function plotlc,kid,phothash,quarters,skygroup,apsize,slope,stitch=stitch,$
	title=title,ps=ps,norm=norm, bcon=bcon,graph=graph,$
	c2=c2,days=days,shiftsub=shiftsub,write=write,noplot=noplot



if ~keyword_set(title) then title1=string(kid) else title1 = title
if ~keyword_set(write) then write=0
if ~keyword_set(stitch) then stitch=0
if ~keyword_set(slope) then slope=0
slope0=slope
if ~keyword_set(norm) then norm=0
if ~keyword_set(shiftfix) then shiftfix=0
if ~keyword_set(c2) then c2=1d0
if ~keyword_set(days) then days=0
if ~keyword_set(noplot) then noplot=0
if ~keyword_set(shiftsub) then shiftsub=0
shiftsub0 = shiftsub
if (shiftsub0 eq 0) then slope0 = 0
skid = 'kplr'+strtrim(string(kid),2)
sap = strtrim(string(apsize),2)
sskygroup = strtrim(string(skygroup),2)

if noplot eq 1 then buffer =1 else buffer = 0

smdays=7
first = 0
firstq = 0
g = skygroup

; nq is number of quarters to cover
nq = quarters[1]-quarters[0]+1

; Make lists of the each data from phothash
tl = list(phothash(quarters[0],g,kid,apsize,'time'))
photl = list(phothash(quarters[0],g,kid,apsize,'phot'))
bkgndl = list(phothash(quarters[0],g,kid,apsize,'bkgnd'))
asyml =  list(phothash(quarters[0],g,kid,apsize,'asym'))
f3f5l = list(phothash(quarters[0],g,kid,apsize,'f3f5'))
for q = quarters[0]+1, quarters[1] do begin
	if (where(phothash[q,g].keys() eq kid) EQ -1) then continue
	tl.add,phothash(q,g,kid,apsize,'time')
	photl.add,phothash(q,g,kid,apsize,'phot')
	bkgndl.add,phothash(q,g,kid,apsize,'bkgnd')
	asyml.add,phothash(q,g,kid,apsize,'asym')
	f3f5l.add,phothash(q,g,kid,apsize,'f3f5')
endfor
; nq is now number of quarters obtained
nq = n_elements(photl)
; If less than 5 quarters,  no shift and subtract 
if (nq lt 5) then shiftsub0 = 0


; For each quarter
for i = 0,nq-1 do begin
	; clean background of outliers
	for rrr = 0, 2 do begin
		smbck=smooth(bkgndl[i],48*4,/nan,/edge_mirror)
		subbck = bkgndl[i]-smbck
		stdev = stddev(subbck,/nan)
		ngood = where(abs(subbck)/stdev gt 3.,nngood)
		if (nngood gt 0) then bkgndl[i,ngood] = smbck[ngood]
	endfor
	for rrr = 0, 2 do begin
		smfot=smooth(photl[i],48*10,/nan,/edge_mirror)
		subfot = photl[i]-smfot
		stdev = stddev(subfot,/nan)
		nogood = where(abs(subfot)/stdev gt 3.,nnogood)
		if (nnogood gt 0) then photl[i,nogood] = smfot[nogood]
		;print,i,rrr,stdev,nngood
	endfor

	; Slightly smooth each quarter's lc
	photl[i]=smooth(photl[i],24,/nan,/edge_mirror)
endfor
q0 = quarters[0]
q1 = quarters[0]+nq-1
ksen = dblarr(nq-1)
ll = 48*6
midtime = tl[nq/2,ll]
;stitch quarters together for lc
if (stitch ge 1) then begin
    for i = 0, nq-2 do begin
	rate = (mean(photl[i,-ll:-1],/nan)-mean(photl[i,-2*ll:-ll-1],/nan))/$
	          (mean(tl[i,-ll:-1],/nan)-   mean(tl[i,-2*ll:-ll-1],/nan))
        change = rate*(mean(tl[i+1,0:2*ll-1],/nan)-mean(tl[i,-2*ll:-1],/nan))
	value = mean(photl[i,-ll:-1],/nan) + change
	ksen[i] = value/mean(photl[i+1,0:ll-1],/nan)
	; May want to not stitch year 1 with year 2
	if (stitch eq 2) then if (i eq 3 or i eq 7) then ksen[i] = 1.d0
	photl[i+1] = ksen[i]*photl[i+1]
    endfor
endif else ksen[*]=1.d0

; Turn list into an array for times and lc
times=tl[0]
phots=photl[0]
for i = 1,nq-1 do begin
	times = [times,tl[i]]
	phots =  [phots,photl[i]]
endfor

; Smooth lc over smdays
smphots = smooth(phots,smdays*48,/nan,/edge_mirror)

