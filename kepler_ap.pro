;Define aperture size.  Each side of box is 2*ap+1.
ap = 2
; Get list of initial positions
xc1 = res_000000.xx_ov
yc1 = res_000000.yy_ov

; Declare array for each star on each FFI
phot = DBLARR(nstars,nffi)
xc_arr = DBLARR(nstars,nffi)
yc_arr = DBLARR(nstars,nffi)
sky = dblarr(nstars)

center = 2+ap
keep1 = 2
keep2 = 2+2*ap
sky1 = 1
sky2 = keep2+1
; Number of pixels in aperture (will need to subtract NaNs)
nkeep = (2d0*double(ap)+1d0)^2

; LOOP OVER FFIs
FOR ffi = 0, nffi-1 DO BEGIN  
   ixc1 = round(xc1)
   iyc1 = round(yc1)
   ffindex = ffindices[ffi]
   IF (ffindex LE 9) THEN res = 'RES_00000'+string(ffindex,FORMAT='(i1)')
   IF (ffindex ge 10) THEN res = 'RES_0000'+string(ffindex,FORMAT='(i2)') 
   PRINT,res
   result = execute('res ='+res)
   img = res.dat_map
   FOR star = 0, nstars-1 do begin
	xc = xc1[star] & yc = yc1[star]
	lastxmove = 0
	lastymove = 0
	xreversal = 0
	yreversal = 0
	stampit:
	ixc = fix(xc) & iyc = fix(yc)
	ixc1[star] = ixc
	iyc1[star] = iyc
  	stamp = img[ixc-center:ixc+center,iyc-center:iyc+center]
	if (not finite(stamp[center,center])) then begin
		phot[star,ffi] = !values.f_nan
		xc_arr[star,ffi] = !values.f_nan
		yc_arr[star,ffi] = !values.f_nan
		continue
	endif
	xdiff = ixc1 - ixc 
	xnear = where(abs(xdiff) lt center,nnear)
	ydiff = iyc1[xnear] - iyc[xnear]
	ynear = where(abs(ydiff) lt center,nnear)
	near = xnear[ynear]
	xd1 = xdiff[near]
	yd1 = ydiff[ynear]
	nnans = 0
	FOR n = 0, nnear-1 do BEGIN
		xd = xd1[n] & yd = yd1[n]
		IF (xd eq 0 and yd eq 0) then continue
		FOR i = -1,1 DO BEGIN
			FOR j = -1,1 DO BEGIN
				IF (abs(xd+i) gt center or abs(yd+j) gt center) THEN CONTINUE
				stamp[center+xd+i,center+yd+j] = !VALUES.F_NAN
				IF (abs(xd+i) ge keep1 and abs(yd+j) ge keep1 $
					and abs(xd+i) le keep2 and abs(yd+j) le keep2) $
					THEN nnans = nnans+1

			ENDFOR
		ENDFOR
	ENDFOR
	; Measure sky on 4 sides
;	IF (ffi EQ 0) THEN BEGIN
		xsky1 = median(stamp[sky1, keep1:keep2],/double) 
	        xsky2 =	median(stamp[sky2, keep1:keep2],/double)
		ysky1 = median(stamp[keep1:keep2, sky1],/double) 
	        ysky2 =	median(stamp[keep1:keep2, sky2],/double)
		sky[star] = (xsky1+ysky1+xsky2+ysky2)/4d0
;	ENDIF
	; Here is sum of counts in aperture - sky*npixels
	phot[star,ffi] = total(stamp[keep1:keep2,keep1:keep2],/double,/nan)  - sky[star]*(nkeep-nnans)
	; If counts is negative, make in NaN
	IF (phot[star,ffi] lt 0d0) THEN  BEGIN
		phot[star,ffi] = !values.f_nan
		xc_arr[star,ffi] = !values.f_nan
		yc_arr[star,ffi] = !values.f_nan
		continue
	endif

	; Centroids in xc_arr and yc_arr
	; Compare counts in pix Pixels on either side of center
	;  Needs to be calibrated with PSF
	for pix = -1, 1 do begin
		if (finite(stamp[center+1,center+pix]) and $
			finite(stamp[center-1,center+pix])) THEN $
				xc_arr[star,ffi] +=  stamp[center+1,center+pix]  $
			  			- stamp[center-1,center+pix]
		if (finite(stamp[center+pix,center+1]) and $
			finite(stamp[center+pix,center-1])) THEN  $
				yc_arr[star,ffi] += stamp[center+pix,center+1] $
						- stamp[center+pix,center-1]
	endfor
	result = where(finite(stamp[center-1:center+1,center-1:center+1]),nfinite)
	nfinite = float(nfinite)
	ninepix = total(stamp[center-1:center+1,center-1:center+1],/double,/nan) - sky[star]*nfinite
	xc_arr[star,ffi] /=  ninepix
	yc_arr[star,ffi] /= ninepix

	; IF centroid is in next pixel then move stamp over to next pixel
	if (abs(xc_arr[star,ffi]) gt 0.52 or abs(yc_arr[star,ffi]) gt 0.52) then begin
		; Give up if need to move 3 pixels
		if (abs(xc_arr[star,ffi] + ixc - xc1[star]) gt 3) then begin
			phot[star,ffi] = !values.f_nan
			xc_arr[star,ffi] = !values.f_nan
			yc_arr[star,ffi] = !values.f_nan
			continue
		endif
		if (xc_arr[star,ffi] gt 0.52) then begin
			if (lastxmove eq -1) then xreversal = 1 else xc +=  1 
			lastxmove = 1
		endif
		if (xc_arr[star,ffi] lt -0.52) then begin
			if (lastxmove eq 1) then xreversal = 1 else xc -=  1 
			lastxmove = -1
		endif
		if (yc_arr[star,ffi] gt 0.52) then begin
			if (lastymove eq -1) then yreversal = 1 else yc +=  1 
			lastymove = 1
		endif
		if (yc_arr[star,ffi] lt -0.52) then begin
			if (lastymove eq 1) then yreversal = 1 else yc -=  1 
			lastymove = -1
		endif
;		print,'ffi = ',ffi,'  star= ',star,' old xpos=',xc1[star],' xpos=',xc_arr[star,ffi]
;		print,'ffi = ',ffi,'  star = ',star,'  old ypos=',yc1[star],' ypos=',yc_arr[star,ffi]

		; If last move is a reversal of previous move, then take half a step
		if (xreversal eq 1 or yreversal eq 1) then begin
			if (xreversal eq 1) then xc_arr[star,ffi] = ixc + 0.5*(1+lastxmove)
			if (yreversal eq 1) then yc_arr[star,ffi] = iyc + 0.5*(1+lastymove)
		endif else begin
			goto, stampit
		endelse
	endif

	;  Adjust for frame where corners of pixels are at integer values.
	xc_arr[star,ffi] += (double(ixc) + 0.5d0)
	yc_arr[star,ffi] += (double(iyc) + 0.5d0)
   ENDFOR ; Loop on stars
ENDFOR ; Loop on ffis
END


