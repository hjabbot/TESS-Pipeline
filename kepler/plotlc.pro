function plotlc,kid,phothash,quarters,skygroup,apsize,slope=slope,stitch=stitch,$
	title=title,ps=ps,norm=norm, bcon=bcon,graph=graph,llc=llc,$
	c2=c2,days=days,shiftsub=shiftsub,write=write,noplot=noplot,nanq=nanq,$
	findsharp=findsharp,vlim=vlim,fast=fast


partday = 2
day = 48/partday
; stitching region
stitchdays = 30
delta = day*stitchdays

if ~keyword_set(title) then title1=string(kid) else title1 = title
wtitle = title1
if ~keyword_set(llc) then llc = 0
if ~keyword_set(stitch) then stitch0 = 0 else stitch0 = stitch
if ~keyword_set(vlim) then vlim = 0
if ~keyword_set(nanq) then begin
	nanq0 = 0
	if (kid eq 11808151) then nanq0 = [13]
;	if (kid eq 12553112) then nanq0 = [10]
	if (kid eq 12301469) then nanq0 = [17]
	if (kid eq 12784696) then nanq0 = [12]
	if (kid eq 11393296) then nanq0 = [15]
	if (kid eq 11703086) then nanq0 = [15]
	if (kid eq 11752884) then nanq0 = [6]
	if (kid eq 11954810) then nanq0 = [9]
	if (kid eq 10317830) then nanq0 = [12]
	if (kid eq 10383333) then nanq0 = [13]
	if (kid eq 10513991) then nanq0 = [11]
	if (kid eq 10579087) then nanq0 = [13]
endif else nanq0 = nanq
if ~keyword_set(bcon) then bcon = 0
if ~keyword_set(write) then write=0
if ~keyword_set(slope) then slope=0
slope0=slope
if ~keyword_set(norm) then norm=0
if ~keyword_set(shiftfix) then shiftfix=0
if ~keyword_set(c2) then c2=1d0
if ~keyword_set(days) then days=0
if ~keyword_set(noplot) then noplot=0
if ~keyword_set(shiftsub) then shiftsub=0
if ~keyword_set(ps) then ps=0
shiftsub0 = shiftsub
skid = strtrim(string(kid),2)
sap = strtrim(string(apsize),2)
sskygroup = strtrim(string(skygroup),2)

if (noplot eq 1) then buffer =1 else buffer = 0

smdays=10
first = 0
g = skygroup

; nq is number of quarters to cover
nq = quarters[1]-quarters[0]+1

; Make lists of the each data from phothash
tl = list(phothash(quarters[0],g,kid,apsize,'time'))
photl = list(phothash(quarters[0],g,kid,apsize,'phot'))
bkgndl = list(phothash(quarters[0],g,kid,apsize,'bkgnd'))
asyml =  list(phothash(quarters[0],g,kid,apsize,'asym'))
f3f5l = list(phothash(quarters[0],g,kid,apsize,'f3f5'))

; Read PDC LC
if (llc) then begin 
      llcl = read_llc(kid, quarters, llctime)
      for q = quarters[0], quarters[1] do begin
	n = q - quarters[0]
	sq = strtrim(string(q),2)
	; Get SF of PDC LC for each quarter
        if (fast ne 3) then begin
	   sfast = strtrim(string(fast),2)
           file='../sf/llc/sfllc_'+skid+'_'+sq+'_'+sfast+'.sav'
	   ; If already have one then skip it
	   ;test = file_search(file,count=count)
	   count = 0
	   if (count eq 0) then begin
	   	print,' SF for llc in quarter '+sq
           	;sfpdc=sf(llctime[n],llcl[n]/mean(llcl[n],/nan),tau=sftau,nnt=nnt,fast=fast)
	        tau2 = 2./3.*(llctime[n,-1]-llctime[n,0])
            	sfpair=strucfunc(llctime[n],llcl[n],tau2=tau2)
		sftau = sfpair[*,0]
		sfpdc = sfpair[*,1]
	        ;plt = scatterplot(sftau,sfpdc,symbol='dot')
           	save,sfpdc,sftau,file=file
           endif
        endif
       endfor
