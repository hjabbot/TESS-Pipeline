function k2pca,campaign,phots_pca,bin=bin,ap=ap,variances=variances

if ~keyword_set(bin) then bin = 1

   mincounts = 1000d0*double(ap)/5d0
   dim = size(phots_pca,/dim)
   if dim[0] eq 0 then return, -1
   nt = dim[0]
   nt0 = nt
   ts = indgen(nt)
   nobj = dim[1]

   lc = []
   stillwh = []
   for i = 0, nobj-1 do begin
        ; put NaN at aberrant points (may be cosmic ray hits)
	lci = phots_pca[*,i]
	sm = lci - smooth(lci,48/bin,/edge_truncate,/nan)
	stdv = stddev(sm,/nan)
	;lci[where(abs(sm) gt 5*stdv,/null)] = !VALUES.D_NAN
   
   	; Interpolate light curves at NaNs
   	wh = where(finite(lci,/nan),nnan)
   	slci = smooth(lci,24/bin,/nan,/edge_truncate) 
	; Replace NaNs with interpolation
   	lci[wh] = slci[wh]

        ;;; Here is where smoothing takes place
        ;lci = smooth(lci,48,/nan,/edge_truncate)

	; Here we replace beginning NANs with constant value
	whfinite = where(finite(lci))
	first = whfinite[0]
	if first ne 0 then lci[0:first-1] = lci[first]

	; If too faint, skip
   	if (mean(lci,/double,/nan) lt mincounts) then continue
  	; If there are still nans we keep track of where 
  	wh = where(finite(lci,/nan),/null,nnan)
	; If too many nans, skip this lc
	;if (nnan gt nt/2.) then continue
	;if (nnan gt 1) then continue
	stillwh = [stillwh,wh]
        lc = [[lc],[lci]]
   endfor
   dim = size(lc,/dim)
   nobj = dim[1]
   print, 'pca: Number of good LC ',nobj
   if (n_elements(stillwh) NE 0) THEN BEGIN
	; Make list of indices without NaNs
   	stillwh = stillwh[uniq(stillwh,sort(stillwh))]
	tsleft = rmelement(ts,stillwh)
	nt = n_elements(tsleft)

   	; Remove remaining NaNs
   	lc2 = rmelement(lc[*,0],stillwh) 
   	lc3 = lc2
   	for j = 1, nobj-1 do begin
	   	lc2 = rmelement(lc[*,j],stillwh) 
	   	lc3=[[lc3],[lc2]]
   	endfor

   endif else lc3 = lc
   lc = transpose(lc3)
   means = TOTAL(lc, 2, /double)/double(nt)
   ; Normalize 
   lc = lc/REBIN(means, nobj, nt) - 1d0
   ;Compute derived variables based upon the principal components.
   result = PCOMP(lc, COEFFICIENTS = coefficients, /double,$
     EIGENVALUES=eigenvalues, VARIANCES=variances, /COVARIANCE)
   ;PRINT, 'Coefficients: '
   ;FOR mode=0,3 DO PRINT, $
   ;   mode+1, coefficients[*,mode], $
   ;   FORMAT='("Mode#",I1,4(F10.4))'
   eigenvectors = coefficients/REBIN(eigenvalues, nobj, nobj)
   ;PRINT
   ;PRINT, *]'Eigenvectors: '
   ;FOR mode=0,3 DO PRINT, $
   ;   mode+1, eigenvectors[*,mode],$
   ;   FORMAT='("Mode#",I1,4(F10.4))'
   array_reconstruct = result ## eigenvectors
   PRINT
   PRINT, 'Reconstruction error: ', $
      TOTAL((array_reconstruct - lc)^2)
   PRINT
   PRINT, 'Energy conservation: ', TOTAL(lc^2), $
      TOTAL(eigenvalues)*(nt-1)
   PRINT
   PRINT, '     Mode   Eigenvalue  PercentVariance'
   nmodes = n_elements(eigenvalues)
   FOR mode=0,(4 < nmodes-1) DO PRINT, $
      mode+1, eigenvalues[mode], variances[mode]*100
   for i = 0,nobj-1 do result[i,*] = result[i,*]/sqrt(variance(result[i,*],/nan))

   ; Put back NaNs at beginning of LC
;   if first ne 0 then begin
;	   r0 = dblarr(nobj,nt0)
;;;	   r0[*,*] = !VALUES.D_NAN
;	   r0[*, first:*] = result
;	   result = r0
;   endif
   ; Put back NaNs in stillwh
   if nt0 ne nt then begin
   	result2 = dblarr(nobj,nt0)
   	result2[*,*] = !VALUES.D_NAN
   	for i=0,nobj-1 do result2[i,tsleft] = result[i,*]
   endif else result2 = result
return,result2
END
