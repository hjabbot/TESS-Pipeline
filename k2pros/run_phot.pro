FUNCTION lcfit,pfind
COMMON lcfit1_com,tvector,raw3,time,pca3,npca,xc0,yc0,delt,whquiet,whnoquiet,repos,res,nomedian,p2,coeff2
COMMON lcfitp0_com,fullp,res_p,smphotn
;  This is called by powell or amoeba by run_phot.pro (below) to find coefficients 

nnt = N_ELEMENTS(time)

; npsaw = Number of sawtooth coefficients 
npsaw = 7
xc = xc0 - pfind[2] MOD 3
yc = yc0 - pfind[3] MOD 3
f1 = 1d0 - pfind[0]*xc - pfind[1]*yc $ 
	+ pfind[4]*xc^2 + pfind[5]*yc^2 + pfind[6]*xc*yc 

;f1 = f1/MEAN(f1,/nan)

; For f2 as an additive factor
;f2 = DBLARR(nnt) 
; For f2 as a multiplicative factor
f2 = DBLARR(nnt) + 1d0 
IF N_ELEMENTS(pfind) GT npsaw THEN BEGIN
	FOR i = 0, npca-1 DO f2 = f2 + pfind[i+npsaw]*pca3[i,*] 
ENDIF ELSE BEGIN 
     IF N_ELEMENTS(fullp) GT npsaw THEN BEGIN
	FOR i = 0, npca-1 DO f2 = f2 + fullp[i+npsaw]*pca3[i,*] 
     ENDIF ELSE f2 = 1.0  ; f2 = 0.0 for additive here
ENDELSE

; Find 3 sigma deviations from nearest 25 points
; This provides remaining from start to t2
; For f2 as a multiplicative factor
photplt = raw3/(f1 * f2)
; For f2 as an additive factor
;photplt = raw3/(f1 - f2)

;Just for C12 channel 82
; photplt[1487:1598] = !VALUES.D_NAN

phot = photplt[whquiet]

IF (N_ELEMENTS(pfind) NE  npsaw) THEN BEGIN

	; Ensure that after corrections the flux is close to a constant value
	; Try keeping max flux in LC as the constant
	;remain = phot/MAX(raw3[whquiet]- f2[whquiet],/nan) - 1d0

	remain = phot - 1d0

	; delt tries to fix last few datapoints to something other than 1.0
	enddays = 2.0
	smwide2 = 24
	; mn3 is mean for time without SN (before t2 or after t3).
	mn3 = MEAN(phot,/nan)
	; Raise edge of light curve by delt
	; If t2 is set then this should raise final few data points
	; If t3 is set then this should raise first few  data points
	; Do not use with both t2 and t3 set
	;stop
	IF (delt NE 0) AND (delt NE -1) THEN BEGIN
		IF whquiet[0] LT 500 THEN $
			edge = photplt[-48*enddays:-1] $
		ELSE $
			edge = photplt[0:48*enddays]
		remain = [remain, (edge - (delt*mn3))] 
	ENDIF

	;If delt == -1 then also try to minimize lc-smooth(lc) variations beyond t2
	IF delt EQ -1  THEN BEGIN
		last = whquiet[-1]
		IF last GE nnt-1 THEN BEGIN
	   	remain = remain - SMOOTH(remain,smwide2,/edge_truncate) 
		ENDIF ELSE BEGIN
			wht = whquiet[-1]+1
			;remain2 = raw3[wht:*]/f1[wht:*] - f2[wht:*] 
			remain2 = raw3[wht:*]/(f1[wht:*] * f2[wht:*] )
	        	remain2 = remain2 - SMOOTH(remain2,smwide2,/edge_truncate) 
	        	remain = [remain,remain2] 
		ENDELSE
	ENDIF
	;;wt = REVERSE(DINDGEN(N_ELEMENTS(remain)))
        ;;remain = remain*SQRT(wt+1d0)

ENDIF ELSE BEGIN
	; If just looking for sawtooth solution and have no cbv vectors, 
	; then subtract smoothed light curve first.
	; WARNING this kills solution for pfull
	; Here we insure that after sawtooth correction it is smooth
	; But not necessarily a constant
	phot1 = raw3[whquiet]/f1[whquiet] 
	sm = smphotn[whquiet]
	; In case one wants to keep f1 < 1.  That is,
	; assume max  of phot1 is when target is centered best and
	; any movement from there causes a reduction in flux
	;diff = raw3[whquiet] -  sm[whquiet]
	;remain = phot1/(1d0 + MAX(diff)) -  sm[whquiet]

	remain = phot1 -  sm

	; Debugging stuff
	debug = 0
	;if res LT 3.4E-04 then debug=1
	IF debug THEN BEGIN
	   res=MEAN(remain^2,/double,/nan)
	   wins = GETWINDOWS()
	   win = wins[-1]
	   win.erase
	   win.show
	   photplt = raw3/f1
	   p=PLOT(/current,time[whquiet],phot1,symbol='dot',linestyle='',$
		   sym_thick=2,color='black')
	  ; p=PLOT(/overplot,time,f1,symbol='dot',linestyle='')
	   p=PLOT(/overplot,time[whquiet],sm,symbol='dot',linestyle='',$
		   sym_thick=2,color='green')
	   p=PLOT(/overplot,time[whquiet],raw3[whquiet],symbol='dot',$
		   sym_thick=2,linestyle='',color='blue')
	   p=PLOT(/overplot,time[whquiet],remain,symbol='dot',$
		   sym_thick=2,linestyle='')
	   print,'res = ',res
	   PRINT,format='(7F12.5)',pfind
	   WAIT,.5
	ENDIF

	;IF (res LT .31) THEN STOP

ENDELSE

;res=TOTAL(remain[4:-5]^2,/nan)
res=MEAN(remain^2,/double,/nan)

;	wins = GETWINDOWS()
;	win = wins[-1]
;	win.erase
;	p=PLOT(/current,time,1.0+raw3,yrange=[.95,1.1],symbol='dot',linestyle='',color='blue')
;	p=PLOT(/current,/overplot,time,1+photplt,symbol='dot',linestyle='')
;	p=PLOT(/current,/overplot,time[whquiet],1+SMOOTH(raw3[whquiet],48,/edge_truncate,/nan) ,symbol='dot',linestyle='',color='red')
;	p=PLOT(/current,/overplot,time[whquiet],1d0+remain,symbol='square',sym_size=.2,linestyle='',color='green')
;	;p=PLOT(/current,/overplot,time,f2,symbol='square',sym_size=.2,linestyle='',color='blue')
;	p=PLOT(/current,/overplot,time,f1,symbol='square',sym_size=.2,linestyle='',color='brown')
;	PRINT,res,pfind
;	;IF pfind[6] NE 0 THEN STOP

RETURN,res
END


FUNCTION run_phot,campaign,nearby,npca,apsize=apsize,mask=mask,k2data=k2data,ccd=ccd,$
	kids=kids,pstep=pstep,rawphots=rawphots,araw=araw,write=write,$
	noplot=noplot,bin=bin,pcavec=pcavec, just_pca=just_pca,$
	saveplt=saveplt,phots_pca=phots_pca,sum=sum,centroids=centroids,$
	func=func,t0=t0,t2=t2,t3=t3,tfinal=tfinal,delt0=delt0,minflux=minflux,$
	yrange=yrange,peak=peak,pend=pend,buffer=buffer,addnans=addnans,$
	quicklook=quicklook,title=title

