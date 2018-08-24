FUNCTION flatten, coef
	COMMON cbvcom1, vec, v1, v2, phot0, time0, maxcoef
	COMMON flatcom,asym,flatness,mid,meanphot,findsharp
	timecbv = vec.(0)
	IF (N_ELEMENTS(time0) ne N_ELEMENTS(timecbv)) THEN BEGIN
		PRINT,' time and timecbv do not match'
		STOP
	ENDIF
	p1 = phot0
	; Sharpness and asym
	IF findsharp EQ 1 THEN p1 *= (1e0+flatness*coef[1])*(1e0+asym*coef[0]) 

	; CBV vectors
	nvec = v2 - v1 + 1
	IF findsharp EQ 1 THEN BEGIN
		nvec = nvec+2
;		FOR i = 2,nvec-1 DO  IF (ABS(coef[i]) GT maxcoef/FLOAT(i-1)) THEN coef[i] = maxcoef/FLOAT(i-1)*signum(coef[i])
		FOR i = 2,nvec-1 DO  IF (ABS(coef[i]) GT maxcoef) THEN coef[i] = maxcoef*signum(coef[i])
		FOR i = 2,nvec-1 DO p1 -= coef[i]*vec.(i+v1)
	ENDIF ELSE BEGIN
		FOR i = 0,nvec-1 DO  IF (ABS(coef[i]) GT maxcoef/FLOAT(i+1)) THEN coef[i] = maxcoef/FLOAT(i+1)*signum(coef[i])
		; If nvec is 1, then fool powell into setting coef[1] to zero
		FOR i = 0,nvec-1 DO p1 -= coef[i]*vec.(i+v1+2)
	ENDELSE

	nn = N_ELEMENTS(p1)
	smp1 = CONGRID(p1,nn/3)
	tmp1 = CONGRID(time0,nn/3)
;	smp1 = SMOOTH(p1,48,/nan)
;	smp1 = smp1[24:-1:48]
;	smp1 = smp1/MEAN(smp1,/nan)
	; Goodness is SF at some point
;	dayshift = 10
	
	;smp1 = ABS(smp1-shift(smp1,-dayshift))
	;ss = TOTAL(smp1[1:-dayshift-1],/nan)
	;;;;;
;	tt = WHERE(time0 lt 1039 and time0 gt 1010)
	;tt = WHERE(time0 gt 1235)
	;ss = sf(time0[tt],p1[tt],instant=12.)
	;ss = MEANABSDEV(p1[tt])],/nan)
	;;;;
	
	;ss = sf(tmp1,smp1,instant=12.)
	ss = sf(time0,p1,instant=12.)

	; Goodness is standard deviation
	;ss = MEANABSDEV(p1,/nan)

	IF nvec EQ 1 THEN ss += coef[1]^2
	RETURN, ss
END
	