endif

for q = quarters[0], quarters[1] do begin
	nodata = 0
	if ( isa(phothash[q],'HASH') eq 0 || $
		where(phothash[q].keys() eq g) EQ -1 || $
		isa(phothash[q,g],'HASH' )eq 0 || $
		where(phothash[q,g].keys() eq kid) EQ -1 || $
		isa(phothash[q,g,kid],'HASH') eq 0 || $
		where(phothash[q,g,kid].keys() eq apsize) EQ -1) then begin
		nodata = 1 
		tl.add,!null
		photl.add,!null
		bkgndl.add,!null
		asyml.add,!null
		f3f5l.add,!null
	endif else begin
	        sq = strtrim(string(q),2)
		tl0 = phothash(q,g,kid,apsize,'time')
		photl0=phothash(q,g,kid,apsize,'phot')
		mom = moment(photl0,/nan,maxmoment=2,sdev=sdev,mean=mn,/double)
		photl0[where(ABS(photl0-mn) GT 5d0*sdev,/null)] = !VALUES.D_NAN

		; Get SF of each quarter
        	if (fast ne 3) then begin
	   		sfast = strtrim(string(fast),2)
			print,'SF on phot for quarter '+sq
			; Structure Function and SDF of Quarter
                        if (where(nanq0 eq q) eq -1) then begin
			   ; File for SDF
			   ;;;;;;;;;
			   ; If we already have a saveset skip both sdf and sf
	   		   ;;;test = file_search(file,count=count)
			   count = 0
	                   if (count eq 0) then begin
			      ; SDF of Quarter
			      filesdf = '../graphs/final/plotsdf'+skid+'_ap'+sap+'_Q'+sq+'.eps'
                              sd = spectraldensity(tl0,photl0,binFreq=binFreq,binSDF=binSDF,freq=freq,yfit=yfit,pars=pars,title='KIC '+skid+', '+'Q'+sq,plt=plt,noplot=1)
			      ;plt.save,filesdf,border=1
			      print,'plotlc: SDFs not creeated or saved'
           	              file='../sf/phot/sf_'+skid+'_'+sq+'_'+sfast+'.sav'
            	              ;sfphot=sf(tl0,photl0/mean(photl0,/nan),tau=tau,nnt=nnt,fast=fast)
			      tau2 = 2./3.*(tl0[-1]-tl0[0])
            	              sfpair=strucfunc(tl0,photl0,tau2=tau2,sdevmax=5)
			      tau = sfpair[*,0]
			      sfphot = sfpair[*,1]
			      ;plt = scatterplot(tau,sfphot,symbol='dot')
            		      save,sfphot,tau,sd,binFreq,binSDF,freq,yfit,file=file
			      openw,12,'../sdf_pars.txt',/append
			      printf,12,format='(i9,1x,i2,4(1x,f5.2))',kid,q,pars
			      close,12
			  endif
			endif

		endif
		; Concatenate all of the quarters
		if (q ne quarters[0]) then begin
		   tl.add,tl0
		   photl.add,photl0
		   bkgndl.add,phothash(q,g,kid,apsize,'bkgnd')
		   asyml.add,phothash(q,g,kid,apsize,'asym')
		   f3f5l.add,phothash(q,g,kid,apsize,'f3f5')
	        endif
	endelse
endfor
; nq is now number of quarters obtained
nq = n_elements(photl)

; If less than 5 quarters,  no shift and subtract 
if (nq lt 5) then shiftsub0 = 0
if (nq eq 1) then stitch0 = 0
q0 = quarters[0]
q1 = quarters[0]+ nq -1

; Take out constant rate of sensitivity loss with time
;; Removed code because this is now done in photaquarter
;midtime = tl[nq/2,delta]
;midtime = tl[0,delta]
;if (slope0 ne 0) then begin
;   for  q = 0, nq-1 do begin
;	; Add sensitivity evolution
;	if tl[q] eq !NULL then continue
;	sen = 1d0 + (tl[q]-midtime)*slope0/3.65d2/1d2
;	photl[q] *= sen
;	bkgndl[q] *= sen
;   endfor
;endif