COMMON lcfit1_com,tvector,raw3,time3,pca3,npca3,xc03,yc03,delt,whquiet,whnoquiet,repos,res,nomedian,p2,coeff2
COMMON lcfitp0_com,fullp,res_p,smphotn

CD, !workdir
first_rb = 15
res_p= 0
debug = 0
; Photometry on a set of targets 

; pstep - 0 - just aperture photometry
;         1  - remove fit of ccd median ltor
;         2 - remove fit to xcenter,ycenter motion

IF N_PARAMS() EQ 0 THEN BEGIN
        PRINT,'usage: phots = run_phot(campaign,nearby,npca,apsize=apsize,mask=mask,k2data=k2data,ccd=ccd,'
	PRINT,' kids=kids,pstep=pstep,noplot=noplot,bin=bin,pcavec=pcavec,just_pca=just_pca,$'
	PRINT,'saveplt=saveplt,phots_pca=phots_pca,rawphots=rawphots,sum=sum,araw=araw,$'
	PRINT,'centroids=centroids,write=write,t0=t0,t2=t2,t3=t3,yrange=yrange,peak=peak,$'
	PRINT,'pend=pend,buffer=buffer,delt0=delt0,minflux=minflux'
	RETURN,0
ENDIF

; Set default values
IF ~KEYWORD_SET(bin) THEN bin = 1
IF ~KEYWORD_SET(quicklook) THEN quicklook = 0
IF ~KEYWORD_SET(minflux) THEN minflux = 1.1
IF ~KEYWORD_SET(buffer) THEN buffer = 0
IF ~KEYWORD_SET(noplot) THEN noplot=0
IF ~KEYWORD_SET(pend) THEN pend = 0
IF ~KEYWORD_SET(pstep) THEN pstep = 0
IF ~KEYWORD_SET(delt0) THEN delt0 = 0
IF ~KEYWORD_SET(title) THEN title = '' 
; To skip faint galaxies when deriving pca vectors set just_pca=1
IF ~KEYWORD_SET(just_pca) THEN just_pca = 0
IF ~KEYWORD_SET(saveplt) THEN saveplt = 0
IF ~KEYWORD_SET(araw) THEN have_raw = 0 ELSE have_raw = 1
IF ~KEYWORD_SET(addnans) THEN addnans = []
IF ~KEYWORD_SET(t2) THEN t2 = 0
IF ~KEYWORD_SET(t3) THEN t3 = 0
IF ~KEYWORD_SET(yrange) THEN yrange0=[.90,1.10] ELSE yrange0=yrange
;if quicklook then yrange0 = 0
IF ~KEYWORD_SET(write) THEN write = 0
IF ~KEYWORD_SET(peak) THEN peak = 0 
; func can be 'lcfit' or 'lcfitpiece'
IF ~KEYWORD_SET(func) THEN func='lcfit'

npca0 = npca
pend0 = pend

dum=''
IF N_ELEMENTS(kids) EQ 1 THEN BEGIN
	help,kids,t0,t2,t3,tfinal,delt0,npca,minflux,quicklook,write
	print,'peak: ',peak
	READ,'Continue? [y,n]:',dum
	if (dum eq 'n') then return,0
ENDIF
; Set mode0 for where in time to minimize for coefficients
; All time
IF (t2 EQ 0 AND t3 EQ 0) then mode0 = 0
; Just at the beginning
IF (t2 NE 0 AND t3 EQ 0) then mode0 = 1
; Just at the end
IF (t2 EQ 0 AND t3 NE 0) then mode0 = 2
; Both at beginning and end
IF (t2 NE 0 AND t3 NE 0) then mode0 = 3


; yrange1 is range for multiple plots on one page made by runk2
yrange1 = [0.95,1.05]

; Setup some strings for labels etc
scamp = STRTRIM(STRING(campaign),2)
snpca = STRING(npca,format='(I1)')
; Setup CBV vectors
sbin = STRTRIM(STRING(bin),2)
IF bin EQ 1 THEN sbin='0'

; If have averaged centroids for each ccd then set have_centroids
; If not passed in, then restore centroids from saveset
IF ~KEYWORD_SET(centroids) THEN BEGIN
	cenfile = 'Campaign'+scamp+'/centroids.sav'
	test1 = FILE_SEARCH(cenfile,count=count)
	IF count NE 0 THEN BEGIN
		RESTORE,cenfile
		have_centroids = 1
	ENDIF ELSE have_centroids = 0
ENDIF ELSE have_centroids = 1
	
IF KEYWORD_SET(apsize) AND KEYWORD_SET(mask) THEN BEGIN
	PRINT,'run_phot: Can not set both apsize and mask'
	RETURN,0
ENDIF

ap = apsize
IF ~KEYWORD_SET(apsize) AND ~KEYWORD_SET(mask) THEN BEGIN
	PRINT,'run_phot: No apsize set, using mymask()'
	mask = mymask()
ENDIF
; If using mask then we set ap=4 mostly for file names. 
;IF KEYWORD_SET(mask) THEN ap = 4
IF KEYWORD_SET(mask) THEN ap = 5
apstr = STRTRIM(STRING(ap),2)

; Read campaign data k2data, if it was not passed in.
IF ~KEYWORD_SET(k2data) THEN  RESTORE,'Campaign'+scamp+nearby+'/k2data.sav'

; Check that we have not set both kids and ccd
nways = 0
IF KEYWORD_SET(kids) THEN nways++
IF KEYWORD_SET(ccd) THEN nways++
IF nways GT 1 THEN BEGIN
	PRINT,'run_phot: Set just 1 of kids or ccd'
	RETURN,0
ENDIF

; If rawphots not passed in, initialize as a hash list.
IF ~KEYWORD_SET(rawphots) THEN BEGIN
	rawphots = ORDEREDHASH()
	rawphots['ccd'] = 0
	rawphots['apsize'] = 0
ENDIF

; plot layout params
plotdir = 'Campaign'+scamp+nearby+'/plots/'
lx = 3
ly = 9
; margin is [left,right,top,bottom] margin
margin=[.1,.1,.05,.1]
pos = eslayout(margin,lx,ly)

; GET LIST IF KIDS TO DO
; If ccd is set then do all of our targets on that ccd
; Else we get ccd from the first target in kids
IF KEYWORD_SET(ccd) THEN BEGIN
	set = WHERE(k2data.channel EQ ccd, nkids)
	IF nkids EQ 0 THEN BEGIN
		PRINT,'run_phot: No targs on ccd ',ccd
		RETURN,-1
	ENDIF ELSE kids = k2data[set].k2_id
	IF rawphots['ccd'] NE ccd OR rawphots['apsize'] NE apsize THEN BEGIN
		rawphots = HASH()
		rawphots['ccd'] = 0
		rawphots['apsize'] = 0
	ENDIF
