pro runk2,campaign,nearby,k2data,npca,ccds=ccds,apsize=apsize,centroids=centroids,$
      write=write,oneshot=oneshot,rawstore=rawstore,tfinal=tfinal,$
      buffer=buffer,noplot=noplot,delt0=delt0,just_pca=just_pca, nopca = nopca,$
      t2=t2,t0=t0,t3=t3,bin=bin,noprompts=noprompts,quicklook=quicklook

; Run K2 photometry on a set of ccds and obtain PCA vectors
; Inputs:
; campaign - Campaign number 
; nearby - For the KEGS Nearby Galaxy campaigns
; k2data -  Structure holding table of GO target info from MAST
;    typically: K2_ID,RA,DEC,RMAG,RMAGERR,
;      JMAG,JMAGERR,KEPMAG,SDSSID,UCACID,2MASSID,MODULE,OUTPUT,CHANNEL
; ccds - 2 element vector with start and end channels to work on
; apsize - Aperture size to use, an odd number usually 3, 5 or 7
; npca - Number of PCA vectors to use to reduce instrumental noise of LC
; write - If set, then statistics and LCs are written to disk
; oneshot - If set, then there is just one pass through, if not set then
;	    a preliminary pass of just the targets with counts above mincounts
;	    are processed to improve the quality of the PCA vectors.
; t2 - For SN, a time just before SN event
; t0 - The earliest time in K2 days for minimization.  That is, ignore LC data 
;       before t0.
; bin - Rebin by bin value (using congrid) is done on everything, unless 
;       bin = 0 or 1.
; rawstore -  Set this flagt to use raw LCs stored in rawphots hash. 
;		A new rawphots hash is written each time.
; centroids - This is the array of centroid positions at each time in each 
;	channel.  Produced in get_centroids.
; buffer - Send plots to buffer, so they do not show up on screen, but eps files
;	    are still written.
; noplot - If set,then no plotting at all.
; just_pca - If set, then PCA analysis is done but faint galaxies are ignored.
; nopca - If set, then no PCA analysis is done

; DirectoFry Structure
;  Top level is workdir (I usually name it K2)
;   Subdir of workdir are CampaignN (ie Campaign5, Campaign6...)
;   Subdir of CampaignN are:
;  LC - output LCs
;  llc - K2 project llc files (can be gzipped)
;  tpf - K2 project target pixel files (can be gzipped)
;  pca - Holds PCA info
;  plots - output plots
;  stats - output files of statistics

IF ~KEYWORD_SET(rawstore) THEN rawstore = 0
IF ~KEYWORD_SET(qucklook) THEN qucklook = 0
IF ~KEYWORD_SET(noprompts) THEN noprompts = 0
IF ~KEYWORD_SET(noplot) THEN noplot = 0
IF ~KEYWORD_SET(just_pca) THEN just_pca = 0
IF ~KEYWORD_SET(apsize) THEN BEGIN
	PRINT,'No apsize set, using mymask'
	apsize = 0
ENDIF
ap = apsize
IF apsize EQ 0 THEN mask = mymask()
IF KEYWORD_SET(mask) THEN ap = 4 
IF ~KEYWORD_SET(bin) THEN bin = 1
IF ~KEYWORD_SET(delt0) THEN delt0 = 0
PRINT,' Binning is ',bin
CD, !workdir
scamp = STRTRIM(STRING(campaign),2)
scampaign = 'Campaign'+scamp
datasavefile = scampaign+'/k2data.sav'
IF ~KEYWORD_SET(k2data) THEN RESTORE,datasavefile
IF ~KEYWORD_SET(oneshot) THEN oneshot = 0
IF ~KEYWORD_SET(nopca) THEN nopca = 0
IF ~KEYWORD_SET(centroids) THEN centroids = 0
IF ~KEYWORD_SET(t2) THEN t2 = 0
IF ~KEYWORD_SET(t3) THEN t3 = 0
IF ~KEYWORD_SET(t0) THEN t0 = 0
IF ~KEYWORD_SET(tfinal) THEN tfinal = 0
IF ~KEYWORD_SET(ccds) THEN BEGIN
	ccds = []
	READ,'ccd start',ccds[0]
	READ,'ccd end',ccds[1]
ENDIF
if ~noprompts then $
	HELP,apsize,bin,npca,oneshot,campaign,write,t0,t2,t3,tfinal,$
	delt0,nopca,just_pca,noplot,rawstore
PRINT,'CCDs:',ccds
dum=''
if ~noprompts then READ,' Continue?',dum
IF dum EQ 'n' THEN RETURN

; Restore centroids or create new ones
IF centroids[0] EQ 0 AND campaign NE 1 THEN BEGIN
    cenfile = scampaign +'/centroids.sav'
    test1 = FILE_SEARCH(cenfile,count=count)
    IF count NE 0 THEN BEGIN
	RESTORE,cenfile
        ENDIF ELSE BEGIN 
		dum = ''
		read, 'SETTING NOPOSCORR in CENTOIDS',dum
		noposcorr = 1

	centroids = get_centroids([1,84],k2data,campaign,noposcorr=noposcorr)
	READ,' Centroids good?', dum
	IF dum EQ 'n' THEN STOP
	SAVE,centroids,filename=cenfile
    ENDELSE
