FUNCTION photbykic,kic,startffi=startffi,endffi=endffi,adjust=adjust,stamp=stamp,$
              phot=phot,noread=noread,noplot=noplot,wunit=wunit,agnflag=agnflag,view=view,wun2=wun2

; For a single galaxy, returns dblarr(3) of variation for golden FFIs, Median of all ffis, maximum excursion
; INPUTS
; startffi - First FFI to use (default starffi=0)
; endffi - Last FFI to use (default endffi=n_ffis-1)
; adjust - 0 for no adjustment, 1 for using means for each season, 
;          2 for normalizing by first year.
;
; OUTPUTS
; stamp - a  100 x 100 pixel image centered on galaxy
; phot - the photometry 
; noread - 1 for skipping setting all of the parameters (default, noread=0)
; noplot - 1 to skip plotting (default, noplot=0)
; wunit -  write unit to output, 5 for screen
; wun2 - write unit to output for a different line
; agnflag - 1 to add 0 to end of output (?)
; view - 1 to view stamp on active window 

setup_ffi,quarter,season,startime,dateobs,ffilist,n_ffis
if ~keyword_set(startffi) then startffi = 0
if ~keyword_set(endffi) then endffi = n_ffis-1
if ~keyword_set(noread) then noread = 0
if ~keyword_set(adjust) then adjust = 0
if ~keyword_set(noplot) then noplot = 0
if ~keyword_set(wunit) then wunit = 0
if ~keyword_set(wun2) then wun2 = 0
if ~keyword_set(agnflag) then agnflag = 0
if ~keyword_set(view) then view = 0
if view then loadct,0
nffis = endffi-startffi+1
ffis = indgen(nffis)+startffi

;startime = startime - startime[0] 
if (noread eq 1) then goto,skipread
phot = dblarr(nffis)
counts = dblarr(nffis)
xc = dblarr(nffis)
yc = dblarr(nffis)
;count0 = 1d8
;mag0 = 11.8d0-6.4d0
count0 = 2.29087d5
mag0 = 12d0

; Read zeropts
ii=0
cch=0
nch = 84
zeroPts = dblarr(n_ffis,nch+1)
openr,13,"zeroPts.txt"
row=dblarr(nch+1)
dummy= ''
for i = 0, n_ffis-1 do begin
	readf,13,ii,dummy
	reads,dummy,row
	zeroPts[i,*] = row
endfor
close,13
; Check photometry files for one with this kic number
spawn,"grep ' "+strtrim(string(kic),2)+" ' phot/2009114174833_q1_s3_c*.phot",photfile

; Handle problems
if (n_elements(photfile) ne 1 or photfile eq '') then begin
	print,'Problem with finding photfile for kic ',kic
        if (n_elements(photfile) gt 1) then print,' Too many, ',photfile	
	return,[!values.d_nan,!values.d_nan,!values.d_nan]
endif

; Get channel used in season 3 (same as area)
sarea = strmid(photfile,strpos(photfile,'c')+1,2)
sarea = fix(sarea)


print,'KIC: ',kic
;print,'      FFI   ',' Channel  ',' Season      ',' Mag      ','  Counts      ','      XC           ',' YC      '
for iffi=0,nffis-1 do begin
	ffi = startffi+iffi
	chan = getchannel(sarea,ffi)
	; Read photometry data
	read_photfile,ffi,chan,struct,nstars
	; Find index of kic
	indx = where(struct.kepid eq kic,count)
	if (count eq 0) then obj.phot = !values.d_nan else obj = struct[indx]
	; Remove those with NaN in positions
	if ~finite(obj.phot) then begin
		print,' NaN for kic ',kic
		counts[iffi] = !values.d_nan
		phot[iffi] = !values.d_nan
		xc[iffi] = !values.d_nan
		yc[iffi] = !values.d_nan
	endif else begin
	
	   side=100
	   if (ffi le 28) then obj.phot = obj.phot/1625d0
	   counts[iffi] = obj.phot
	   mag2 = mag0 + zeropts[ffi,chan]
	   obj.phot = -2.5*alog10(obj.phot/count0)+mag2[0]
	   ;print,ffi,season[ffi],mag2[0],count0
	   phot[iffi] = obj.phot
	   xc[iffi] = obj.xc
	   yc[iffi] = obj.yc
	   if (view) then begin
		fitsfile=ffilist[ffi]
		stop
		img = mrdfits("FFIs/"+fitsfile,chan)
		if (ffi le 28) then img = img/1625d0
		dim=size(img,/dim)
		x1 = obj.xc-side
		x2 = obj.xc+side-1
		y1 = obj.yc-side
		y2 = obj.yc+side-1
		s1 = 0
		s2 = 0
		if (dim[0] - obj.xc lt side) then begin
			x2 = dim[0]-1 
		endif
		if (obj.xc lt side) then begin
			x1 = 0 
			s1 = side - obj.xc
		endif
		if (dim[1] - obj.yc lt side) then begin
			y2 = dim[1]-1
		endif
		if (obj.yc lt side) then begin
			y2 = 0 
			s2 = side - obj.yc
		endif
		stamp = fltarr(2*side,2*side)
		stamp[s1,s2]=img[x1:x2,y1:y2]
		if (ffi eq startffi) then stretch0= 2d0*mean(stamp,/nan)
		minimg=min(stamp[side-10:side+9,side-10:side+9],/nan)
		if (where([41,42,43,44] eq chan) ne -1) then $
		if ((season[ffi] eq 0) or (season[ffi] eq 2)) then $
			stamp=transpose(stamp)
		;wset,season[ffi]
		tv1,stamp,minimg,stretch0 - minimg
		read,'Continue? ',dummy
	endif
   endelse