ENDIF ELSE BEGIN
	nkids = N_ELEMENTS(kids)
	i0 = WHERE(k2data.k2_id EQ kids[0],nkids3)
	IF (nkids3 EQ 0) THEN BEGIN
		PRINT, 'First target is not in k2data', kids[0]
		RETURN,0
	ENDIF
	ccd = k2data[i0[0]].channel
	; Figure out where it is in the list of k2data with this channel
ENDELSE
sccd = STRING(ccd,format='(I02)')

have_rawphots = 0
; If ccd and apsize in rawphots are correct then have_rawphots is set to 1
IF rawphots['ccd'] EQ ccd AND rawphots['apsize'] EQ apsize THEN BEGIN
	have_rawphots = 1
ENDIF ELSE BEGIN
	rawphots['ccd'] = ccd
	rawphots['apsize'] = apsize
ENDELSE

; If CBVs were not passed in then try to read them in.
IF ~KEYWORD_SET(pcavec) THEN BEGIN
	if sbin ne 0 then  $
		cbvfile = 'Campaign'+scamp+'/pca/cbv_ap'+apstr+'_rebin'+sbin+$
		'_ccd'+sccd+'.sav' $
	else $
		cbvfile = 'Campaign'+scamp+'/pca/cbv_ap'+apstr+$
		'_ccd'+sccd+'.sav' 
	test0 = FILE_SEARCH(cbvfile,count=count)
	IF count NE 0 THEN BEGIN
		RESTORE,cbvfile 
		pcavec = cbv
		; For KSN2015H
		;IF kids[0] EQ 211845655 THEN BEGIN
		;	pcavec[4,*] = cbv[3,*]
		;	pcavec[3,*] = cbv[4,*]
		;ENDIF

	ENDIF ELSE BEGIN
		; If no pca vectors then STOP, unless npca=0
		IF npca NE 0 THEN BEGIN
			PRINT,'run_phot:  No CBV File:', cbvfile
			RETURN,0
		ENDIF
		pcavec = 0
	ENDELSE
ENDIF
pca0 = pcavec

; Do photometry
ccd_old = 0
place = 1
IF buffer THEN current = 0 ELSE current = 1
np = 1

gal = {kid: 0L, mean: 0., stddev: [0d0,0d0,0d0,0d0], coeffs: [0d0,0d0,0d0,0d0,0d0,0d0]}
gals = REPLICATE(gal,nkids)

xcs = 0
ycs = 0
nn = 1
phots = []
phots_pca = []
xcmax = 300
ycmax = 300

; READ llc file for pdc and sap flux, and time array
; Call read_k2llc
if ~quicklook then $
	pdc_flux=read_k2llc(kids[0],campaign,time,xc,yc,sap_flux,data=llcdata)  $
else $
       k2cube = read_k2targ(kids[0],campaign,time,quality,flux_bkg,apmask) 
; t0 sets earliest time to consider before explosion in LCFIT
IF ~KEYWORD_SET(t0) THEN t0 = time[0]
IF ~KEYWORD_SET(tfinal) THEN tfinal = time[-1]
;IF t3 EQ 0 THEN t3 = tfinal 

; mincounts sets the flux required to be used in PCA.
mincounts = 1000d0*DOUBLE(ap)/5d0
IF t2 NE 0 THEN st2 = STRING(t2,format='(f6.1)')
IF (mode0 EQ 2) THEN st3 = STRING(t3,format='(f6.1)')
maxjitter = 0.1

; Setup up windows for plots
IF ~buffer THEN BEGIN
	havewin2 = 0
	havewin3 = 0
    	wins = GETWINDOWS()
	nwins = N_ELEMENTS(wins)
	IF nwins GT 0 THEN BEGIN
	    FOREACH win2, wins DO BEGIN
		IF win2.window_title EQ 'Individual Target' THEN BEGIN
			havewin2 = 1
			BREAK
		ENDIF
	    ENDFOREACH
	    FOREACH win3, wins DO BEGIN
		IF win3.window_title EQ 'Test' THEN BEGIN
			havewin3 = 1
			BREAK
		ENDIF
	    ENDFOREACH
	ENDIF
	IF ~havewin2 THEN $
		win2 = WINDOW(window_title='Individual Target', dimensions=[768,512])
	IF ~havewin3 THEN $
		win3 = WINDOW(window_title='Test',dimensions=[512,512])
ENDIF
; List of targets to exclude from PCA analysis (AGNs, SN, etc)
; Best peak values for problem kids are here as well
nodo = nodo_list(campaign,peakhash,undoable)		

