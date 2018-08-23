pro plot_fluxtiles,kid,k2cube,time,campaign=campaign,i0=i0,i1=i1,j0=j0,j1=j1,norange=norange


skid = STRTRIM(string(kid),2)
win = window(window_title='Fluxtiles: KTWO '+skid,dimension=[512,512])
win.SetCurrent

if ~keyword_set(k2cube) then begin
	k2cube = read_k2targ(kid,campaign,time,quality,flux_bkg)
	k2cube = double(k2cube)
	dims = size(k2cube,/DIM)
	bad = where(quality ne 0,/null)
	k2cube(*,*,bad) = !values.f_nan
endif

dims = size(k2cube,/dim)

d1 = dims[0]
d2 = dims[1]
if keyword_set(norange) then yrange = 0 else yrange=[min(k2cube,/nan),max(k2cube,/nan)]

if ~keyword_set(i0) then i0 = 0
if ~keyword_set(j0) then j0 = 0
if ~keyword_set(i1) then i1 = d1-1
if ~keyword_set(j1) then j1 = d2-1
dd1 = i1-i0+1
dd2 = j1-j0+1

for j=j0,j1 do for i=i0,i1 do begin
	f = k2cube[i,j,*]
	fsm = smooth(f[*],48,/nan,/edge_truncate)
        f[where(ABS(f[*]-fsm[*]) gt 40.,/null)] = !VALUES.F_NAN
	p=plot(/current,time,f[*],layout=[dd1,dd2,(j1-j)*dd1+i-i0+1],$
		xshowtext=0,yshowtext=0,$
		yrange=yrange,margin=0,symbol='dot',linestyle='')
endfor
return
end