for q = 0, nq-1 do begin
	if tl[q] eq !null then continue
	if (total(finite(photl[q])) eq 0) then begin
		tl[q] = !null
		photl[q] = !null
		continue
	endif
	tl[q] = tl[q,partday-1:-1:partday]
        photl[q]=smooth(photl[q],partday,/nan,/edge_mirror)
	bkgndl[q]=smooth(bkgndl[q],partday,/nan,/edge_mirror)
	asyml[q]=smooth(asyml[q],partday,/nan,/edge_mirror)
	f3f5l[q]=smooth(f3f5l[q],partday,/nan,/edge_mirror)
	photl[q] = photl[q,partday-1:-1:partday]
	bkgndl[q] = bkgndl[q,partday-1:-1:partday]
	asyml[q] = asyml[q,partday-1:-1:partday]
	f3f5l[q] = f3f5l[q,partday-1:-1:partday]
endfor

for q = 0,nq-1 do begin
	if (llc) then begin
	        if (total(finite(llcl[q])) eq 0) then continue
		llcl[q]=smooth(llcl[q],partday,/nan,/edge_mirror)
		llcl[q] = llcl[q,partday-1:-1:partday]
		llctime[q] = llctime[q,partday-1:-1:partday]
	endif
endfor

; For each quarter
for q = 0,nq-1 do begin
	if tl[q] eq !null then continue
	; clean background of outliers
	for rrr = 0, 2 do begin
		smbck=smooth(bkgndl[q],day*4,/nan,/edge_mirror)
		subbck = bkgndl[q]-smbck
		stdev = stddev(subbck,/nan)
		ngood = where(abs(subbck)/stdev gt 3.,nngood)
		if (nngood gt 0) then bkgndl[q,ngood] = smbck[ngood]
	endfor
	;clean lightcurve of outliers
;	for rrr = 0, 3 do begin
;		smfot=smooth(photl[q],day*10,/nan,/edge_mirror)
;		subfot = photl[q]-smfot
;		stdev = stddev(subfot,/nan)
;		nogood = where(abs(subfot)/stdev gt 4.,nnogood)
;		if (nnogood gt 0) then photl[q,nogood] = smfot[nogood]
;	endfor
	;clean PDC lightcurve of outliers
	if llc then begin
	   for rrr = 0, 3 do begin
		smfot=smooth(llcl[q],day*10,/nan,/edge_mirror)
		subfot = llcl[q]-smfot
		stdev = stddev(subfot,/nan)
		nogood = where(abs(subfot)/stdev gt 4.,nnogood)
		if (nnogood gt 0) then llcl[q,nogood] = smfot[nogood]
	   endfor
	endif

endfor

stdevarr = dblarr(12) + !values.d_nan
if llc then for q = 0, nq-1 do stdevarr[q+q0-6] = stddev(llcl[q],/nan)
shiftsubstdevarr = dblarr(12) + !values.d_nan

; Stitch background
if (stitch0 ge 1) then begin
    for q = 0, nq-2 do begin
	qin = q
        if (where(nanq0 eq quarters[0]+qin) ne -1) then continue
	if tl[q+1] eq !null then continue
	while (tl[qin] eq !null ||where(nanq0 eq quarters[0]+qin) ne -1 ) $
		do qin--
	if (total(finite(bkgndl[q+1])) eq 0) then continue 
	if (total(finite(bkgndl[qin])) eq 0) then qin-- 
	stitch,bkgndl[qin],bkgndl[q+1],tl[qin],tl[q+1],delta,c  
	if c[0] eq -1 then stop
	bkgndl[q+1] = c
    endfor
endif