FUNCTION cbv,kid,apsize,quarter,channel,phot,time,vlim,t10,t1
	COMMON cbvcom1, vec0, v1,v2, phot0, time0, maxcoef
	COMMON flatcom,asym,flatness,mid,meanphot,findsharp
	maxcoef = 2.00d0
	v1 = vlim[0]
	v2 = vlim[1]
	t0 =  0
	t1 = -1
	; KSN2011a
	IF KID EQ 8480662 THEN BEGIN
	    IF (quarter EQ 10) THEN BEGIN
		t0 = 0
		t1 = WHERE(time GT 933.5)
		t1 = t1[0]
		meanphot=MEAN(phot[t0:t1],/nan)
	    ENDIF
	    ;if (quarter eq 12) then begin
	;	t0 = where(time gt 1150)
	;	t0 = t0[0]
	;	t1 = -1
	;	meanphot=mean(phot[t0:t1],/nan)
	;    endif
	ENDIF
	; KSN2011d
	IF KID EQ 10649106 THEN BEGIN
	    IF (quarter EQ 11) THEN BEGIN
		t0 = WHERE(time GT 1001) 
		t1 = WHERE(time GT 1038)
		t0 = t0[0]
		t1 = t1[0]
		meanphot = MEAN(phot[t0:t1],/nan)
	    ENDIF
	    IF (quarter EQ 12) THEN BEGIN
		t2 = WHERE(time GT 1164)
		t2 = t2[0]
		phot[t2:*] *= 1.002
	    ENDIF
	    IF (quarter EQ 13) THEN BEGIN
		t0 = WHERE(time GT 1215)
		t0 = t0[0]
		t1 = -1
		meanphot=MEAN(phot[t0:t1],/nan)
	   ENDIF
	ENDIF
	phot0 = phot[t0:t1]/meanphot - .5d0
	time0 = time[t0:t1]
	schan= STRING(format='(i02)',channel)
	sq = STRING(format='(i02)',quarter)
	IF !version.os EQ 'Win32' THEN $
	 dir = "C:\Users\eshaya\Dropbox\Kepler Mission\targ\CBV\" $
	ELSE $
	 dir = "/home/eshaya/Documents/Kepler/targ/CBV/"
	filenm=FILE_SEARCH(dir + '*-q'+sq+'-d*',/fully_qualify_path)
	cbvstruc = read_fitswhole(filenm)

	module = chan2mod(channel,1)
	m1 = FIX(module)
	m2 = FIX((module- FIX(module))*10.0001)
	sm1 = STRTRIM(STRING(m1),2)
	sm2 = STRTRIM(STRING(m2),2)
	schan = STRTRIM(STRING(channel),2)
	smod = +sm1+'_'+sm2+'_'+schan
	Result = EXECUTE('cbvs =  cbvstruc.modout_'+smod)
	vec = cbvs.data
	vec0 = vec[t0:t1]

	; Find best coefficients
	func = 'flatten'
	;p=plot(time0,phot0,yrange=minmax(phot0,/nan),symbol='dot',linestyle='')
	; c is the coefficient for the added amount of the vector
	; eventually one is adding less than 1*vector which is small and can stop there.
	; c2 sums all of the c's to get the total amount of the vector used.
	nvec = v2 - v1 + 1
	IF findsharp EQ 1 THEN nvec = nvec+2
	IF (nvec eq 1) THEN nvec = 2
	FOR i=0,nvec-1 DO BEGIN
		x = FLTARR(nvec)
		x[i] = 0.1
		IF (i EQ 0) THEN xarr =[[x]] ELSE xarr = [[xarr],[x]]
	ENDFOR
	xi = TRANSPOSE(xarr)
	coef = FLTARR(nvec)
	ftol = 1.0e-3

	;For KSN2011?
	;if quarter ge 10 and quarter le 12 then begin
                ;if quarter eq 10 then coef=([-0.0226249,-0.00311042,-0.0105148,0.000149659] + [-0.0202722,-0.00105253,0.00167967,-0.00553662])/2.
                ;if quarter eq 10 then coef=[-0.0202722,-0.00105253,0.00167967,-0.00553662]
        ;        if quarter eq 10 then coef=[0.00124348,0.000687592,0.000658676,-0.000555155]
                ;if quarter eq 11 then coef=[-0.00582091,-0.0526826,0.0155974,-0.00212091]
                ;if quarter eq 11 then coef=[-0.000582091,-0.00526826,0.,0.]
        ;        if quarter eq 11 then coef= [0.00,  -0.0,0.,0.]
        ;        if quarter eq 15 then coef= [0.00,  -0.0,0.,0.]
                ;if quarter eq 12 then coef=[0.0556524,-0.0277159,-0.0117196,0.0110628]
        ;        if quarter eq 12 then coef=[0.0757546,-0.0286702,-0.0118970,0.0116647]
;		if quarter eq 11 then  coef=[ -.30666, 1d-11, 0d0,0d0]
;		if quarter eq 11 then  coef=[ -0.15, 0.0357475, 0.00271012, 0.00371497 ]
;		if quarter eq 12 then  coef=[ -1.06 , .14 , -.0000,.0000]
;	endif else $
	;KIC8094413
;	if quarter GE 8 and quarter LE 10 then begin
	  ; Use Q15 for Q7
;	  if quarter EQ 7 then coef=[-0.200000,   -0.0531576 ,   0.0177562,   -0.0152990,0,0]
   ;if quarter EQ 7 then coef=[-0.216755 ,  -0.0568063 ,   0.0150540 ,  -0.0383300,    0.05]
   ;Use Q11 for Q7
; if quarter EQ 7 then coef=[-.13,0,0,0,0]
	  ; Use Q12 for Q8
;		if quarter EQ 8 then coef=[ -0.117 ,  -0.0232 ,  -0.00,   0.00,0]
	;	if quarter EQ 8 then coef=[-0.119569,   -0.0429456 ,  -0.0179256,   0.00706560 , 0.000389162 ]

		; Use Q13 for Q9
	;if quarter EQ 9 then coef=[ -0.150000 ,  0.00196089,   0.00468624 ,   0.0198529,0]