igal = 0
rawphots('time') = time
FOREACH kid, kids DO BEGIN
	PRINT,'Apsize = ',apsize
	IF debug then PRINT,'debug run_phot - new kid'
	whereundo = WHERE(undoable EQ kid, nundo)
	IF nundo NE 0 THEN BEGIN
		PRINT,'run_phot: ',kid+' not doable.'
		CONTINUE
	ENDIF
	peak0 = peak
	npca = npca0
	pend = pend0
	delt = delt0

	; Get peak for problem galaxies
	IF peakhash.haskey(kid) THEN peak0 = peakhash[kid]

	IF campaign EQ 5 THEN BEGIN
		IF kid EQ 211358204 AND npca0 NE 0 THEN npca=1 
		IF kid EQ 211826271 AND npca0 NE 0 THEN npca=1 
	ENDIF

	PRINT,'run_phot:  npca = ', npca
	IF (campaign NE 1 AND kid NE kids[0] AND ~quicklook) THEN $
		     pdc_flux=read_k2llc(kid,campaign,time,xc,yc,sap_flux,data=llcdata) 
	IF nkids GT 1 THEN gals[igal].kid = kid
	skid = STRING(kid,format='(i9)')
	title0 = 'EPIC '+skid
	IF title NE '' THEN title0 = title+' = ' + title0
	PRINT,''
	PRINT,'run_phot: Kid = ',skid,' on ccd ',ccd,', ',nn++,'/',nkids,', ',$
		SYSTIME(),format='(a16,a9,a9,i3,a2,i3,a1,i3,a2,a)'

	; Read in target pixel data or use araw or use rawphots
	; raw LC is just called raw
	IF ~have_rawphots OR peak0[0] NE 0  OR  ~rawphots.HasKey(kid) THEN BEGIN

	   ; Run photometry program
	   IF ~have_raw OR peak0[0] NE 0 OR ~rawphots.hasKey(kid) THEN BEGIN
		   ; Get targdata either way
		IF write NE 2 THEN $
	   	    raw = phot_k2targ(campaign,kid,sum,apsize=apsize,mask=mask,$
		   	k2data=k2data,time=time,noplot=1,peak=peak0,$
			quicklook=quicklook,bkg=bkg,sky=sky,data=targdata)  $
		ELSE $
	   	    raw = phot_k2targ(campaign,kid,sum,apsize=apsize,mask=mask,$
		   	k2data=k2data,time=time,noplot=1,peak=peak0,apmask=apmask,$
			data=targdata,bkg=bkg,sky=sky,quicklook=quicklook)  
		; Get info from RB_LEVELS data in targdata
		tags = GET_TAGS(targdata.targettables.data)
		wh = where(tags eq '.RB_LEVEL',rbpresent)
		if (rbpresent EQ 1) then begin
			rb_level=targdata.targettables.data.rb_level
			rbs = reform(max(rb_level[2,2:-2,*],dim=2) GT 1.5)
			whrb = WHERE(rbs,/null,nrb)
			; rbs info is store in rawphots
	        	rawphots[kid*5L] = rbs
		endif else nrb = 0

	        rawphots[kid] = raw
	        rawphots[kid*10L] = bkg
	        rawphots[kid*3L] = sky
		rawphots[skid+'peak'] = peak0
		IF campaign EQ 3 THEN BEGIN
			; Remove asteroid
			IF (kid EQ 206315676) THEN $
				raw[134:180] = !VALUES.D_NAN
		ENDIF
		araw = raw
	   ENDIF ELSE raw = araw ;skip photometry and use araw
        ENDIF ELSE BEGIN
		raw = rawphots[kid] ; skip photometry and use rawphots
		bkg = rawphots[kid*10L] ; store bkg in rawphots  hash
		sky = rawphots[kid*3L] ; store bkg in rawphots  hash
		print,format='(a,i2,",",i2)','run_phot: Peak from rawphots: ',rawphots[skid+'peak']
		if rawphots.hasKey(kid*5L) then begin
		   rbs = rawphots[kid*5L] ; rbs is stored info in rawphots  hash
		   whrb = WHERE(rbs,/null,nrb)
		   nrb = N_ELEMENTS(whrb)
	        endif else nrb = 0
		IF write EQ 2 THEN $ 
			k2cube = read_k2targ(kid,campaign,time,quality,$
			   flux_bkg,apmask0,data=targdata)
	ENDELSE
	if kid eq 251502099 then $
	     foreach ind,[3110,3122,3134,3182,3194,3206,3218,3254,3266,3276,3243,3255,3267] do $
			raw[ind] = !values.d_nan
	IF campaign EQ 12 THEN BEGIN
		CASE ccd of
		1:  raw[WHERE(time GT 2937.7 AND time LT 2941.0)] = !VALUES.D_NAN
		2:  raw[WHERE(time GT 2937.7 AND time LT 2941.2)] = !VALUES.D_NAN
		3:  raw[WHERE(time GT 2937.5 AND time LT 2941.0)] = !VALUES.D_NAN
		14: raw[WHERE(time GT 2955.0 AND time LT 2961.0)] = !VALUES.D_NAN
		43: raw[WHERE(time GT 2947.5 AND time LT 2949.5)] = !VALUES.D_NAN
		44: raw[WHERE(time GT 2948.5 AND time LT 2951.5)] = !VALUES.D_NAN
		58: raw[WHERE(time GT 2938.0 AND time LT 2942.0)] = !VALUES.D_NAN
		61: raw[WHERE(time GT 2945.0 AND time LT 2946.5)] = !VALUES.D_NAN
		65: raw[WHERE(time GT 2947.5 AND time LT 2948.5)] = !VALUES.D_NAN
		66: raw[WHERE(time GT 2945.0 AND time LT 2947.0)] = !VALUES.D_NAN
		67: raw[WHERE(time GT 2942.0 AND time LT 2946.5)] = !VALUES.D_NAN

		ELSE:
		ENDCASE
	ENDIF
	nt = N_ELEMENTS(raw)
	IF nt EQ 0d0 THEN CONTINUE
	IF (N_ELEMENTS(addnans) NE 0) THEN raw[addnans] = !VALUES.D_NAN
	IF TOTAL(raw,/nan) EQ 0 THEN BEGIN
		PRINT,'run_phot: All NANs in raw photometry'
		spawn,'mail eshaya2@gmail.com -s "K2 stop" < process_stopped.txt'
		;IF ~quicklook then STOP
		;CONTINUE
	ENDIF
            
        ; Check that there are enough pixels that are not set NaN
	nonans = WHERE(FINITE(raw),nnonans)
	IF nnonans LT nt/3 THEN BEGIN
	   PRINT, 'run_phot: Too few finite values.  Skipping ', skid
	   PRINT, 'run_phot: Finite Values = ',nnonans, ' Nt = ',nt
	   igal++
	   CONTINUE
	ENDIF