if (bcon ne 0) then begin
   j1 = apsize^2*bcon
   mindev = 1d20
   for j = -j1, j1  do begin
	dev = 0d0
   	for  q = 0, nq-1 do begin
        	; Subtract adjustable background to photometry
		if (tl[q] eq !NULL) then continue
		if (total(finite(photl[q])) eq 0) then continue 
		fot = photl[q] - bkgndl[q]*double(j)/20d0
		fot2 = (fot - shift(fot,-96))^2
		dev = dev + total(fot2[0:-98],/nan)
		if (dev lt mindev) then begin
			jmin = j
			mindev = dev
		endif
     	endfor
     endfor
     print,'plotlc: Best background at ',jmin
     ; Have jmin and can subtract best background level
     for q = 0, nq-1 do begin
	     if (tl[q] eq !NULL) then continue
	     if (total(finite(photl[q])) eq 0) then continue 
	     photl[q] -= bkgndl[q]*double(jmin)/20d0
     endfor
endif
	
;stitch quarters together for pdc and photl
if (stitch0 ge 1) then begin
    for q = 0, nq-2 do begin
	qin = q
        if (where(nanq0 eq quarters[0]+q+1) ne -1) then continue
	while (where(nanq0 eq quarters[0]+qin) ne -1) do qin--
	if (qin lt 0) then continue
	if (qin ne q) then delta0 = 2.0d0*delta else delta0 = delta
	if (llc && total(finite(llctime[q+1])) ne 0) then begin 
		stitch,llcl[qin],llcl[q+1],llctime[qin],llctime[q+1],delta0,c 
		if c[0] eq -1 then stop
		llcl[q+1] = c
	endif
	if (stitch0 eq 2) then if (q eq 3 or q eq 7) then continue
	qin = q
	while (tl[qin] eq !NULL || $
		where(nanq0 eq quarters[0]+qin) ne -1) do qin--
	; May want to not stitch year 1 with year 2
	if (tl[q+1] eq !NULL) then continue
	if (total(finite(photl[q+1])) eq 0) then continue 
	if (total(finite(photl[qin])) eq 0) then qin-- 
	stitch,photl[qin],photl[q+1],tl[qin],tl[q+1],delta0,c 
	if (kid eq 8094413 and qin eq 0) then  begin
		print,'8094413 stitch test'
		print,c[0],photl[qin,1],photl[q+1,1]
	        c = photl[q+1]*7345./photl[1,1] 
		print,c[1]
	endif
	if c[0] eq -1 then stop
	photl[q+1] = c
    endfor
endif 

;openw,/append,/get_lun,wunit,"../llcdev2.txt"
;printf,wunit,skygroup,kid,mean(llcl[0],/nan),stdevarr,format='(i2,1x,i9,13e10.3)'
;free_lun,wunit

; NANQ
if (nanq0[0] ne 0) then begin
	for i = 0, n_elements(nanq0)-1 do begin
		for j=0, nq-1 do begin
		    if (nanq0[i] eq quarters[0]+j) then begin
		        if (tl[j] ne !NULL) then photl[j,*] = !values.d_nan
			if llc then if (llctime[j] ne !NULL) then llcl[j,*] = !values.d_nan
		    endif
		endfor
	endfor
endif


; Turn list into an array for times and lc
times=tl[0]
phots=photl[0]
for q = 1,nq-1 do begin
	times = [times,tl[q]]
	phots =  [phots,photl[q]]
endfor

; Smooth over smdays
smphots = smooth(phots,smdays*day,/nan,/edge_mirror)

; Create smphotss
nt = n_elements(times)
if (shiftsub0 ne 0) then begin
	; Create array of smoothed data shifted by 1 Kepler year.
	; Start with photss as all NaNs
	photss = dblarr(nt)
	photss[*] = !values.d_nan
	; Shift chunks of phots to new times in photss
	if (shiftsub eq 1) then begin
	    for i = 0, nt-day, day*10 do begin
		shifti = (where(times[i:*] gt times[i]+373d0))[0]
		if (i+shifti gt nt-(day*10+1)) then break
		if (shifti ne -1) then $
			photss[i+shifti] = smphots[i:i+(day*10-1)]
	    endfor
	endif
	if (shiftsub0 eq -1) then begin
	    for i = 0, nt-1, day*10 do begin
		shifti = (where(times[i:*] gt times[i]+373d0))[0]
		if (shifti eq -1) then begin