ENDIF
FOR ccd = ccds[0],ccds[1] DO BEGIN
	IF campaign EQ 10 AND ccd EQ 9 THEN CONTINUE
	IF campaign EQ 10 AND ccd EQ 10 THEN CONTINUE
	IF campaign EQ 10 AND ccd EQ 11 THEN CONTINUE
	IF campaign EQ 10 AND ccd EQ 12 THEN CONTINUE
	; These channels have bad centroids
	IF campaign EQ 16 AND ccd EQ 67 THEN CONTINUE
	IF campaign EQ 16 AND ccd EQ 68 THEN CONTINUE
	whccd = WHERE(k2data.channel EQ ccd, nkids)
	npca0 = npca
	IF nkids EQ 0 THEN BEGIN
		PRINT,'runk2: No targets on channel ',ccd
		CONTINUE
	ENDIF
	pcavec = 0
	variances = 0
	PRINT,''
	PRINT,'runk2: Now running ccd ',ccd
        sccd = STRING(ccd,format='(I02)')
	sbin = STRTRIM(STRING(bin),2)
	IF bin EQ 1 THEN sbin = '0'
	sap = STRTRIM(STRING(ap),2)

	IF sbin NE 0 THEN $
		cbvfile = scampaign + '/pca/cbv_ap'+sap+'_rebin'+sbin+$
		'_ccd'+sccd+'.sav' $
	else $
		cbvfile = scampaign + '/pca/cbv_ap'+sap+$
		'_ccd'+sccd+'.sav' 
	PRINT,' cbvfile = ',cbvfile
	IF npca NE 0 THEN BEGIN
	   ; Check to see if have pca already, 
	   ; If we have it, restore it from saveset, otherwise create new
	   ;  by setting npca0 to 0, overriding npca.
	   test0 = FILE_SEARCH(cbvfile,count=count)
	   ; Restore pcavec and variances
	   IF count NE 0 THEN BEGIN
		   RESTORE,cbvfile 
		   pcavec = cbv
	   ENDIF ELSE BEGIN
	           PRINT,' No cbv file: ',cbvfile
		   STOP
		   npca0 = 0
	   ENDELSE
	   IF pcavec[0] EQ -1 THEN CONTINUE
        ENDIF

	; Check if there is a saved rawphots
	rawfile= scampaign+nearby+'/raw/rawphots_c'+scamp+'_ccd'+sccd+'_ap'+sap+'.sav'
	; if rawstore set, then restore rawfile, if it exist.
	IF rawstore THEN BEGIN
	    test0 = FILE_SEARCH(rawfile,count=count)
	    IF count NE 0 THEN RESTORE, file = rawfile
	ENDIF

	; If oneshot is not set we do this section and the other, but
	; if it is set we do only the other section.
	IF oneshot EQ 0 THEN BEGIN
	  ; starting first run_phot
	  phots=run_phot(campaign,nearby,npca0,apsize=apsize,mask=mask,k2data=k2data,$
		centroids=centroids,pstep=1,ccd=ccd,bin=bin,/noplot,quicklook=quicklook,$
		rawphots=rawphots,pcavec=pcavec,phots_pca=phots_pca,$
		t3=t3,t2=t2,t0=t0,tfinal=tfinal,peak=0,/just_pca,buffer=buffer)
	  IF phots[0] EQ -1 THEN CONTINUE
	  IF t2 EQ 0 AND t3 EQ 0 THEN BEGIN
             if (size(phots_pca,/n_dim) NE 2) then continue
	     pcavec = k2pca(campaign,phots_pca,bin=bin,ap=ap,variances=variances) 
	     dim = SIZE(pcavec,/dimension)
	     cbv = pcavec[0:(dim[0]-1) < 15,*]
	     PRINT,' Saving pcavec for ccd ',ccd
	     IF dim[0] GE 5 THEN $
		     SAVE,cbv,variances,filename=cbvfile $
	     ELSE $
	     	PRINT,'runk2: WARNING: Less than 5 vectors found from PCA'
  	   ENDIF
  	ENDIF

	; Here is where the finally photometry is done
	IF ~oneshot AND npca0 EQ 0 THEN npca1=1 ELSE npca1=npca0
	; Running run_phot for second time if oneshot=0, otherwise first time
	phots=run_phot(campaign,nearby,npca1,mask=mask,apsize=apsize,k2data=k2data,$
		pstep=1,ccd=ccd,bin=bin,pcavec=pcavec,/saveplt,rawphots=rawphots,$
		centroids=centroids,phots_pca=phots_pca,write=write,t2=t2,quicklook=quicklook,$
		t3=t3,t0=t0,tfinal=tfinal,peak=0,buffer=buffer,noplot=noplot,delt0=delt0,func='lcfit')
	IF phots[0] EQ -1 THEN CONTINUE
	IF t2 EQ 0 AND t3 EQ 0  AND nopca EQ 0 THEN BEGIN
	    cbv = k2pca(campaign,phots_pca,bin=bin,ap=ap,variances=variances) 
	    dim = SIZE(cbv,/dimension)
	    IF dim[0] GT 4 THEN SAVE,cbv,variances,filename=cbvfile
	    IF sbin NE 0 THEN  $
	    	pcafile = scampaign +'/pca/pca_ap5_rebin'+sbin+$
		'_ccd'+sccd+'.sav' $
	    ELSE $
	    	pcafile = scampaign +'/pca/pca_ap5'+ $
			'_ccd'+sccd+'.sav' 
	    SAVE,phots_pca,filename=pcafile
;
	    ; Save new rawphots for each ccd.  Note this is always done
	    SAVE,rawphots,file= rawfile
	ENDIF
ENDFOR ; end foreach ccds
; For viewing SN
;npca=2 & write=0 & oneshot=1 & t0 = 0 & t3 = 0 & rawstore=1 & buffer=0 & noplot=0 & delt0=0 & just_pca=0 & nopca=1 & tfinal=0
RETURN
END