; 	IF campaign EQ 3 and ccd EQ 79 then have_centroids = 0

	; Setup centroid motion vectors xc and yc
	IF quicklook THEN xc = centroids(ccd,0,*)
	IF quicklook THEN yc = centroids(ccd,1,*)
	IF have_centroids THEN BEGIN
		; Find first finite xc,yc from light curve file  
		; and add it to averaged centroid array
		i = 0
		first = WHERE(~FINITE(xc,/nan))
		first = first[0]
		;if all of xc is NaNs, then just use 0.0,0.0
		IF first EQ -1 THEN BEGIN
			first = 0
			xc[0] = 0.0
			yc[0] = 0.0
		ENDIF
		xc = REFORM(centroids[ccd,0,*]) + xc[first]
		yc = REFORM(centroids[ccd,1,*]) + yc[first]
	ENDIF  ; IF ~have_centroids xc,yc are individual ones for each target

	thalf = (time[-1] + time[0])/2.
	; Rebin data
	IF bin GT 1 THEN BEGIN
		nt = nt/bin
		IF (campaign NE 1 AND ~quicklook) THEN $
			pdc_flux = CONGRID(pdc_flux,nt,/interp)
		time = CONGRID(time,nt,/interp)
		raw = CONGRID(raw,nt,/interp)
		xc = CONGRID(xc,nt,/interp)
		yc = CONGRID(yc,nt,/interp)
	        IF pca0[0] NE 0 THEN pca0 = CONGRID(pca0,11,nt,/interp) 
	ENDIF

	xc0 = xc - DOUBLE(FIX(xc[0])) - 0.5
	yc0 = yc - DOUBLE(FIX(yc[0])) - 0.5

	; Place lx by ly on a page
	; IF new ccd or page full then save and open new window
	IF ((ccd NE ccd_old) OR ((place MOD (lx*ly)) EQ 1) AND nkids GT 1 $
		AND ~noplot) THEN BEGIN
		pltname = 'phots_C'+scamp+nearby+'_ccd'+sccd+ $
			'_ap'+apstr+'_pca'+snpca+'_'+STRING(np++,format='(I02)')
		IF t2 NE 0 THEN pltname = pltname + '_t'+st2
		IF mode0 EQ 3 THEN pltname = pltname + '_t'+st3
	    	IF (place NE 1) AND (saveplt EQ 1) THEN $
        		plt.save,plotdir+pltname+'.png' $
	        ELSE np = 1
		IF buffer THEN current = 0
		IF ~(buffer OR noplot) THEN BEGIN
		  wins = GETWINDOWS()
		  nwins = N_ELEMENTS(wins)
	    	  IF nwins GT 9 THEN BEGIN
		      FOR i=0,nwins-9 DO BEGIN
			  winn = wins[i]
			   IF winn.name.startswith('Channel') THEN BEGIN
				   ;PRINT, 'closing window ',winn.name
				   winn.close
			   ENDIF
		      ENDFOR
		  ENDIF
	    	  win = WINDOW(window_title='Channel'+STRING(format='(I02)',ccd)$
			+'_'+STRING(np,format='(I02)'), $
		    dimensions=[600,512*4/3],position=[0.,.2,1.,1.])
    		ENDIF
		place = 1
	ENDIF
	IF debug THEN PRINT,'debug run_phot - set windows'
	; Remove cosmic rays 
	crcut = 3.0d0
	oddcut = 3d0
	smwide = 24
	FOR i=1,3 DO BEGIN
		sm3 = raw - SMOOTH(raw,smwide,/edge_truncate,/nan)
		stdev = STDDEV(sm3,/nan)
		; Cut crcut sigma ABOVE smooth to remove cosmic rays
		whq = WHERE(sm3 GT crcut*stdev,/null, nwhq)
        	PRINT, 'Cosmic rays removed: ',nwhq
		raw[whq] = !VALUES.D_NAN
		whq = WHERE(sm3 LT -oddcut*stdev,/null, nwhq)
        	PRINT, 'Too low ',nwhq,' By sigma x ',oddcut
		raw[whq] = !VALUES.D_NAN
	ENDFOR

	; Normalize
	; wht0p is set of all indices in time to use
        ; wht0p = WHERE((time GT t0 AND time LT tfinal))
        wht0p = WHERE(time GT t0)
	; If not bright enough for pca, can go on to next galaxy
	IF just_pca AND MEAN(raw,/double,/nan) LT mincounts THEN BEGIN
		igal++
		CONTINUE
	ENDIF

	; Pstep = 1 solves for coefficients
	IF (pstep GE 1) THEN BEGIN ;Begin pstep 1
		; For speed, get rid of NaNs before making fit
		     ;nonans = WHERE(FINITE(raw+xc0+yc0+pca0[0,*] AND ~rbs),nt3) $
		IF (npca NE 0) THEN $
		     nonans = WHERE(FINITE(raw+xc0+yc0+pca0[0,*]),nt3) $
		ELSE nonans = WHERE(FINITE(raw+xc0+yc0),nt3)
	        
		pca3 = pca0[*,nonans] ; just to get it into the common block
		npca3 = npca
		xc03 = xc0[nonans]
		yc03 = yc0[nonans]
		time3 = time[nonans]

		; Motion from one time step to another
		; May be used in sawtooth solution
	 	xminus = SHIFT(xc03,-1) - xc03
	 	yminus = SHIFT(yc03,-1) - yc03

		; repos is last in series before a thruster firing
		; When we shift down by 1 time step this one gets
		; a huge difference
		repos = WHERE(SQRT(xminus^2 + yminus^2) GT maxjitter,nrepos)

		; Prepare for Powell Minimization
		npsaw = 7
		nvec = npca + npsaw
		pfind = DBLARR(nvec)
		IF npca GT 0 THEN pfind[npsaw:*] = 2e-1/(indgen(npca)+1)
		;pfind[0:npsaw-1] = 1e0
		fullp = pfind
		IF KEYWORD_SET(pend)THEN BEGIN
			nvec = npsaw
			pfind = pfind[0:nvec-1]
		ENDIF
	
		; Get indices of raw and raw3 for Powell minimization
		; if no t2 or t3 then use whole LC 
		IF mode0 EQ 0 THEN BEGIN
		    whquiet = WHERE(time3 GE t0 AND time3 LT tfinal) 
		    whquietp = WHERE(time GE t0 AND time LT tfinal) 
	        ENDIF
		IF (mode0 EQ 1 OR mode0 EQ 3) THEN BEGIN
		    whquiet = WHERE(time3 GE t0 AND time3 LT t2) 
		    whquietp = WHERE(time GE t0 AND time LT t2) 
		ENDIF
		IF (mode0 EQ 3) THEN  BEGIN
		    whquiet = [whquiet,WHERE(time3 GT t3 AND time3 LE tfinal)]
		    whquietp = [whquiet,WHERE(time GT t3 AND time LE tfinal)]
		ENDIF
		IF (mode0 EQ 2) THEN  BEGIN
		    whquiet = [WHERE(time3 GT t3 AND time3 LE tfinal)]
		    whquietp = [WHERE(time GT t3 AND time LE tfinal)]
		ENDIF
	        mn = MEAN(raw[whquietp],/double,/nan)
	        rawn = raw/mn
		sm = SMOOTH(rawn,32,/edge_truncate,/nan)
		smphotn = sm[nonans]
	        IF nkids GT 1 THEN gals[igal].stddev[0] = STDDEV(rawn,/nan)
	        IF nkids GT 1 THEN gals[igal].mean = mn
		raw3 = rawn[nonans]
		nomedian = 1
		; Just help things along by first guess at 1st PCA coef.
		;IF N_ELEMENTS(fullp) GT npsaw THEN fullp[npsaw] = 0.01

		err = 0
		; If problems debugging, comment out next line
		waserror = 0
		;CATCH,err
		; Assume error is in awowell, so reset pfind to 0 and try more
		IF err NE 0 THEN BEGIN
			PRINT,' At catch1'
			PRINT,'run_phot: Error Index: ',err
			PRINT, 'run_phot: Error Message: ',!ERROR_STATE.MSG
			IF err EQ -654 THEN pfind = pfind*0d0 ELSE STOP
			waserror = 1
			err = 0
		ENDIF

		ftol = 1d-6
		nmax = 20000
		; Try Amoeba
		scale = DBLARR(nvec)+3d0
		scale[1:2] = 4d0
		pfind = pfind*0d0
		result = pfind
                IF ~waserror THEN BEGIN
		   ftol = 1d-5
		   fmin = 0
		   iter = 0
		   Result = AMOEBA( ftol, FUNCTION_NAME='lcfit', $
		        FUNCTION_VALUE=fmin, NCALLS=iter, $
		   	NMAX=nmax, P0=pfind, SCALE=scale )
		   PRINT,'Amoeba result = ',result
		   PRINT,'Amoeba res = ',format='(a,E14.3)',res
		   IF result[0] EQ -1 THEN BEGIN
		      ftol = 1d-6
		      scale = DBLARR(nvec)+2d0/(findgen(nvec)+1d0)
		          scale[1:2] = 1d0
		      pfind = pfind*0d0
                      Result = AMOEBA(ftol,FUNCTION_NAME='lcfit',$
			      FUNCTION_VALUE=fmin, NCALLS=iter,$
			      NMAX=nmax,P0=pfind,SCALE=scale )
		      PRINT,'result second try = ',result
		   ENDIF
		ENDIF
		pfind = result
		PRINT,format='(a,i6,E14.3)',$
			'run_phot: amoeba iterations, fmin =',  iter, fmin[0]
		; First use of Powell
		ftol = 1d-6
		itmax = 600
		xi = IDENTITY(nvec,/double)*1d-3
		; FOR i =0,npca-1 DO xi[i+npsaw,i+npsaw] = 1d-3 
		POWELL, pfind, xi,ftol,fmin,'lcfit',iter=iter,itmax=itmax,/double
		PRINT, format='(a,i6,E14.3)',$
			'run_phot: Number of iterations and fmin: ',iter,fmin
		ftol = 1d-6
		xi = IDENTITY(nvec,/double)*1d-4
		xi[0]=-.1d0
		xi[-1]=.2d0
		; Immediately rerun powell
		POWELL, pfind, xi,ftol,fmin,'lcfit',iter=iter,itmax=itmax,/double
		PRINT, format='(a,i6,E14.3)',$
			'run_phot: Number of iterations and fmin: ',iter,fmin
		;ftol = 1d-7
		xi = IDENTITY(nvec,/double)*2d-3
		;FOR i =0,npsaw-1 DO xi[i,i] = 1d-3 
		;pfind2 = pfind*0d0
		POWELL, pfind, xi,ftol,fmin,'lcfit',iter=iter,itmax=itmax,/double
		PRINT,'pfind = ',pfind
		PRINT, format='(a,i6,E14.3)','run_phot: Number of iterations and fmin: ',iter,fmin
		CATCH,/cancel
		IF KEYWORD_SET(pend) THEN fullp = [pfind,pend] ELSE fullp=pfind
   		PRINT, format='(a,7e10.2)','run_phot: Solution centroid coeffs: ', $
			fullp[0:npsaw-1]
   		IF npca NE 0 THEN PRINT,format='(a,9e10.2)',$
			'run_phot: Solution PCA coeffs: ', fullp[npsaw:*]
		PRINT,'run_phot: fmin',format='(a,E14.3)',fmin
		;IF kid EQ 206361816 THEN fullp[7:9] = [-.005,-.000,.000]

		xc1 = xc0 - fullp[2] MOD 3
		yc1 = yc0 - fullp[3] MOD 3
    		ffit1= 1d0 - (fullp[0]*xc1) - (fullp[1]*yc1) $
		     + fullp[4]*xc1^2 + fullp[5]*yc1^2 + fullp[6]*xc1*yc1

		IF npca GT 0 THEN BEGIN
		    ; additive
		    ;ffit2 = DBLARR(nt)
		    ; multiplicative
		    ffit2 = DBLARR(nt) + 1d0
	 	    FOR i = 0, npca-1 DO ffit2 = ffit2 + fullp[i+npsaw]*pca0[i,*] 
		ENDIF ELSE ffit2 = 1d0 ; ffit2 = 0d0 for additive

		;photn = rawn/ffit1 - ffit2
		photn = rawn/(ffit1 * ffit2)
		; mn2 is mean of quiet period after correction fit
		mn2 = MEAN(photn[whquietp],/double,/nan)
		photn = photn/mn2
		fullp0 = fullp