;			extra = smphots[lastshift:*]
;			photss[firstnan] = extra
;			firstnan = firstnan + n_elements(extra)
			break
		endif
		if (shifti ne -1) then begin
			if (i+shifti+day*10-1 gt nt-1) then begin
				photss[i] = smphots[i+shifti:*] 
	     			firstnan = i + n_elements(smphots[i+shifti:*])
			endif else $
				photss[i] = smphots[i+shifti:i+shifti+(day*10-1)]
			;lastshift = i + shifti+day*10
		endif
	     endfor
	endif

	; Finished shift, now subtract or divide
	shiftdivide = 1
	if shiftdivide then begin
		photss = phots/photss*mean(photl[0],/nan)
	endif else begin
		photss = phots -  photss
		; Bring photss back up to mean level of phots
		photss += mean(photl[0],/nan) - mean(photss,/nan)
	endelse
	; This process loses the sensitivity fix, so put it back
	;photss *= 1d0 + (times-midtime)*slope0/3.65d2/1d2

	; Smooth photss
	smphotss = smooth(photss,2*smdays*day,/nan,/edge_mirror,$
		missing=!values.d_nan)
	whfinite =  where(finite(photss),ncount)
	if ncount ne 0 then  begin
		first = whfinite[0]
		last =  whfinite[-1]
	endif else begin
		first = 0
		last = n_elements(photss) - 1
	endelse

	; Take out slope in shiftsub
;	if (shiftsub0 eq 7) then begin
	;if (shiftsub0 ne 0) then begin
;;;	   last = last - delta
;;;	   first = first + delta
;;;	   dt = times[last]-times[first]
;;;	   slope2 =  (smphotss[last]-smphotss[first])/dt
;;;	   fit = slope2*(times-times[first])/smphotss[first]+1d0
;;;	   photss /= fit
;;;	   smphotss /= fit
;	endif
endif

if (nanq0[0] ne 0 and llc) then begin
	for q = quarters[0], quarters[1] do $
		if (where(nanq0 eq q) ne -1) then $
			llcl[q-quarters[0],*] = !values.d_nan
endif


times=tl[0]
phots=photl[0]
bkgnds=bkgndl[0]
asyms=asyml[0]
f3f5s=f3f5l[0]
for q = 1,nq-1 do begin
	help,tl[q],photl[q]
	times = [times,tl[q]]
	phots =  [phots,photl[q]]
	bkgnds = [bkgnds,bkgndl[q]]
	asyms =  [asyms,asyml[q]]
	f3f5s =  [f3f5s,f3f5l[q]]
endfor
smphots = smooth(phots,smdays*day,/nan,/edge_mirror)
smphots[where(finite(phots,/nan),/null)] = !VALUES.D_NAN
nt = n_elements(times)

if (llc) then begin
	llctimes = llctime[0]
	llcs = llcl[0]
	for q = 1,nq-1 do begin
		llcs = [llcs,llcl[q]]
		llctimes = [llctimes,llctime[q]]
	endfor
endif




; Remove extremes from phots
photssmooth = smooth(phots,48,/nan)
devphots=MeanAbsdev(phots,/nan,/double)
outliers = where(abs(phots-photssmooth) gt 5d0*devphots,/null)
phots[outliers] = !VALUES.D_NAN

meanphot = mean(phots,/nan)
if (norm eq 1) then begin
	divide = meanphot
	if (llc) then $
		llcdiv = mean(llcs,/nan) 
endif else begin
	divide = 1d0
	llcdiv = 1d0
endelse
devphots /= divide

if (llc) then $
	devllc = MeanAbsdev(llcs,/nan,/double)/llcdiv
devsm=MeanAbsdev(smphots,/nan,/double)/divide
print,'plotlc: MeanAbsDev(smooth): ', devsm

;;;;;;; To output mag
;;phots = -2.5*alog10(phots/229087.)+12.006
;;;;;;

