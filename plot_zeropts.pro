pro plot_zeropts,zeropts1,season,startime,startseason,endseason,oat=oat
; Just plot the photometric zeropts of each channel

if (n_params() eq 0) then begin
	print,' Usage: plot_zeropts,zeropts,season,startime,startseason,endseason,noseason=noseason,oat=oat'
	return
endif

season1=season
if ~keyword_set(startseason) then startseason = 0 
if ~keyword_set(endseason) then endseason = 3 
if ~keyword_set(oat) then oat = 0 
wh0=where(season1 eq 0)
wh1=where(season1 eq 1)
wh2=where(season1 eq 2)
wh3=where(season1 eq 3)
n_ffis = 41
startseason = 0
endseason = 0
season1 = intarr(n_ffis)
zeropts=zeropts1
stime=startime-startime[0]
whnan=where(zeropts eq -0.09d0,/null)
zeropts[whnan] = !values.f_nan
dum=''
for s=startseason,endseason do begin
	wh=where(season1 eq s)
	if (!d.name eq 'X') then begin
	wset,s
	for i=1,84 do begin
		print,'channel ',i,' season ',s
		plot,stime[wh],zeropts[wh,i]-zeropts[wh[0],i],xrange=[-10,1200],$
		yrange=[-.06,.04],xtitle='Days',ytitle='Magnitude',$
		title='Changes in sensitivity of all 84 Channels',linestyle=1
		oplot,stime[wh0],zeropts[wh0,i]-zeropts[wh[0],i],psym=1
		oplot,stime[wh1],zeropts[wh1,i]-zeropts[wh[0],i],psym=2
		oplot,stime[wh2],zeropts[wh2,i]-zeropts[wh[0],i],psym=4
		oplot,stime[wh3],zeropts[wh3,i]-zeropts[wh[0],i],psym=5
		for yr=0,1200,365 do oplot,[yr,yr],[-1,1],linestyle=2
		if (oat eq 1) then read,'Next: ',dum
	endfor
	endif else begin
		i = 0
		plot,stime[wh],zeropts[wh,i]-zeropts[wh[0],i],xrange=[-10,1200],$
		yrange=[-.06,.04],xtitle='Days',ytitle='Magnitude',$
		title='Changes in sensitivity of all 84 Channels'
	endelse
	for i=1,84 do oplot,stime[wh],zeropts[wh,i]-zeropts[wh[1],i],linestyle=1
	for i=1,84 do oplot,stime[wh0],zeropts[wh0,i]-zeropts[wh[1],i],psym=1
	for i=1,84 do oplot,stime[wh1],zeropts[wh1,i]-zeropts[wh[1],i],psym=2
	for i=1,84 do oplot,stime[wh2],zeropts[wh2,i]-zeropts[wh[1],i],psym=4
	for i=1,84 do oplot,stime[wh3],zeropts[wh3,i]-zeropts[wh[1],i],psym=5
	for yr=0,1200,365 do oplot,[yr,yr],[-1,1],linestyle=2
endfor
end