;	        This starts loops for data after the explosion
		IF (mode0 NE 0 AND just_pca EQ 0)  THEN BEGIN
			win3.setCurrent
			win3.show
			win3.erase
			; Plot photn (reduced LC) in black dots
			plt=PLOT(/current,time,photn,$
				yrange=yrange0,symbol='dot',linestyle='',$
			        title=title0,xtitle='Day',font_size=14,$
				ytitle='Normalized Flux',xstyle=1,xthick=2,$
				ythick=2,sym_thick=1,sym_size=1,xrange=[time[0]-2,time[-1]+2])
			; PLOT red RB_LEVEL > 1.
			IF (nrb GT 0) then $
				plt=PLOT(/current,/over,time[whrb],photn[whrb],$
				linestyle='',symbol='dot',color='red')
		        ; Overplot rawn (raw LC) in cyan dot
			plt=PLOT(/overplot,/current,$
				time,rawn,$
				color='cyan',symbol='dot',linestyle='')
			; Overplot ffit3 (best fit) in magenta dots
			plt = PLOT(/overplot,/current,$
				time,ffit1 * ffit2,$
				symbol='dot',linestyle='',color='magenta')
			plt = PLOT(/overplot,/current,$
				[time[0],time[-1]],[1,1])
			dummy = ''
			PRINT, ' Solved coefficients for quiet times, hit return to continue'
		   	sm = SMOOTH(photn,32,/edge_truncate,/nan)
		  	smphotn =  sm[nonans]
		   	ftol = 1d-7
			;IF npca GT 0 THEN pend = fullp[npsaw:*]
			pfind = fullp[0:npsaw-1]
			fullp = pfind
		        xi = -IDENTITY(npsaw,/double)*1d-3

			; This time solve in the period of activity
			; whnoquietp is where known variations happen
			IF (mode0 EQ 1) THEN BEGIN
			    whnoquietp = WHERE(time GT t2 AND $
			     time LE tfinal AND photn GE minflux, nnoquiet) 
			    whnoquietp2 = WHERE(time GT t2 AND $
			      photn GE minflux, nnoquiet) 
			ENDIF
			IF (mode0 EQ 2) THEN BEGIN
			    whnoquietp = WHERE(time GE t0 AND $
			      time LT t3 AND photn GE minflux, nnoquiet,/null) 
		            IF ISA(whnoquietp) THEN BEGIN
			        whnoquietp = WHERE(time GE time[whnoquietp[0]] $
		            		AND time LE time[whnoquietp[-1]]) 
			    	whnoquietp2 = WHERE($
			        time LT t3 AND photn GE minflux, nnoquiet) 
		                whnoquietp2 = WHERE(time GE time[whnoquietp2[0]] $
		            	AND time LE time[whnoquietp2[-1]])
			    ENDIF
			ENDIF 
			IF (mode0 EQ 3) THEN BEGIN
			    whnoquietp = WHERE(time GT t2 AND $
			      time LT t3 AND photn GE minflux, nnoquiet,/null) 
		            IF nnoquiet GT 0 THEN BEGIN
			        whnoquietp = WHERE(time GE time[whnoquietp[0]] $
		            		AND time LE time[whnoquietp[-1]]) 
			    ENDIF
		      		whnoquietp2 = whnoquietp
			ENDIF
			; Begin analysis of variation time
			IF (nnoquiet GT 0) THEN BEGIN

			    ; whnoquiet is time3 (for lcfit) when variations happen.
			    whnoquiet = WHERE(time3 GE time[whnoquietp[0]]$
				    AND time3 LE time[whnoquietp[-1]])

			    ; LCFIT works on whquiet points, so set whquiet to
			    ; whnoquiet to fool it into working on  not
			    ; quiet period
			    whquiet = whnoquiet
			    IF (n_elements(whnoquiet) LT 200) THEN CONTINUE
 			    ; Take out sawtooth of not quiet phase.
			    ; But we do not want to change overall level this
			    ; section of photn, so multiply by first value
			    ; of quiet phase of ffit1
			    if (mode0 EQ 1 OR mode0 EQ 3) THEN $
				    mnfit = mean(ffit1[whnoquietp2[0:2]],/double,/nan)
			    if (mode0 EQ 2) THEN mnfit = mean(ffit1[whnoquietp2[-3:-1]],/double,/nan)
			    photn[whnoquietp2] = photn[whnoquietp2]*$
				ffit1[whnoquietp2]/mnfit

			    sm = SMOOTH(photn,32,/edge_truncate,/nan)
			    smphotn = sm[nonans]
			    ; Put this into raw3 to solve in Powell again
			    ; but we will just work on whnoquiet region
			    raw3 = photn[nonans] 
 
			    CATCH,err
			    IF err NE 0 THEN BEGIN
				PRINT,' At catch2'
				PRINT,'run_phot: Error Index: ',err
				PRINT, 'run_phot: Error Message: ',!error_state.msg
				IF err EQ -654 THEN pfind = pfind*0d0 ELSE STOP
			    ENDIF
			    ; Solving just for sawtooth
	        	    xi = IDENTITY(npsaw,/double)*1d-2
			    ftol=1d-7
			    POWELL, pfind, xi,ftol,fmin,func,iter=iter,itmax=itmax,/double
			    PRINT, format='(a,i6,E14.3)','run_phot: Number of iterations and fmin: ',iter,fmin
			    CATCH,/cancel
			    POWELL, pfind, xi,ftol,fmin,func,iter=iter,itmax=itmax,/double
			    PRINT, format='(a,i6,E14.3)','run_phot: Number of iterations and fmin: ',iter,fmin
			    PRINT, format='(a,7e10.2)','run_phot: Solution centroid coeffs: ', pfind

			    xc1 = xc0 - pfind[2] MOD 3
			    yc1 = yc0 - pfind[3] MOD 3

			    ffit1p = 1d0 - pfind[0]*xc1 -  pfind[1]*yc1 $
				+ pfind[4]*xc1^2 + pfind[5]*yc1^2 + pfind[6]*xc1*yc1 
			    ; The overall effect on not quiet part is that it 
			    ; is multiplied by ffit1p
			    ffit1[whnoquietp2] = ffit1p[whnoquietp2]
			    photn[whnoquietp2] = photn[whnoquietp2]/ffit1p[whnoquietp2]
	   		    ;plt.erase
			    ; Plot corrected sn LC
	   		    ;plt=PLOT(/current,time,1.0d0+snphot/ffit1p ,symbol='dot',linestyle='',$
	   		    ;plt=PLOT(/current,time,photn,symbol='dot',linestyle='',$
	   		    ;title=skid,yrange=yrange0,xtitle='Day',ytitle='Normalized Flux',$
			    ;xthick=2,ythick=2,xstyle=1,font_size=14)
	 		    ; Plot 1+snphot SN light curve as blue dots
	   		    ;plt=PLOT(/overplot,/current,time,galaxy+snphot,color='blue',symbol='dot',linestyle=''
			    ; Plot sawtooth used in SN
			    ;plt = PLOT(/overplot,/current,time,ffit1p/galaxy,symbol='dot',linestyle='',color='green')

			    ;READ,'Plot of snphot raw and final. Hit return to continue',dummy

		            ;plt = PLOT(/overplot,/current,time,ffit1 * ffit2,symbol='dot',linestyle='',color=!color.brown)
		            ;plt = PLOT(/overplot,/current,[time[0],time[-1]],[1,1])
			    IF KEYWORD_SET(pend) THEN fullp = [pfind,pend] ELSE fullp=pfind
        		    IF KEYWORD_SET(pend) THEN PRINT,'run_phot: But, pend =',fullp[npsaw:*]

			ENDIF ; if whnoquiet not null

	        ENDIF ELSE BEGIN ; if mode0 not 0, now mode0 eq 0

			; Check if kid is on the nodo list for PCA
			wheredo = WHERE(nodo EQ kid,ndo)
			IF ndo GT 0 THEN $
				PRINT,'run_phot: ',skid+' not included in PCA.'$
			ELSE $
				phots_pca = [ [phots_pca],[mn*rawn/ffit1] ]

			; Print the value at the solution point:
	   		PRINT, 'run_phot: rms rawn-1 before fit', $
			SQRT(MEAN((rawn-1d0)^2,/double,/NAN))
			;photn = rawn/ffit1 - ffit2
			; Small adjust to get mean to exactly 1.0
        	ENDELSE  ; end if mode0 NE 0

	   ; This is done in all mode0
           PRINT, 'run_phot: rms photn-1 ', $
	   SQRT(MEAN((photn-1d0)^2,/double,/NAN))

	   IF nkids GT 1 THEN gals[igal].stddev[1] = STDDEV(photn,/nan)
	ENDIF ; if pstep 1
	phot = photn*mn 

	IF campaign NE 1 THEN BEGIN
		
		IF ISA(sap_flux) THEN meansap = MEAN(sap_flux,/double,/nan) else meansap = 0
		IF (nkids GT 1 AND ISA(sap_flux)) THEN $
			gals[igal].stddev[2] = STDDEV(pdc_flux/meansap,/double,/nan)
		IF ISA(pdc_flux) then meanpdc = MEAN(pdc_flux,/double,/nan) else meanpdc = 0
		IF (nkids GT 1 AND ISA(pdc_flux)) THEN $
			gals[igal].stddev[3] = STDDEV(pdc_flux/meanpdc,/double,/nan)
		PRINT, 'run_phot: Mean phot: ',mn, ', Mean sap: ',meansap,', Mean PDC: ',meanpdc
	ENDIF
        photplt = photn
	nrm = 1d0
	;IF kid EQ 206361816 THEN t2=2148
	; Normalize by galaxy light without SN light
	IF (mode0 EQ 1 OR mode0 EQ 3) THEN BEGIN
		;wht0 = WHERE(time GT t0 AND time LT t2)
		nrm = MEAN(photplt[whquietp],/double,/nan)
		photplt = photplt/nrm
	ENDIF
	IF (mode0 EQ 2) THEN BEGIN
		wht0 = WHERE(time GT t3 AND time LT tfinal)
		nrm = MEAN(photplt[wht0],/double,/nan)
		photplt = photplt/nrm
	ENDIF
	IF ~buffer THEN BEGIN
		win2.setCurrent
		win2.show
		win2.erase
		; Plot,first reduced LC with black dots
		IF debug THEN PRINT,'debug: run_phot: About to start plot'
		plt2=PLOT(/current,time,photplt,yrange=yrange0,symbol='dot',$
			linestyle='',title=title0,xtitle='Day',xstyle=1,$
			sym_size=1,sym_thick=1,$
			ytitle='Normalized Flux',font_size=14,$
			xthick=3,ythick=3,xrange=[time[0]-2,time[-1]+2])

		IF (nrb gt 0) THEN plt2=PLOT(/current,/over,time[whrb],photplt[whrb],symbol='dot',$
			color='red',linestyle='',sym_thick=1,sym_size=1)

		;plt2=PLOT(/overplot,time,SMOOTH(photn,48,/nan,/edge_truncate),/current)
		;plt2=PLOT(/overplot,time,SMOOTH(pdc_flux,48,/nan,/edge_truncate)/meanlc,$
;			color='red',/current)

 		; Plot pdc flux as red dots
;		plt2=PLOT(/overplot,time,pdc_flux/MEAN(pdc_flux,/nan),color='red',symbol='dot',linestyle='',/current)

		; Plot fit 
		plt2 = PLOT(/overplot,/current,time,ffit1 * ffit2-0.07,symbol='dot',linestyle='',color='orange')
		; Plot raw as cyan dots
		plt2=PLOT(/overplot,time,rawn-0.07,symbol='dot',linestyle='',color='cyan',/current)
		
		plt2 = PLOT(/overplot,[time[0],time[-1]],[1,1])
		;plt2=PLOT(/overplot,time,photplt,symbol='dot',linestyle='',/current)
;		plt2 = PLOT(/overplot,/current,time,ffit3,symbol='square',$
;			linestyle='',sym_size=.2,color='green')
		text = TEXT(.04,.86,STRING(mn,format='(i8)'),/relative,$
			target=plt2,color='red',font_size=12)
		IF debug THEN PRINT,'debug: run_phot: end plot'
	ENDIF ;~buffer

	phots = [[phots],[phot]]


	;IF kid EQ 211394078 AND nkids GT 1 THEN STOP
	;IF kid EQ 211394078 THEN plt2.save,'sn_k.eps',resolution=300

	; Write LC data
;	p=scatterplot(time,bkg,symbol='.',title='Background',ytitle='K2 Counts',xtitle='Day',sym_color='red')
	IF write EQ 1 THEN BEGIN
		if sbin NE 0 then $
			datafile = 'Campaign'+scamp+nearby+'/LC/LC_'+'C'+scamp+$
			'_'+skid+'_rebin'+sbin+'_ap'+apstr $
		else $
			datafile = 'Campaign'+scamp+nearby+'/LC/LC_'+'C'+scamp+$
			'_'+skid+'_ap'+apstr 

		IF t2 NE 0 THEN datafile = datafile + '_t2_' + st2 $
		ELSE IF t3 NE 0 THEN datafile = datafile + '_t3_' + st3 
		OPENW,/get_lun,wunit,datafile+'.txt'
		PRINTF,wunit,'LC of EPIC ',skid,format='(a6,a11)'
		PRINTF,wunit,'K2_Time,Counts,Raw,RB,Sky,Error'
		PRINTF,wunit,'double,double,double,double,double,double'
		;p = errorplot(/overplot,time,phot,errorbar,linestyle='',symbol='+')
		;FOR i = 0,nt-1 DO PRINTF,wunit,format='(5D15.6)',time[i],phot[i],raw[i], bkg[i], errorbar[i]
		IF (t2 NE 0) THEN $
			whq = WHERE(time GT t2-7. AND time LT t2,nwhq) 
		IF (t3 NE 0) THEN $
			whq = WHERE(time GT t3 AND time LT t3+7,nwhq) 
		IF (t3 EQ 0 AND t2 EQ 0) THEN $
		        whq = WHERE(time Gt t0+5. AND time LT t0+12.,nwhq)
		if nwhq GT 0 then $
			stdev = SQRT(MEAN((phot[whq]-MEAN(phot[whq],/double,/nan))^2,/nan))
		print,'stdev',stdev
		errorbar = stdev*SQRT((phot+sky)/(phot[whq[0]]+sky[whq[0]]))
		FOR i = 0,nt-1 DO PRINTF,wunit,format='(D11.6,5(",",D13.6))',time[i],phot[i],raw[i], bkg[i], sky[i], errorbar[i]
		CLOSE,wunit
		FREE_LUN,wunit
	ENDIF
	IF write EQ 2 THEN BEGIN

		; Header data for this kid
		hdr_0 = llcdata.header
		hdr_lc = llcdata.lightcurve.header
		hdr_ap = llcdata.aperture.header
		cadenceno = llcdata.lightcurve.data.cadenceno
		write_fits_lc,kid,campaign,npca,hdr_0,hdr_lc,hdr_ap,$
			cadenceno, raw,$
			phot,targdata.targettables.header,time,fullp0,apmask
	ENDIF

	; PLOT phots on each CCD
	IF nkids GT 1 AND ~noplot THEN BEGIN
		IF ~buffer THEN BEGIN
			win.setCurrent
			win.show
		ENDIF
		plt = SCATTERPLOT(time,photplt,$
		     symbol='dot',yrange=yrange1,xrange=[time[0],time[-1]],$
		     xshowtext=0,yshowtext=0,font_size=9,current=current,$
		     xtickinterval=20,buffer=buffer,xstyle=3,position=pos[*,place-1])
		IF (nrb gt 0) THEN plt=SCATTERPLOT(/over,time[whrb],photplt[whrb],symbol='dot',sym_color='red')
		IF (((place++ -1) MOD (lx*ly)) GE (lx*ly-3)) THEN plt['axis0'].showtext=1
		IF (nn GT nkids-2) THEN plt['axis0'].showtext=1
	        current = 1
 		;IF pstep EQ 2 THEN  $
 		;	plt  = PLOT(/overplot,time,ffit3,color='red',sym_size=.5)
		; Plot pdc_flux lightcurve in red
		;IF ISA(pdc_flux) THEN $
		;	plt  = PLOT(/overplot,$
		;	time,pdc_flux/MEAN(pdc_flux,/double,/nan),symbol='dot',$
		;	linestyle='',sym_size=.5,color='orange',sym_transparency=50)
;
		; Write EPIC number in red
		text=TEXT(thalf+5,1.03,skid,font_size=8,color='red',/data,$
			target=plt,fill_background=1,fill_color=[204,255,204])
		; Write Mean Count Rate in red
		text=TEXT(time[0]+1,1.03,STRING(mn,format='(i7)'),color='red',$
			font_size=8,/data,target=plt,fill_background=1,fill_color=[204,255,204])
		IF debug THEN PRINT,'debug run_phot - Prepare to plot done'

	ENDIF ; nkids gt 1 and noplot
	if nkids gt 1 and npca gt 0 then gals[igal].coeffs[0:npca-1] = pfind[npsaw:-1]
	ccd_old = ccd
	igal++
ENDFOREACH ; END foreach kid
IF ~noplot THEN BEGIN
	; SAVE PLOT
	IF (nkids GT 1) AND (saveplt EQ 1) THEN BEGIN
		pltname = 'phots_C'+scamp+nearby+'_ccd'+sccd+ $
			'_ap'+apstr+'_pca'+snpca+'_'+STRING(np++,format='(I02)')
		IF t2 NE 0 THEN pltname = pltname + '_t'+st2
        	plt.save,plotdir+pltname+'.png'
	ENDIF
ENDIF

; WRITE summary statistics
IF nkids GT 1 AND pstep GE 1 AND write EQ 1 THEN BEGIN
	statsname = 'Campaign'+scamp+nearby+'/stats/summarystats_'+sccd+'_ap'+apstr
	IF t2 NE 0 THEN statsname = statsname + '_t'+st2
	OPENW,/get_lun,wunit,statsname+'.txt'
	PRINTF,wunit,nkids,' ',SYSTIME()
	PRINTF,wunit,format='(a9,a10,1x,4a13,5A13)','Name','Mean','Stdv(rawn)',$
		'Stdv(photn)','Stdv(sapn)','Stdv(pdcn)','Coeff1','Coeff2','Coeff3',$
		'Coeff4','Coeff5'
	FOR i = 0, nkids-1 DO PRINTF,wunit,format='(i9,1x,F9.0,1x,4E13.4,5E13.4)',gals[i]
	CLOSE,wunit
ENDIF

		IF debug THEN PRINT,'debug run_phot - wrote summary statistics '
PRINT,'End run_phot',' ',SYSTIME()
RETURN,phots
END