minphots=min(phots,/nan)/divide
maxphots=max(phots,/nan)/divide
;minphots=min((phots-smphots) + meanphot,/nan)/divide
;maxphots=max((phots-smphots) + meanphot,/nan)/divide
if (shiftsub0 ne 0) then begin
	if (norm eq 1) then $
		divides = mean(photss[first:*],/nan) else divides = 1d0
	if (shiftsub0 eq 1) then begin
		photss[0:first-1] = !values.d_nan
		smphotss[0:first-1] = !values.d_nan
	endif else begin 
		photss[firstnan:*] = !values.d_nan
		smphotss[firstnan:*] = !values.d_nan
	endelse
	devsmss = MeanAbsdev(smphotss/divides,/nan,/double)
	print,'plotlc: MeanAbsDev(smooth ss): ', devsmss
endif

if apsize eq 5 then title1 = 'KIC '+skid+',  5x5 pix'
if apsize eq 3 then title1 = 'KIC '+skid+',  3x3 pix'
title1 += ',  cps: '+strtrim(string(meanphot,format='(f10.2)'),1) 
;title1 += ',slope='+string(format='(f4.1)',slope)
title1 += ',CBVs ='+string(format='(i1,",",i2)',vlim)
;title1 += ',sharp='+string(format='(I1)',findsharp)


; PLOTS
laycols = 1
layrows = 2
layplot = 1
if (norm eq 1) then ytitle='Counts Normalized' else ytitle='Counts per sec'
;if (norm eq 1) then ytitle='Counts Normalized' else ytitle='Kepmag [Mag]'
if (noplot ne 2) then begin
	; Plot photometry points in black
	xshowtext = ~llc
	graph = plot(times,phots/divide,$
		layout=[laycols,layrows,layplot++],dimensions=[8.5,11.0]*60.,$
		symbol='dot',linestyle='none',$
		xrange=[times[0],times[-1]],xtitle = 'Time [MJD - 54,833]',$
		yrange=[min(phots/divide,/nan),max(phots/divide,/nan)], $
		title=title1,ytitle=ytitle,xshowtext=xshowtext,font_size=14,$
		window_title=wtitle,$
		margin=[0.20,0.0,0.03,0.15],buffer=buffer)
;	graph = plot(/overplot,times,(phots-smphots+meanphot)/divide,symbol='dot',linestyle='',color='orange')
	; Plot bkgnd in red
	;graph = plot(times,(bkgnds+minphots)/divide,color=!color.red,/overplot,/current)
	; Plot bkgnd zero level at minimum of phots in red
	;graph = plot([times[0],times[-1]] ,[minphots,minphots],color=!color.red,/current,/overplot)
	; Plot vertical lines at quarter boundaries
	for i=0,nq-2 do begin
		if (tl[i] ne !null) then $
		graph2 = plot([tl[i,-1],tl[i,-1]],[minphots,maxphots],$
		/overplot,/current,linestyle='Dashed')
	endfor
	; Label quarters
	for i = 0,nq-1 do $
		if (tl[i] ne !null) then $
		text = text(tl[i,0]+10,minphots+(maxphots-minphots)*.15,'Q'+$
			strtrim(string(i+q0),1),/data,font_size=14)
		if (mean(phots[1:100],/nan)/divide gt 1) then yplace = .7 else yplace = .85
		text2 = text(.25,yplace,'AbsDev = '+strtrim(string(format='(e9.2)',devphots),2),$
			fill_background=1,fill_color=[255,255,255],font_size=14,font_name="Times")