; Create smphotss
nt = n_elements(times)
if (shiftsub0 ne 0) then begin
	; Create array of smoothed data shifted by 1 Kepler year.
	; Start with photss as all NaNs
	photss = dblarr(nt)
	photss[*] = !values.d_nan
	; Shift chunks of phots to new times in photss
	if (shiftsub eq 1) then begin
	    for i = 0, nt-481, 480 do begin
		shifti = (where(times[i:*] gt times[i]+373d0))[0]
		if (i+shifti gt nt-481) then break
		if (shifti ne -1) then $
			photss[i+shifti] = smphots[i:i+479]
	    endfor
	endif
	if (shiftsub0 eq -1) then begin
	    for i = 0, nt, 480 do begin
		shifti = (where(times[i:*] gt times[i]+373d0))[0]
		if (i+shifti gt nt-481) then break
		if (shifti ne -1) then $
			photss[i] = smphots[i+shifti:i+shifti+479]
	     endfor
	     firstnan = (i-1)+479
	endif
;;	; Finished shift, now subtract
;;	photss = phots -  photss
;;	; Bring photss back up to mean level of phots
;;	photss += mean(photl[4],/nan) - mean(photss,/nan)
	photss = phots/photss*mean(photl[4],/nan)
	; Smooth photss
	smphotss = smooth(photss,2*smdays*48,/nan,/edge_mirror,$
		missing=!values.d_nan)

	; Take out slope in shiftsub
	if (shiftsub0 eq 1) then begin
	first =  (where(finite(photss)))[0]
	firstq = 4
	dt = times[-ll]-times[first+ll]
	slope2 =  (smphotss[-ll]-smphotss[first+ll])/dt
	fit = slope2*(times-times[first+ll])/smphotss[first]+1d0
	photss /= fit
	smphotss /= fit
	endif
endif

;midtime = (tl[-1,-1]-tl[0,0])/2d0
if (apsize eq 5) then begin
for  q = 0, nq-5 do begin
        ; Subtract adjustable background to photometry
	bck = bkgndl[q]
	fot0 = photl[q]
	j1 = apsize^2*0
	mindev = 1d20
	for j = -j1, j1  do begin
		fot = fot0 - bck*double(j)/20d0
		dev = meanabsdev(fot,/nan,/double)/mean(fot,/nan)
		if dev lt mindev then begin
			jmin =j
			mindev = dev
		endif
	endfor
	;PRINT,'plotlc: Bck Adjust: ',double(jmin)/1d1
	photl[q] -= bck*double(jmin)/10d0
	q2 = q+4
	photl[q2] -= bkgndl[q2]*double(jmin)/10d0
	
	; Add sensitivity evolution
	;sen = 1d0 + (tl[q]-midtime)*slope0/3.65d2/1d2
	;photl[q] *= sen
	;bkgndl[q] *= sen
endfor
endif
; stitch background
if (stitch ge 1) then begin
    for q = 0, nq-2 do begin
	rate = (mean(bkgndl[q,-ll:-1],/nan)- mean(bkgndl[q,-2*ll:-ll-1],/nan))/$
	       (mean(tl[q,-ll:-1],/nan)- mean(tl[q,-2*ll:-ll-1],/nan))
        change = rate*(mean(tl[q+1,0:2*ll-1],/nan)-mean(tl[q,-2*ll:-1],/nan))
	value = mean(bkgndl[q,-ll:-1],/nan) + change
	ksen[q] = value/mean(bkgndl[q+1,0:ll-1],/nan)
	if (stitch eq 2) then if (q eq 3 or q eq 7) then ksen[q] = 1.d0
	bkgndl[q+1] = ksen[q]*bkgndl[q+1]
    endfor
endif else ksen[*] = 1d0 

if (stitch ge 1) then begin
    for q = 0, nq-2 do begin
	rate = (mean(photl[q,-ll:-1],/nan)-mean(photl[q,-2*ll:-ll-1],/nan))/$
	          (mean(tl[q,-ll:-1],/nan)-   mean(tl[q,-2*ll:-ll-1],/nan))
        change = rate*(mean(tl[q+1,0:2*ll-1],/nan)-mean(tl[q,-2*ll:-1],/nan))
	value = mean(photl[q,-ll:-1],/nan) + change
	ksen[q] = value/mean(photl[q+1,0:ll-1],/nan)
	if (stitch eq 2) then if (q eq 3 or q eq 7) then begin
		ksen[q] = mean(photl[0],/nan)/mean(photl[q+1],/nan)
	endif
	photl[q+1] = ksen[q]*photl[q+1]
    endfor
endif else ksen[*]=1d0

