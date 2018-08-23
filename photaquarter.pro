function photaquarter,gotable,quarter,skygroup,apsize,phothash=phothash,noplot=noplot,slope=slope,$
	data=data,igal0=igal0,ps=ps,pdf=pdf,kid=kid,fittime=fittime,$
		vlim=vlim,close=close,tv=tv,findsharp=findsharp
; Inputs
;	gotable - array of tables with info from MAST
;	quarter - quarter or seaon of interest
;	skygroup - skygroup of interest
;	apsize - aperture size (1,3,5, or 7)
;	fittime - [fitt0,fitt1] - start and end time to fit vectors in days
;	tv - view video of stamp through the quarter
;	ps - output ps file
;	pdf - output pdf file
;	kid - Kepler ID IF you just want one target
;	findsharp - remove changes from focus and drift
;	vlim - [v1,v2] start and end vector to use in cbv
;	igal0 - Do just the igal0 target in the skygroup
;	noplot - Don't show any plots

; Outputs
;	phothash - Hash of results
;	data - data in _targ .fits

; Return
;	Apphot - the light curve in both apsize and 1 step smaller apsize.
;			apphot = DBLARR(dims[2],2) + !values.d_nan 

COMMON flatcom,asym,flatness,mid,meanphot,findsharp0

IF ~KEYWORD_SET(kid) THEN kid=0 ELSE kid0 = kid
IF ~KEYWORD_SET(vlim) THEN vlim=[0,-1]
IF ~KEYWORD_SET(findsharp) THEN findsharp=0
if ~keyword_set(slope) then slope=0
findsharp0 = findsharp

IF ~KEYWORD_SET(fittime) THEN fittime=[0,-1]
IF ~KEYWORD_SET(ps) THEN ps = 0
IF ~KEYWORD_SET(pdf) THEN pdf = 0
IF ~KEYWORD_SET(tv) THEN tv = 0
IF ~KEYWORD_SET(close) THEN close = 0
IF ~KEYWORD_SET(noplot) THEN noplot = 0