print,ffi,chan,season[ffi],xc[iffi],yc[iffi],counts[iffi],phot[iffi]
if (wun2 ne 0) then printf,format='(i10,i3,i4,i4,1x,f9.3,1x,3f11.5,1x,f7.3)',wun2,kic,ffi,chan,season[iffi],startime[iffi],xc[iffi],yc[iffi],counts[iffi],phot[iffi]
endfor; next ffi
; If there is just one FFI being examined return structure with mag, counts, xc, yc.
if (nffis eq 1) then begin
	return, obj
endif
skipread:
s0 = where(season[ffis] eq 0)
s1 = where(season[ffis] eq 1)
s2 = where(season[ffis] eq 2)
s3 = where(season[ffis] eq 3)
phot2 = phot
;;;;;
;;phot2 = phot2[0:-2]
;;;;;;
cgold= mean(phot[s3[0:7]])
case adjust of 
	0: 
	1: begin
		; Bring mean of each quarter in first year to mean of golden set
		c0 = mean(phot[s0[1:5]])
		c1 = mean(phot[s1[0:2]])
		c2 = mean(phot[s2[0:3]])
		c3 = mean(phot[s3[8:10]])
		phot2[s0] = phot2[s0]+cgold-c0
		phot2[s1] = phot2[s1]+cgold-c1
		phot2[s2] = phot2[s2]+cgold-c2
		phot2[s3[8:*]] = phot2[s3[8:*]]+cgold-c3
    	    end
	2: begin
		; Bring second FFI in each quarter to golden set
		; and raise/lower all others in quarter by same.
		phot2[s0]  = phot2[s0]+cgold-phot2[s0[1]]
		phot2[s1]  = phot2[s1]+cgold-phot2[s1[1]]
		phot2[s2]  = phot2[s2]+cgold-phot2[s2[1]]
		phot2[s3[8:*]] = phot2[s3[8:*]]+cgold-phot2[s3[9]]
	    end
	    else: print,'adjust should be 0,1, or 2'
endcase

if (noplot eq 0) then begin

range=max(phot2)-min(phot2)
plt=plot(startime[ffis],phot2,$
	yrange=[max(phot2)+.05*range,min(phot2)-.05*range],$
	xrange=[-50,1200],$
	ystyle=1,$
	xtitle='Day',ytitle='Kepler Mag',font_size=14,$
	title='KIC'+strtrim(string(kic),2))
plt = plot(/overplot,startime[ffis[s0]],phot2[s0],symbol="+",linestyle="",sym_size=2)
plt = plot(/overplot,startime[ffis[s1]],phot2[s1],symbol="x",linestyle="",sym_size=2)
plt = plot(/overplot,startime[ffis[s2]],phot2[s2],symbol="Diamond",linestyle="",sym_size=2)
plt = plot(/overplot,startime[ffis[s3]],phot2[s3],symbol="Square",linestyle="",sym_size=2)
for i=0,3 do plt = plot(/overplot,[i,i]*365,[0,25],linestyle="-")
endif
; Median Absolute Differences
; Goldens
gdiff = 0
for i= 1,7 do gdiff += abs(phot[i] - phot[i-1]) 
gdiff = gdiff/7.

; Yearly differences
nydiff=18
ydiff = fltarr(nydiff)
ffi1 = intarr(2,nydiff)
ffi1[*,0] = [7,18]
ffi1[*,1] = [18,29]
ffi1[*,2] = [9,22]
ffi1[*,3] = [22,33] 
ffi1[*,4] = [10,23]
ffi1[*,5] = [23,34]
ffi1[*,6] = [11,24]
ffi1[*,7] = [24,35]
ffi1[*,8] = [12,25]
ffi1[*,9] = [25,36]
ffi1[*,10] = [13,26] 
ffi1[*,11] = [26,37]
ffi1[*,12] = [15,27]
ffi1[*,13] = [27,38]
ffi1[*,14] = [16,28]
ffi1[*,15] = [28,39]
ffi1[*,16] = [18,29]
ffi1[*,17] = [19,30]
;for i =0,nydiff-1 do if (season[ffi1[0,i]] ne season[ffi1[1,i]]) then stop
;print,'Passed season test'
;for i =0,nydiff-1 do if ((abs(startime[ffi1[1,i]] - startime[ffi1[0,i]]) - 365.) gt 14.) then stop
;print,'Passed year test'
for i = 0, nydiff-1 do ydiff[i] = phot[ffi1[0,i]] - phot[ffi1[1,i]]

a1 = median(abs(ydiff))
maxamp=max(abs(ydiff),/nan)
; Write to screen
print,format='(a5,a7,4a9)','KIC', 'Kepmag','goldens', 'Median','Max','FFIMAG'
if (agnflag eq 0) then print,format='(i9,2x,f5.2,4f9.5)',kic,obj.kepmag,gdiff,a1,maxamp,obj.phot
if (agnflag ne 0) then print,format='(i9,2x,f5.2,4f9.5,i3)',kic,obj.kepmag,gdiff,a1,maxamp,obj.phot,agnflag-1
; Write to wunit
if (wunit ne 0 and (agnflag eq 0)) then printf,format='(i9,2x,f5.2,4f9.5)',wunit,kic,obj.kepmag,gdiff,a1,maxamp,obj.phot
if (wunit ne 0 and (agnflag ne 0)) then printf,format='(i9,2x,f5.2,4f9.5,i3)',wunit,kic,obj.kepmag,gdiff,a1,maxamp,obj.phot,agnflag-1
return,[gdiff,a1,maxamp,obj.phot]
end