; 		graph3 = plot(times,smphots/divide,/overplot,/current,color=!color.red)    
 		graph3 = plot(/overplot,[times[0],times[-1]],[1,1],linestyle='-')    
	if (shiftsub0 ne 0) then begin
	       graph4 = plot(/current,times,photss/divides,$
		symbol='dot',linestyle='none',color=!color.blue,$
		layout=[laycols,layrows,layplot++],xtitle='Time [MJD - 54,833]',$
		yrange=minmax([photss/divides,llcs/llcdiv],/nan),$
		margin=[.20,0.25,0.03,0.],xrange=[times[0],times[-1]],$
		font_size=14,ytitle="Shift and Subtract")
	        graph5 = plot(times,smphotss/divides, /overplot,/current,color=!color.brown)    
		;text3 = text(.25,.55,'AbsDev = '+$
		;	strtrim(string(format='(e9.2)',devsmss),2),font_size=13,font_name="Times")

	        ; plot smooth of shiftsub result
	        if llc then $
		   graph4 = plot(/overplot,/current,llctimes,llcs/llcdiv,$
		     symbol='dot',color=!color.light_green,linestyle='none')
	endif else begin
	    if llc then begin
		graph4 = plot(/current,llctimes,llcs/llcdiv,$
		   symbol='dot',linestyle='none',color=!color.red,$
		   layout=[laycols,layrows,layplot++],xtitle='Time [MJD - 54,833]',$
	   	   margin=[.20,0.25,0.03,0.],xrange=[times[0],times[-1]],$
		   font_size=14)
		graph4 = plot(/overplot,/current,[llctimes[0],llctimes[-1]],[1.,1.],$
		     linestyle='-')
		for i=0,nq-2 do begin
		   if (tl[i] ne !null) then $
		   graph2 = plot([tl[i,-1],tl[i,-1]],[min(llcs,/nan),max(llcs,/nan)]/llcdiv,$
	   	      /overplot,/current,linestyle='Dashed')
	        endfor
      	    endif
	endelse
	if llc then $
		text3 = text(.25,.45,'AbsDev = '+strtrim(string(format='(e9.2)',devllc),2),$
		fill_background=1,fill_color=[255,255,255],font_size=14,font_name="Times")
	; Add asym axis
	;graph3 = plot(/current,times[0:*],asyms[0:*],layout=[1,3,3],color=!color.purple,xtitle='Days',$
	;	font_size=9,margin=[0.20,0.15,0.03,0.0],ytitle='Asymmetry')
	
	; f3/f5 plot
;	graph3 = plot(times,f3f5s[0:*],layout=[laycols,layrows,layplot++],/current,color=!color.violet,$
;		xrange=[times[0],times[-1]], margin=[.20,0.25,0.03,0.])
	;ax3 = graph2.axes
	;ax3[0].hide=1
	filenm = '../graphs/final/plotlc_'+skid+'_ap'+sap+'_grp'+sskygroup
        filenm2 = '../graphs/final/plotlc_'+skid+'_ap'+sap+'_g'+sskygroup
	if keyword_set(ps) then begin
		print,"plotlc: Saving .eps of plot"
		if (llc) then $
			filenmeps = filenm+'_llc.eps' $
		else $
			filenmeps = filenm+'.eps'
		graph.save,filenmeps,bitmap=0,resolution=200
		spawn,'eps2eps '+filenmeps+ ' '+filenm2+'.eps'
		spawn,'mv -f '+filenm2+'.eps '+filenmeps
	endif
	if keyword_set(pdf) then begin
		print,"plotlc: Printing .pds of plot"
		filenmpdf = filenm+'.pdf'
		graph.save,filenmpdf,resolution=200
	endif
endif ; end noplot ne 2
if (write eq 1) then begin
	print,"plotlc: Saving phots and times to saveset"
	save,phots,times,filename='../lc/lc_'+skid+'_ap'+sap+'.sav'
;	phots2  = phots-smphots + meanphot
;	save,phots2,times,filename='../lc/lc_'+skid+'_ap'+sap+'.sav'
	if (shiftsub0 ne 0) then $
		save,photss,filename='../shiftsub/lcs_'+skid+'_ap'+sap+'.sav'
	if (llc ne 0) then $
		save,llcs,llctimes,filename='../pdc/pdc'+skid+'.sav'
endif
if (shiftsub0 eq -1) then begin
   for q = 0, nq-1 do begin
	if tl[q] eq !null then continue
	ind1=where(times ge tl[q,0]+1d0)
	ind2=where(times ge tl[q,-1]-1d0)
	shiftsubstdevarr[q+q0-6] = stddev(photss[ind1[0]:ind2[0]],/nan)
;	if finite(shiftsubstdevarr[q+q0-6]) then stop
    endfor
    openw,/append,/get_lun,wunit,"../shiftsubdev.txt"
    printf,wunit,skygroup,kid,mean(photss,/nan),shiftsubstdevarr,format='(i2,1x,i9,13e10.3)'
    free_lun,wunit
endif
return,[[phots],[times]]
end