times=tl[0]
phots=photl[0]
bkgnds=bkgndl[0]
asyms=asyml[0]
f3f5s=f3f5l[0]
for q = 1,nq-1 do begin
	times = [times,tl[q]]
	phots =  [phots,photl[q]]
	bkgnds = [bkgnds,bkgndl[q]]
	asyms =  [asyms,asyml[q]]
	f3f5s =  [f3f5s,f3f5l[q]]
endfor
smphots = smooth(phots,smdays*48,/nan,/edge_mirror)
nt = n_elements(times)

meanphot = mean(phots,/nan)
if (norm eq 1) then divide = meanphot else divide = 1d0
devsm=MeanAbsdev(smphots/divide,/nan,/double)
print,'plotlc: MeanAbsDev(smooth): ', devsm
minphots=min(phots,/nan)
maxphots=max(phots,/nan)
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

if apsize eq 5 then title1 = skid+',  5x5 pix'
if apsize eq 3 then title1 = skid+',  3x3 pix'
title1 = title1 +',  cps: '+strtrim(string(meanphot,format='(f10.2)'),1) 

; PLOTS
if (norm eq 1) then ytitle='Counts Normalized' else ytitle='Counts per sec'

	; Plot photometry points in black
	graph = plot(times[0:-1:12],phots[0:-1:12]/divide,$
		layout=[1,2,1],dimensions=[512,256],$
		symbol='dot',linestyle='none',$
		xrange=[times[0],times[-1]],$
		title=title1,ytitle=ytitle,xshowtext=0,font_size=9,$
		margin=[0.11,0.0,0.05,0.15],buffer=buffer)
	; Plot bkgnd in green
	;graph = plot(times[0:-1:24],(bkgnds[0:-1:24]+minphots)/divide,color=!color.green,/overplot)
	; Plot bkgnd zero level at minimum of phots in green
	;graph = plot([times[0],times[-1]] ,[minphots,minphots]/divide,color=!color.green,/overplot)
	; Plot vertical lines at quarter boundaries
	for i=0,nq-2 do $
		graph2 = plot([tl[i,-1],tl[i,-1]],[minphots,maxphots]/divide,$
		/overplot)
	; Label quarters
	for q = q0,q1-1 do $
		text = text(tl[q-q0,0]+35,minphots/divide,'Q'+$
			strtrim(string(q),1),/data)
		text2 = text(.13,.85,'AbsDev = '+$
			strtrim(string(format='(e10.3)',devsm),2),font_size=10)
		graph3 = plot(times[0:-1:12],smphots[0:-1:12]/divide,$
		       	/overplot,color=!color.red)    

;if (shiftsub0 eq 1) then begin
;   ax2 = graph.axes
;   ax2[0].hide=0
;endif
; shiftsub result plot
if (shiftsub0 ne 0) then begin
	graph4 = plot(/current,times[0:-1:24],photss[0:-1:24]/divides,$
		symbol='dot',linestyle='none',color=!color.blue,$
		layout=[1,2,2],xtitle='Time [Days]',$
		margin=[.11,0.25,.05,0.],xrange=[times[0],times[-1]],$
		font_size=9,ytitle="Shift and Subtract")
	text3 = text(.13,.42,/current,$
		'AbsDev = '+strtrim(string(format='(e10.3)',devsmss),2),$
		font_size=10)
	; plot smooth of shiftsub result
	graph5 = plot(times[0:-1:48],smphotss[0:-1:48]/divides, /overplot,color=!color.brown)    
endif

; Add asym axis
;graph3 = plot(/current,times[0:*],asyms[0:*],layout=[1,3,3],color=!color.purple,xtitle='Days',$
;	font_size=9,margin=[0.15,0.15,0.05,0.0],ytitle='Asymmetry')

; f3/f5 plot
;graph3 = plot(times[0:*],f3f5s[0:*],/overplot,color=!color.violet)
;ax3 = graph2.axes
;ax3[0].hide=1
filenm = '../graphs/plotlc_'+skid+'_ap'+sap+'_grp'+sskygroup
filenm2 = '../graphs/plotlc_'+skid+'_ap_'+sap+'_grp'+sskygroup
if keyword_set(ps) then begin
	filenmeps = filenm+'.eps'
	graph.save,filenmeps,bitmap=0,resolution=200
	spawn,'eps2eps '+filenmeps+ ' '+filenm2+'.eps'
	spawn,'mv -f '+filenm2+'.eps '+filenmeps
endif
if keyword_set(pdf) then begin
	filenmpdf = filenm+'.pdf'
	graph.save,filenmpdf,resolution=200
endif
if (write eq 1) then begin
	save,phots,times,filename='../lc/lc_'+skid+'_ap'+sap+'.sav'
	if (shiftsub0 ne 0) then $
		save,photss,filename='../shiftsub/lcs_'+skid+'_ap'+sap+'.sav'
endif
return,phots
end