;	if quarter EQ 9 then coef=[-0.168407,  -0.00656625 ,  0.00,    0.000 , -0.00812985]
    ; Use Q6 for Q10
	;	if quarter EQ 10 then coef=[ -0.200000 ,  -0.0818748 ,   0.0127209,  -0.00324067,0,0,0,0]
	;	if quarter EQ 10 then coef=[-0.206973,   -0.0858541,    0.0119395,  -0.00136812 , -0.00]
;if quarter EQ 10 then coef=[-0.250000  ,  -0.125000  , -0.0111158 ,  0.00387453,   0.00777958]
	;	coef = coef[0:nvec-1]
	;endif else  POWELL, coef,xi, ftol,fmin,'flatten'
	POWELL, coef,xi, ftol,fmin,'flatten'

	; For KSN2011d
	IF KID EQ 8480662 THEN BEGIN
	   IF apsize EQ 3 THEN BEGIN
	      IF quarter EQ 11 THEN BEGIN
	             coef=[0.0665742,0.0258178, -0.0016746,0,0,0,0]
		     coef[1] = -coef[1]
		     coef[2] = coef[2]
	      ENDIF
	      IF quarter EQ 12 THEN BEGIN
	             coef=[0.177603, -0.0328247, -0.0190038,0,0,0]
	      ENDIF
           ENDIF
	ENDIF
	IF KID EQ 10649106 THEN BEGIN
	   IF apsize EQ 5 THEN BEGIN
	      ;for apsize5 from Q15
              IF quarter EQ 11 THEN coef=[-0.218887, 0.0878004, 0.0105120,0,0]

	      ;for apsize5 from Q16
	      IF quarter EQ 12 THEN coef=[-0.345193,-0.0325658, 0.00271503,0.00181324,0.000353141]
           ENDIF
	
	   IF apsize EQ 3 THEN BEGIN
	   ; For apsize3 from Q16
	   ; changed sign on coef[1]
	      IF quarter EQ 12 THEN coef=[-0.954382, 0.0675, 0.00605372,0,0]
           ENDIF


	   IF apsize EQ 7 THEN BEGIN
	    IF quarter EQ 11 THEN $
                   coef=[-0.511113  ,  0.137683 ,  0.0412212,0,0]
           ENDIF

	ENDIF

	; Bring phot0 back to original phot not just t0:t1.
	; And use coef to modify it.
	phot0 = phot/meanphot - 0.5d0
	IF findsharp EQ 1 THEN BEGIN
		FOR i = 2,nvec-1 DO  IF (ABS(coef[i]) GT maxcoef/FLOAT(i-1)) THEN coef[i] = maxcoef/FLOAT(i-1)*signum(coef[i])
		PRINT,'cbv: Asym: ',coef[0],' sharpc: ', coef[1]
		IF vlim[0] NE 0 THEN PRINT,'cbv: vecs: ',v1,' to ',v2,' coefs: ',coef[2:*]
	        phot0 *= (1e0+flatness*coef[1])*(1e0+asym*coef[0]) 
		FOR i = 2,nvec-1 DO phot0 -= coef(i)*vec.(i+v1)
	ENDIF ELSE BEGIN
;		for i = 0,nvec-1 do  if (ABS(coef[i]) gt maxcoef/FLOAT(i+1)) then coef[i] = maxcoef/FLOAT(i+1)*signum(coef[i])
		FOR i = 0,nvec-1 DO  IF (ABS(coef[i]) GT maxcoef) THEN coef[i] = maxcoef*signum(coef[i])
		FOR i = 0,nvec-1 DO phot0 -= coef(i)*vec.(i+v1+2)
		IF vlim[0] NE 0 THEN PRINT,'cbv: vecs: ',v1,' to ',v2,' coefs: ',coef
	ENDELSE
	phot0 = (phot0 + 0.5d0)*meanphot

	;hp = plot(time0,phot0,symbol='dot',linestyle='')
	; Remove slope in the quarter
;	first = 0
;	while finite(phot0[first],/nan) do first++
;	last = -1
;	quartile = n_elements(phot0)/4
;	while finite(phot0[last],/nan) do last--
;	dt = mean(time0[last-quartile:last],/nan)-mean(time0[first:quartile],/nan)
;	slope =  (mean(phot0[last-quartile:last],/nan)-mean(phot0[first:quartile],/nan))/dt
;	tmid = time0(where(time0 gt time0[first] + dt/2d0))
;	tmid = tmid[0]
;	fit = slope*(time0-tmid)
;phot0 -= fit
	;p=plot(time0,phot0,yrange=minmax(phot0,/nan),symbol='dot',linestyle='')

RETURN,phot0
END
