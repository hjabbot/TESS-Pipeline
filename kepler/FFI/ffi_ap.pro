pro ffi_ap,x,y,mags,errap0,image0,files,image1,skyerr0,dat_maps
havecoo=1
havemags = 0
;openr,10,'fitsfiles'
;file=''
;nffi=14
;nffi=9
;readf,10,file
;files[0] = file
;image0=readfits(files[0],hdr0,exten_no=1)
ffi = 7
nffi = 14
image0 = dat_maps[*,*,ffi]
if (havecoo eq 0) then begin
;	 Find Stars
	sharplim=[.2,2.]
	fwhm=1.0
	rndlim=[-2.,2.]
	hmin = 2000.
	find, image0, x, y, flux, sharp, rnd, hmin, fwhm, rndlim, sharplim,$
                      print='kepler.coo', SILENT=0
                      
 tv1,image0,2e5,5e5
 mark,image0,x,y
	wh = where(y ge 10. and x ge 10. and y lt 1060 and x lt 1122,nwh)
	if (nwh gt 0) then begin
		x = x[wh]
		y = y[wh]
	endif
endif
; Photometry on first FFI
phpadu=107.
skyrad=[7.,15.]
apr=[1.8,2.2,2.6,3.0]
badpix=[-1.,1e11]
naps = n_elements(apr)
nstars=n_elements(x)
if (havemags ne 1) then begin
	print,' Doing Aper on 0 image'
	aper,image0,x,y,mags0,errap0,sky,skyerr0,phpadu,apr,skyrad,badpix,/silent
	bad = where(mags0 eq 99.9990,nbad)
	if (nbad gt 0) then mags0[bad] = !VALUES.F_NAN
	mags0 = mags0+8.5013
	wherrors = where(sky gt 2.8e5,nerrors)
	if (nerrors gt 0) then mags0[*,wherrors] = !VALUES.F_NAN
	print,'Nerrors =', nerrors
	mags=fltarr(naps,nstars,nffi)
	mags[*,*,ffi]=mags0
endif
xcen=x
ycen=y
bx=3
;for ffi=1,nffi-1 do begin
;	readf,10,file
;	files[ffi] = file
;endfor
;close,10
;xstar0 = 753.266
;ystar0 = 474.022
;xstar = [xstar0,xstar0,xstar0,xstar0,xstar0,$
;;		 xstar0,xstar0,xstar0,753.916,753.855,$
;		 753.873,758.021,758.023,758.001]
;ystar = [ystar0,ystar0,ystar0,ystar0,ystar0,$
;		 ystar0,ystar0,ystar0,473.328,469.476,$
;	 	469.499,471.248,471.311,470.992]
;bright = where(mags[3,*,0] lt 16. and mags[3,*,0] gt 10.)
for ffi = 0, nffi-1 do begin
	IF (ffi EQ 7) THEN continue
;	image1=readfits(files[ffi],hdr0,exten_no=1)
	image1 = dat_maps[*,*,ffi]
	fwhm = 1.
	offset = 0.0
;	x1 = x-xstar0+xstar[ffi]
;	y1 = y-ystar0+ystar[ffi]
	x1 = x
	y1 = y
	for i = 0,nstars-1 do begin
		cntrd,image1[x1[i]-bx:x1[i]+bx,y1[i]-bx:y1[i]+bx],bx,bx,xcen1,ycen1,fwhm,/SILENT
		xcen[i]=xcen1+x1[i]+1
		ycen[i]=ycen1+y1[i]+1
	endfor
	if (havemags eq 1) then goto,plotthem
	print,' Doing Aper', ffi
	aper,image1,xcen,ycen,mags1,errap,sky,skyerr,phpadu,apr,skyrad,badpix,/silent
	bad = where(mags1 eq 99.9990,nbad)
	if (nbad gt 0) then mags1[bad] = !VALUES.F_NAN
	mags1 = mags1+8.5013
	if (nerrors gt 0) then mags1[wherrors] = !VALUES.F_NAN
	mags[*,*,ffi]=mags1
	plotthem:
;	mom = moment(mags[3,bright,ffi]-mags[3,bright,0],maxmoment=2,sdev=sdev,/nan)
;	better = where(abs(mags[1,bright,ffi]-mags[1,bright,0]- mom[0]) lt 5.*sdev,nbetter)
;	better = where(mags[3,bright,ffi] lt 99.9,nbetter)
;	mom = moment(mags[3,bright,ffi]-mags[3,bright,0],maxmoment=2,sdev=sdev,/nan)
;	print,mom[0],sdev
;	yrange=[-sdev,sdev]*2.
;	for ap=3,3 do begin
;		print,'ap = ',ap,'  ffi = ',ffi
;		plot,mags[ap,*,0],mags[ap,*,ffi]-mags[ap,*,0]-mom[0],xrange=[10,20],yrange=yrange,thick=3,charthick=2,$
;	psym=3,xtitle='!8 Kepler Mag',ytitle='Mag1-Mag0',charsize=2.0
;		wait,2
;	endfor
endfor
print,'Done'
end