; Check right directory
CD,current=pwd

 IF !version.os EQ "Win32" THEN $ 
      dir=(STRSPLIT(pwd,'\',/extract))[-1] $
 ELSE $
      dir=(STRSPLIT(pwd,'/',/extract))[-1] 
dir0 = STRING('Q',quarter,format='(A1,I02)')
IF (dir NE dir0) THEN BEGIN
	PRINT,'photaquarter: Wrong directory'
	STOP
ENDIF

;PRINT,'photaquarter: Photometry on quarter ',quarter,' skygroup ',skygroup
IF (kid NE 0) THEN PRINT,'photaquarter: Only K_ID: ',kid
graphic = OBJARR(10)
nperpage = 6
IF (ps EQ 1 OR pdf EQ 1) THEN  buffer = 1 
sgrp = STRTRIM(STRING(skygroup),1)
squarter = STRTRIM(STRING(quarter),1)

;; Create wget file to download targ files
;download_targs,gotable,quarter,quartersuffix  
;; Retrieve data for one quarter
; spawn,'chmod +x gettarg6'
; spawn,'gettarg6'
;; index for a particular quarter and skygroup
indQG=WHERE(gotable.skygroup_id EQ skygroup AND gotable.quarter EQ quarter) 
IF KEYWORD_SET(kid) THEN $
	indQG=WHERE(gotable.skygroup_id EQ skygroup AND gotable.quarter EQ quarter $
			and gotable.kepler_id EQ kid) 
IF (indQG[0] EQ -1 AND ~KEYWORD_SET(kid)) THEN BEGIN
	PRINT,'photaquarter: No galaxies in skygroup ',skygroup,' in quarter',quarter
	RETURN,0
ENDIF
IF ~KEYWORD_SET(kid) THEN kid0=gotable.kepler_id[indqg[0]]
channel=gotable.channel[indqg[0]]
data=read_localfits(kid0,/kepler,/compress)
IF ~ISA(data,/array) THEN RETURN,0

timslice=sxpar(data.targettables_1.header,'TIMSLICE')
timecorr = data.targettables_1.data.timecorr
time = DOUBLE(data.targettables_1.data.time)-timecorr+(0.25+0.52*(5.-timslice))/86400.

t1 = time[0]
t2 = time[-1]
;whfinite = WHERE(FINITE(time))
;iplot,time,time,/nodata,yrange=[.5,1.1]

igal1 = 0
igal2 = N_ELEMENTS(indQG)-1
IF KEYWORD_SET(igal0) THEN BEGIN
	igal1 = igal0-1
	igal2 = igal0-1
ENDIF

; Loop over galaxies in a skygroup in 1 quarter
FOR igal = igal1, igal2 DO BEGIN
   ; Choose a particular Kepler ID value
   IF ~KEYWORD_SET(kid) THEN kid0=gotable.kepler_id[indqg[igal]]
   ;print,'photaquarter: Kepler ID: ',kid0
   ;  Read in data for this galaxy
   data=read_localfits(kid0,/kepler,/compress)

   ; Uncomment to use raw_cnts
   ; flux = data.targettables_1.data.raw_cnts
   ;whbad=WHERE(flux LT -21000L)                
   ;flux = long(data.targettables_1.data.raw_cnts)  
   ;flux[whbad]= !VALUES.D_NAN

   flux = DOUBLE(data.targettables_1.data.flux)  
   ;flux = DOUBLE(flux)  
   kbkgnd = DOUBLE(data.targettables_1.data.flux_bkg)

   ;time = DOUBLE(data.targettables_1.data.time)
   nt = N_ELEMENTS(time)
   ; Fill in time with NaN values
   FOR i=0,nt-1 DO $
	   IF (FINITE(time[i],/nan)) THEN $
	   	time[i] = time[i-1]+0.020434289d0
   quality = data.targettables_1.data.quality
   whqualbad = WHERE(quality NE 0,nbad)
   flux[*,*,whqualbad] = !Values.d_nan
   kbkgnd[*,*,whqualbad]= !values.d_nan

   ;flux = flux + kbkgnd

   ;; Now do aperture photometery for this quarter
   dims = size(flux,/dimensions)
   mid0 = dims[2]/2.4
   mid=mid0
   getmid:
   REPEAT BEGIN
   	mid--
        fluxmid = flux[*,*,mid]
   ENDREP UNTIL (TOTAL(FINITE(fluxmid,/nan)) LT 2.5*dims[1]) 
   x1 = dims[0]/2
   y1 = dims[1]/2
   ; Find peak flux nearest to the center
   peak = peakup(fluxmid,x1,y1)
   ; IF failure try at a different timestep
   IF (peak[0] EQ -1) THEN peak = peakup(flux[*,*,dims[2]/3],x1,y1)

   aparr = [apsize-2,apsize]
   apphot = DBLARR(dims[2],2) + !values.d_nan
   bkgnd = DBLARR(dims[2],2) + !values.d_nan
   IF (apsize EQ 1) THEN fapl = 1 ELSE fapl = 0
   FOR apl = fapl, 1 DO BEGIN
	ipage = 0
	current = 0
   	apsize0 = aparr[apl]
	ap = (apsize0-1)/2
	npixels = apsize0^2
	sap = STRTRIM(STRING(apsize0),1)
   	IF (peak[0] EQ -1) THEN  GOTO,skipit
        ; Find peak pixel for an aperture in the middle of the quarter
          ; Define the aperture for photometry
   	left = (peak[0] - ap) > 0
   	right = (peak[0] + ap) < (dims[0] - 1)
   	bottom = (peak[1] - ap) > 0
   	top = (peak[1] + ap) < (dims[1] - 1)
	
	; Restrict number of nans within the aperture
	mid++
   	REPEAT BEGIN
   		mid--
        	apmid = flux[left:right,bottom:top,mid]
   	ENDREP UNTIL (TOTAL(FINITE(apmid,/nan)) LT 4) 
	fluxmid = flux[*,*,mid]
	whnansmid = WHERE(FINITE(apmid,/nan),nnans)
   	bindex = SORT(fluxmid+kbkgnd[*,*,mid])

   	; Look for column bias drifts
   	bias = 0
   	IF (bias EQ 1) THEN begin 
   		minRowValues = flux[*,0,mid]
	   	minRowTotal = TOTAL(minRowValues,/nan)
   		minrow = 0
   		IF ((WHERE(FINITE(minRowValues,/nan)))[0] NE -1 ) THEN $
			minrowTotal = 1e20
   		FOR row = 1, dims[1]-1 DO BEGIN
			   rowValues = flux[*,row,mid]
			   rowTotal = TOTAL(rowValues,/nan)
       		    IF ((WHERE(FINITE(rowValues,/nan)))[0] NE -1 ) THEN rowTotal = 1e20
			   IF rowTotal LT minRowTotal THEN BEGIN
				   minRowTotal = rowTotal
				   minRow = row
				   minRowValues = rowValues
			   ENDIF
   		ENDFOR
   		coldev = DBLARR(dims[0],dims[2])
   		; Subtract mid rowValues from all other timesteps
   		FOR k = 0,dims[2]-1 DO coldev[*,k] = flux[*,minRow,k]-minRowValues
   		FOR col = 0, dims[0] - 1 DO BEGIN
   		   ; Smooth each column
		   coldev[col,*] = SMOOTH(coldev[col,*],24,/nan)
		   ; remove coldev from each column at each time step
		   FOR k = 0, dims[2]-1 DO $
			   flux[col,*,k] = flux[col,*,k] - coldev[col,k]
    		ENDFOR
    	ENDIF
    
	   
   	;bkgndmid = fluxmid[bindex[1:1]]
   	;flux = flux - bkgndmid[0]

        sharpindxx = [peak[0]  ,peak[0]+1,peak[0]  ,peak[0]-1]
        sharpindxy = [peak[1]-1,peak[1]  ,peak[1]+1,peak[1]  ]
        sharpmid = fluxmid[peak[0],peak[1]]/TOTAL(fluxmid[sharpindxx,sharpindxy])
        sharp =DBLARR(dims[2])
        asym=DBLARR(dims[2])
        ; Loop over exposures in quarter
        FOR k = 0,dims[2]-1 DO BEGIN
	   flux1 = flux[*,*,k]
	   aperture = flux1[left:right,bottom:top]
	   whnans = WHERE(FINITE(aperture,/nan),nnans)
	   apphot[k,apl] = TOTAL(aperture,/nan)
	   bkgnd[k,apl] = MEAN(flux1[bindex[1:5]],/nan)
	   IF (nnans GT 2) THEN quality[k] = 9
	   IF (quality[k] NE 0) THEN BEGIN
		   apphot[k,apl] = !values.d_nan
		   bkgnd[k,apl] = !values.d_nan
	   ENDIF
;	   IF (apl EQ 1 AND k EQ 2567) THEN stop
;	   IF (apl EQ 1 AND apphot[k,apl] LT 500d0) THEN  stop
	   IF (apl EQ 1) THEN BEGIN
	   	asymx = flux1[peak[0]-1,peak[1]]-flux1[peak[0]+1,peak[1]]
		asymx = asymx/TOTAL(flux1[peak[0]-1:peak[0]+1,peak[1]])
	   	asymy = flux1[peak[0],peak[1]-1]-flux1[peak[0],peak[1]+1]
		asymy = asymy/TOTAL(flux1[peak[0],peak[1]-1:peak[1]+1])
	   	asym[k] = SQRT(asymx^2+asymy^2)
   	   ENDIF
           IF ~ARRAY_EQUAL(whnans,whnansmid) THEN apphot[k,apl]=!values.d_nan	
   	ENDFOR ; end loop over exposures
   
;        apphot[*,apl] = apphot[*,apl] - TOTAL(FINITE(aperture))*SMOOTH(bkgnd[*,apl],24,/nan,/edge_mirror,missing=!values.d_nan)

;	Use slope parameter to adjust for secular sensitivity loss
;	slope = 1 provides loss of 1 percent loss per year
	sen = 1d0 + (time-1460.)*slope/3.65d2/1d2
	apphot[*,apl] *= sen

	
	phot1 = apphot[*,apl]
;;	IF (quarter EQ 15) THEN BEGIN
	IF (quarter EQ 29) THEN BEGIN
		PRINT,'Warning:  stitching day 845'
		tsplit =845
		aa = phot1[WHERE(time LT tsplit)]
		atime = time[WHERE(time LT tsplit)]
		bb = phot1[WHERE(time GE tsplit)]
		btime = time[WHERE(time GE tsplit)]
		delta = 20.*48.
		stitch,aa,bb,atime,btime,delta,cc & phot1 = [aa,cc]
	ENDIF
	IF (quarter EQ 11) THEN BEGIN
		tsplit = 1035.25d0
		aa = phot1[WHERE(time LT tsplit)]
		atime = time[WHERE(time LT tsplit)]
		bb = phot1[WHERE(time GE tsplit)]
		btime = time[WHERE(time GE tsplit)]
		bb2 = bb[0:48*5]
		delta = 2.5*48.
		stitch,aa,bb,atime,btime,delta,cc & phot1 = [aa,cc]
	ENDIF

	IF (quarter EQ 115) THEN BEGIN
		tsplit = 1413d0
		tsplit2 = 1418d0
		PRINT,'Warning:  stitching day '+STRING(LONG(tsplit))
		wha = WHERE(time LT tsplit)
		whb = WHERE(time GT tsplit2)
		aa = phot1[wha]
		atime = time[wha]
		bb = phot1[whb]
		btime = time[whb]
		bb2 = phot1[wha[-1]+1:whb[0]-1]
		delta = 30.*48.
		stitch,aa,bb,atime,btime,delta,cc & phot1 = [aa,bb2,cc]
	ENDIF
	delta = 4*48
	IF (quarter EQ 27) THEN BEGIN
		aa = phot1[WHERE(time LT 1583)]
		atime = time[WHERE(time LT 1583)]
		bb = phot1[WHERE(time GE 1583)]
		btime = time[WHERE(time GE 1583)]
		stitch,aa,bb,atime,btime,delta,cc & phot1 = [aa,cc]
	ENDIF
   	apphot[*,apl] = phot1

	IF apl EQ 0 THEN CONTINUE

;	; Use Cotrending Basis Vectors
;	IF KEYWORD_SET(vlim) THEN BEGIN
;   		IF (quarter EQ 11 AND kid0 EQ 3111451L) THEN vlim=[2,4]
;   		phot1 = cbv(kid,apsize,quarter,channel,phot1,time,vlim,findsharp)
;;   	   	phot1 *=  cps/MEAN(phot1,/nan)
;	ENDIF

	asym = SMOOTH(asym,5*48,/nan,/edge_mirror,missing=!values.d_nan)
	f3f5 = apphot[*,0]/apphot[*,1]
	f3f5 = SMOOTH(f3f5,5*48,/nan,/edge_mirror,missing=!values.d_nan)
	f3f5[WHERE(quality NE 0)] =  !values.d_nan
	flatness = 1d0 - f3f5
	cut = 40e0
	cps = MEAN(phot1,/nan)
;	IF findsharp THEN BEGIN
;	    IF (apsize ne 1) THEN  BEGIN
;		mid1 = mid
;	   	sharpc = 0.0e0
;	   	asymc = 0.0e0
;		p = [asymc,sharpc]
;		xi = transpose([[0.1, 0.0],[0.0, 0.1]])
;		ftol = 1.0e-4
;		; Minimize the function
;	   	POWELL, p,xi, ftol,fmin,'sharpfunc'
;	   	sharpc = p[1] & asymc = p[0]
		; Restrict sharpc to -cut to cut
;	        IF (abs(sharpc) GT cut) THEN sharpc = cut*signum(sharpc)
;	   	PRINT, 'photaquarter: Solution sharpc, asymc ',sharpc,asymc
;  	   	phot1 *= (1e0+asym*asymc)*(1e0+flatness*sharpc)
;   	   	phot1 *=  cps/MEAN(phot1,/nan)
;	    ENDIF
;        ENDIF

	; Use Cotrending Basis Vectors
	IF vlim[0] NE 0 || findsharp EQ 1 THEN BEGIN
   		;IF (quarter EQ 11 AND kid0 EQ 3111451L) THEN vlim=[2,4]
		IF (fittime[1] GT time[0] AND fittime[0] LT time[-1]) THEN BEGIN
			t0 = WHERE(time GT fittime[0], nt0)
			IF nt0 GT 0 THEN BEGIN
				fitt0 = t0[0]
				fitt1 = WHERE(time GT fittime[1], nt1)
				IF nt1 GT 0 THEN BEGIN
					fitt1 = fitt1[0]
				ENDIF ELSE BEGIN
					fitt1 = nt - 1
				ENDELSE
			ENDIF ELSE BEGIN
				PRINT, 'photaquarter: No t0', fittime[0]
				STOP
			ENDELSE
		ENDIF ELSE BEGIN
			fitt0 = 0
			fitt1 =  nt-1
		ENDELSE
		meanphot = MEAN(phot1,/nan)
		vlim0 = vlim
		;IF (kid EQ 12556836) THEN BEGIN
		;	PRINT,'photaquarter: Warning special code for 12556836'
		;	IF quarter EQ 11 THEN vlim0 = [1,1]
		;	IF quarter EQ 13 THEN vlim0 = [1,1]
		;ENDIF
   		phot1 = cbv(kid,apsize,quarter,channel,phot1,time,vlim0,fitt0,fitt1)
   	   	phot1 *=  cps/MEAN(phot1,/nan)
	ENDIF

   	apphot[*,apl] = phot1

	smbkgnd = SMOOTH(bkgnd[*,1],48,/nan,/edge_mirror,missing=!values.d_nan)
	IF (apl EQ 1) THEN PRINT,'photaquarter: KID: ',kid0,' CPS: ',cps,' Skygroup ',sgrp,' Quarter ',squarter

	skipit:
	; prepare  phothash
	IF KEYWORD_SET(phothash) THEN BEGIN
		; IF this quarter is not in phothash add quarter
		IF ~phothash.HasKey(quarter) THEN BEGIN
			 phothash += HASH(quarter,HASH(skygroup,HASH(kid0,HASH(apsize0)))) 
		ENDIF ELSE BEGIN
		       IF ~ISA(phothash[quarter],'HASH') THEN BEGIN
			   phothash[quarter] = HASH(skygroup,HASH(kid0,HASH(apsize0)))
		       ENDIF ELSE BEGIN
			   ; IF skygroup is not in phothash add skygroup
			   IF ~phothash[quarter].HasKey(skygroup) THEN BEGIN
			       phothash[quarter] += HASH(skygroup,HASH(kid0,HASH(apsize0)))
			   ENDIF ELSE BEGIN
			       ; IF skygroup but not this galaxy
			       IF ~phothash[quarter,skygroup].HasKey(kid0) THEN $
				      phothash[quarter,skygroup] += HASH(kid0,HASH(apsize0))
			    ENDELSE
			ENDELSE
		ENDELSE
		;Add info on this apsize0.  Blow away any previous info at this apsize0. 
	        phothash[quarter,skygroup,kid0] += $
			HASH(apsize0,HASH('phot',apphot[*,apl],'bkgnd',$
			REFORM(kbkgnd[peak[0],peak[1],*]),'time',time,'peak',peak,$
			'asym',asym,'f3f5',f3f5)) 
	ENDIF ; end phothash


	IF (noplot EQ 0) THEN BEGIN
		; Create Plots
		current = 1
		IF (igal MOD nperpage) EQ 0 THEN BEGIN
			current = 0 
			graph = graphic[ipage]
			ipage++
		ENDIF
		IF (((igal MOD nperpage) EQ nperpage -1) OR (igal EQ igal2)) THEN showtext = 1 ELSE showtext = 0
		xtitle = 'Days'
		graphic[ipage] = PLOT(time,apphot[*,apl]/cps, $
			axis_style = 1, $
			layout=[1,nperpage,igal+1], $
			xshowtext = showtext, $
			buffer = buffer, $
			symbol='dot', $
			linestyle='none', $
			title='id: '+STRTRIM(STRING(kid0),1) $
			+ ',  cps: '+STRTRIM(STRING(cps,format='(f10.2)'),1) $
			+ ', Channel: '+STRTRIM(STRING(channel),1) $
			+ ', Skygroup: '+sgrp $
			+ ', Quarter: '+squarter $
			+ ', Ap: '+sap, $
				font_size=10, $
			   window_title='channel: '+STRTRIM(STRING(channel),1) $
				+', skygroup: '+sgrp, $
			   margin=[.10,.25,.10,.15], $
			   current=current, $
			   xtitle = xtitle, $
			   xrange=[t1-5,t2+5], $
			   yrange=[0.97,1.03])
		
	        graphic[ipage] = PLOT(time,apphot[*,1]/cps,/overplot,color=!color.red)    
	        itext,642,.85,/data 

		spage = STRTRIM(STRING(ipage+1),1)
		IF (ps EQ 1 AND igal2 ne -1) THEN BEGIN
			IF ((igal MOD nperpage EQ nperpage-1) OR (igal EQ igal2)) THEN BEGIN
				graphic[ipage].save,'graphs/q'+squarter+'g'+sgrp+'a'+sap+'p'+$
			spage+'.eps',border=10,resolution=300
	ENDIF
		ENDIF
		IF (pdf EQ 1 AND igal2 NE -1) THEN BEGIN
			IF ((igal MOD nperpage EQ nperpage-1) OR (igal EQ igal)) THEN $
		             graphic[ipage].save,'graphs/q'+squarter+'a'+sap+'.pdf',resolution=300,ymargin=1,/append,page_size="letter"
		ENDIF
		;WSET,3
		;cut=1.5
		;whsh= WHERE(sharp LT cut,/null)
	ENDIF ; end noplot
	IF KEYWORD_SET(tv) THEN BEGIN
			; Show stamp at end minus at beginning
			WSET,0

			midflux=flux[*,*,mid]
			cflux=flux[peak[0],peak[1],mid]
			WSET,1
			PLOT,midflux[*,1]-midflux[*,1],yrange=[-15,15]
			FOR k = 14*48, dims[2]-50,30 DO BEGIN
			  ; img0=flux[*,*,k]- flux[*,*,k-14*48]
;			   img0=TOTAL(flux[*,*,k:k+24],3)/25d0- midflux
			   img0=TOTAL(flux[*,*,k:k+24],3)/25d0
;			img0 = img0 - MIN(img0,/nan)
			   WSET,0
			   imin = MIN(img0,/nan)
			   cflux=flux[peak[0],peak[1],k]
			   IF FINITE(imin) THEN tv1,img0,imin-cflux*.2e0,cflux*2e0
			   WAIT,.1
			   WSET,1
			   OPLOT,TOTAL(flux[*,dims[1]-1,k:k+48],3)/49d0 - midflux[*,dims[1]-1],psym=10
			ENDFOR
			; Show stamp at end
			WSET,1
			img0=TOTAL(flux[*,*,dims[2]-15:dims[2]-5],3,/DOUBLE,/nan)/10d0
			tv1,img0,-30,MAX(img0)*2d0
			; Show stamp at beginning
			WSET,2
			k=5
			img1=TOTAL(flux[*,*,k:k+10],3,/DOUBLE,/nan)/10d0
			tv1,img1,-30,MAX(img0)*2d0
;			graph = PLOT(img1[peak[0],*],xtitle='pixels',ytitle='Counts',color=!color.red,thick=2,$
;				title='PSF in Quarter '+squarter+', K_id: '+STRTRIM(STRING(kid0),2))
			;FOR k=485, dims[2]-15,480 DO BEGIN
			;	img=TOTAL(flux[*,*,k:k+10],3,/DOUBLE,/nan)/10d0
			;	wait,1.
			;	graph = PLOT(/overplot,img[peak[0],*])
			;ENDFOR
			;graph = PLOT(/overplot,img[peak[0],*],color=!color.blue,thick=2)
			;graph.save,'graphs/psf_q'+squarter+'_'+STRTRIM(STRING(kid0),2)+'.eps'
	ENDIF ; end if tv
   ENDFOR ;End loop over aperture size
ENDFOR ;end loop over galaxy igal
RETURN,apphot
END
