pro kepler_regress,outfile,apphot,xpos,ypos,mjd_arr,coeffs,afit,nominals,sigma,corr,apphotout
obsarr = apphot
dims = size(obsarr,/dim)
nstars = dims[0]
nffi = dims[1]
for star = 0L, nstars-1 do $
   obsarr[star,*] = obsarr[star,*]/mean(apphot[star,*])
nobs = 1
obsarr = reform(obsarr,nstars*nffi)
obsfinite = where(finite(obsarr))
obsarr = obsarr[obsfinite]
obsarr = alog10(obsarr)
obs = 0

; environ: position on pixel
xp = reform(xpos)
yp = reform(ypos)

apphotout = apphot[obsfinite]
xpos = xpos[obsfinite]
ypos = ypos[obsfinite]
xfinite = where(finite(xpos))
obsarr = obsarr[xfinite]
xpos = xpos[xfinite]
ypos = ypos[xfinite]
apphotout = apphotout[xfinite]
yfinite = where(finite(ypos))
obsarr = obsarr[yfinite]
ypos = ypos[yfinite]
ypos = ypos[yfinite]
apphotout = apphotout[yfinite]

xp = xp-fix(xp) - 0.5d0
yp = yp-fix(yp) - 0.5d0
xc = (xp - 5d2)/1d3
yc = (yp- 5d2)/1d3

xc = reform(xc,nstars,nffi)
yc = reform(yc,nstars,nffi)
nenviron =  21L
environ = dblarr(nenviron,nstars*nffi)
afit = dblarr(nobs,nstars*nffi)
nominals = dblarr(nobs)
coeffs = dblarr(nenviron,nobs)

environNames =  [ 'xp','yp','xp^2','yp^2','xp*yp','xp^3','yp^3']
;environNames =  [environNames, 'xc','yc','xc^2','yc^2','xc*yc','xc^3','yc^3','Counts']
environNames =  [environNames, 'Counts']
environNames =  [environNames, 'cost','sint','cost^2','sint^2','cost^3','sint^3']
ke =  0L
; environ: position on pixel
environ[ke,*] = xp & ke++
environ[ke,*] = yp & ke++
environ[ke,*] = xp^2 & ke++
environ[ke,*] = yp^2 & ke++
environ[ke,*] = yp*xp & ke++
environ[ke,*] = xp^3 & ke++
environ[ke,*] = yp^3 & ke++
ke1 = ke
for ffi = 0L, nffi-1 do begin
	ke = ke1
	phase = 2d0*!pi*(mjd_arr[0]-mjd_arr[ffi])/365.25d0
	cost = cos(phase)
	sint = sin(phase)
	; environ: position on chip
	; x,y,x^2,y^2,xy,x^3,y^3,x^2y,y^2x
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = xc[*,ffi]*cost & ke++
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = yc[*,ffi]*cost & ke++
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = xc[*,ffi]^2*cost & ke++
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = yc[*,ffi]^2*cost & ke++
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = yc[*,ffi]*xc[*,ffi]*cost & ke++
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = xc[*,ffi]^3*cost & ke++
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = yc[*,ffi]^3*cost & ke++
	; environ: counts
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = apphot[*,0] & ke++
	; environ: 2*pi*mjd/265.25
	print,'ffi,cost2,sint2: ',ffi,cost^2,sint^2
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = cost & ke++
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = sint & ke++
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = cost^2 & ke++
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = sint^2 & ke++
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = cost^3 & ke++
	environ[ke,nstars*ffi:nstars*(ffi+1)-1] = sint^3 & ke++
endfor
GET_LUN,out
OPENW,out, outfile

  	coeff = REGRESS( environ, obsarr, $
		CHISQ=chisq, CONST=nominal, $
		CORRELATION=corr, /DOUBLE, FTEST=ftest, $
		MCORRELATION=mcorr, MEASURE_ERRORS=merrors, $
		SIGMA=sigma, STATUS=status, YFIT=yfit ) 

	PRINTF,format='(11x,21a11)',out,environNames
	PRINTF,FORMAT='(22e11.3)',out,nominal,coeff
	PRINTF,FORMAT='(11x,21e11.3)',out,sigma
	PRINTF,FORMAT='(11x,21e11.3)',out,corr
	PRINT,format='(11x,21a11)',environNames
	PRINT,'Nominal and Coeffs'
	PRINT,FORMAT='(22e11.3)',nominal,coeff
	PRINT,'Sigmas'
	PRINT,FORMAT='(11x,21e11.3)', sigma
	PRINT,'Correlations'
	PRINT,FORMAT='(11x,21e11.3)', corr
	afit[obs,*] = reform(yfit)
	nominals[obs] = nominal
	coeffs[*,obs] = coeff
	IF (status NE 0) THEN BEGIN
		PRINT,' Problem with fit to ',obs+1
      		IF(status EQ 1) THEN PRINT,'Singular Array'
      		IF(status EQ 2) THEN PRINT,'small pivot element'
    	ENDIF
	FREE_LUN,out
	afit = 10.^afit
	afit = reform(afit,nstars,nffi)
	apphotout = reform(apphotout,nstars,nffi)
	for star = 0L, nstars-1 do $
		afit[star,*] = afit[star,*] * mean(apphot[star,*])
	RETURN
	END
