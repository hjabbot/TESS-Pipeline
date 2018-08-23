pro allforone,kid,apsize,gotablearr,phothash,quarters=quarters,write=write,llc=llc,$
	vlim=vlim,slope=slope,nanq=nanq,fast=fast,norm=norm,stitch=stitch,photst=photst,$
	ymajor=ymajor,ps=ps,bcon=bcon,shiftsub=shiftsub,$
	skip=skip, findsharp=findsharp,fittime=fittime,tv=tv,bestq=bestq
common bplf, frq, pdf0
if (N_PARAMS() eq 0) THEN BEGIN
	print,'Usage: allforone,kid,apsize,gotablearr,phothash,quarters=quarters,write=write,$'
	print,'slope=slope,nanq=nanq,shiftsub=shiftsub,fast=fast,stitch=stitch,llc=llc,$'
	print,'skip=skip,vlim=vlim,ps=ps,bcon=bcon,norm=norm,bestq=bestq,$'
	print,'ymajor=ymajor,findsharp=findsharp,photst=photst,fittime=fittime,tv=tv'
	return
endif

skygroup=skygroupof(gotablearr,kid)
sskygroup = strtrim(string(skygroup),2)
sap = strtrim(string(apsize),2)
skid = strtrim(string(kid),2)
q=quartersof(gotablearr,kid)
if ~keyword_set(quarters) then quarters0=minmax(q) else quarters0 = quarters
if ~keyword_set(stitch) then stitch0=0 else stitch0 = stitch
if ~keyword_set(vlim) then vlim=0d0
if ~keyword_set(ymajor) then ymajor= -1
if ymajor EQ -1 then yminor = -1
if ~keyword_set(ps) then ps=0
if ~keyword_set(tv) then tv=0
if ~keyword_set(bcon) then bcon=0
if ~keyword_set(nanq) then nanq=0
if ~keyword_set(norm) then norm=0
skygroups=[skygroup,skygroup]
if (nanq[0] ne 0) then $
	for i=0,n_elements(nanq)-1 do $
		if (quarters0[0] eq nanq[i]) then $
			quarters0[0] += 1
noplot = 1
   print,'APSIZE: ',apsize
   ;if skip eq 0 then $
   ;;;;; Commented out if phothash has everything needed
   read_targ,gotablearr,quarters0,skygroups,apsize,kid=kid,vlim=vlim,tv=tv,$
	fittime=fittime,phothash=phothash,noplot=noplot,findsharp=findsharp,$
	slope=slope

   ; If no entities in the last quarter(s), have to reduce quarters[1]
   q2=intarr(2)
   q3=intarr(2)
   ; Find first quarter with data in this skygroup
   
   qq = quarters0[0]
   while ( ~phothash.HasKey(qq) || ~isa(phothash[qq],'HASH')|| ~phothash[qq].HasKey(skygroup)) do qq++ 
   q2[0] = qq
   ; Find last quarter with data in this skygroup
   qq = quarters0[1]
   while ( ~phothash.HasKey(qq) || ~isa(phothash[qq],'HASH')|| ~phothash[qq].HasKey(skygroup)) do qq--
   q2[1] = qq

   ; Find first quarter with data in this kid
   qq = q2[0]
   while   (~phothash[qq].HasKey(skygroup) || ~phothash[qq,skygroup].HasKey(kid)) do qq++
   q3[0] = qq
   ; Find last quarter with data in this kid
   qq = q2[1]
   while (~phothash[qq].HasKey(skygroup) || ~phothash[qq,skygroup].HasKey(kid)) do qq--
   q3[1] = qq

   ; Call plotlc
   if  skip  ne 2 then $
   photst = plotlc(kid,phothash,q3,skygroup,apsize,stitch=stitch0,norm=norm,shiftsub=shiftsub,write=write,llc=llc,nanq=nanq,bcon=bcon,findsharp=findsharp,vlim=vlim,fast=fast,ps=ps)

        filename = '../graphs/final/plotlc_'+skid+'_ap'+sap+'_grp'+sskygroup+'_llc.eps'
	;spawn,'gv '+filename
	return
	  ; print,' Pick best quarter'
	   ;bestq = ''
	   ;read, sbestq
	   sbestq = strtrim(string(bestq),2)
	   ;bq = fix(bestq)
	   bt = phothash(bestq,skygroup,kid,apsize,'time')
           bphot = phothash(bestq,skygroup,kid,apsize,'phot')
	   divide = mean(bphot,/nan)
	   ; Plot best quarter
           if apsize eq 5 then title1 = 'KIC '+skid+',  5x5 pix'
           if apsize eq 3 then title1 = 'KIC '+skid+',  3x3 pix'
           wtitle = title1
           title1 += ', CBV='+string(format='(i1,"-",i2)',vlim)
	   graph = plot(bt,bphot/divide,$
	      layout=[1,3,1],dimensions=[8.5,11.0]*60.,$
	      symbol='dot',linestyle='none',$
	      xrange=[bt[0],bt[-1]],$
	      yrange=[min(bphot/divide,/nan),max(bphot/divide,/nan)], $
	      title=title1,ytitle=ytitle,xshowtext=xshowtext,font_size=16,$
	      window_title=wtitle,margin=[0.20,0.0,0.03,0.15],buffer=buffer)  
           text = text(.25,.9,'Q'+sbestq,font_size=16)
	   graph = plot(/overplot,[bt[0],bt[-1]],[1.,1.],thick=2,/current)
           ; Under that, plot llc 
           llcl = read_llc(kid, q3, /kepler,llctime)
	   bllc = llcl[bestq-q3[0]]
	   bllct = llctime[bestq-q3[0]]
           graph = plot(/current,bllct,bllc/mean(bllc,/nan),$
		symbol='dot',linestyle='none',color=!color.red,$
		layout=[1,3,2],xtitle='Time [MJD - 54,833]',$
		margin=[.20,0.25,0.03,0.],xrange=[bllct[0],bllct[-1]],$
		font_size=16)
	   graph = plot(/overplot,[bllct[0],bllct[-1]],[1.,1.],$
		     linestyle='-',/current)

; These commented lines are for SF of sewn together LCs
;     restore,'../lc/lc_KIC'+skid+'_ap'+sap+'.sav'
;     sfphots=sf(times,phots/mean(phots,/nan),tau=tauphots,nnt=nnt,fast=fast)

;     restore,'../pdc/pdcKIC'+skid+'.sav'
;     sfpdc=sf(llctimes,llcs/mean(llcs,/nan),tau=taupdc,nnt=nnt,fast=fast)

;     if (shiftsub and q3[1]-q3[0] gt 3) then begin
;    	restore,'../shiftsub/lcs_KIC'+skid+'_ap'+sap+'.sav'
;    	sfphotss=sf(times,photss/mean(photss,/nan),tau=tauphotss,nnt=nnt,fast=fast)
;    	graph = plot(tauphotss,sfphotss,/current,layout=[1,4,4],$
;		/xlog,/ylog,thick=3,sym_thick=2,margin=[0.20,0.30,0.03,0.0],$
;	 xtitle='$\tau$ [Days]',ytitle='Structure Fn',font_size=14,color='blue',$
;	 yrange=[min([sfphots,sfphotss,sfpdc],/nan)*.9,max([sfphots,sfphotss,sfpdc],/nan)*1.1])
;    	graph = plot(/overplot,taupdc,sfpdc,linestyle='Dashed',$
;		thick=2,color='red')
;     endif else begin

     sfast = strtrim(string(fast),2)
     ; Plot of SF
     for q = q3[0], q3[1] do begin
	 whnanq= where(nanq eq q)
	 if whnanq ne -1 then continue
	 sq = strtrim(string(q),2)
	 ; Restore file with sfphot, tau, sd, binFreq, binSDF, freq, yfit
         restore,'../sf/phot/sf_'+skid+'_'+sq+'_'+sfast+'.sav'
	    sfphots = smooth(sfphot,2)
	    sfphot[where(tau gt 0.1)] = sfphots[where(tau gt 0.1)]
	    sfphots = smooth(sfphot,6)
	    sfphot[where(tau gt 1.)] = sfphots[where(tau gt 1.)]
	    sfphots = smooth(sfphot,18)
	    sfphot[where(tau gt 10.)] = sfphots[where(tau gt 10.)]
	 ; Now restore saveset with sfpdc,sftau
         restore,'../sf/llc/sfllc_'+skid+'_'+sq+'_'+sfast+'.sav'
	    sfpdcs = smooth(sfpdc,2)
	    sfpdc[where(sftau gt 0.1)] = sfpdcs[where(sftau gt 0.1)]
	    sfpdcs = smooth(sfpdc,6)
	    sfpdc[where(sftau gt 1.)] = sfpdcs[where(sftau gt 1.)]
	    sfpdcs = smooth(sfpdc,18)
	    sfpdc[where(sftau gt 10.)] = sfpdcs[where(sftau gt 10.)]
	 if q eq bestq then color = 'blue' else color = 'black'
	 if q eq bestq then color2 = 'violet' else color2 = 'red'
	 if q eq bestq then thick = 2 else thick = 1
	 if (q eq q3[0]) then begin
	    sfphot0 =sfphot[0]
	    ; Plot Structure Functions

            graph = plot(tau,sfphot,/current,layout=[1,3,3],$
	       ymajor=2,yminor=9,color=color,$
	       /xlog,/ylog,thick=thick,sym_thick=2,margin=[0.20,0.20,0.03,0.00],$
 	       xtitle='$\tau$ [Days]',ytitle='Structure Fn',font_size=16,$
 	       yrange=[min(sfphot,/nan)*.9,max(sfphot,/nan)*1.1])
            ; Get window of SF plots
            ; Overplot SF of pdc in red
            graph = plot(/overplot,sftau,sfpdc*sfphot0/sfpdc[0],linestyle='0',$
		    color=color2,thick=thick)
	 endif else begin
            graph = plot(/overplot,tau,sfphot*sfphot0/sfphot[0],linestyle='0',thick=thick,color=color)
            graph = plot(/overplot,sftau,sfpdc*sfphot0/sfpdc[0],linestyle='0',thick=thick,color=color2)
	 endelse
     endfor
   if ps then begin
        filenm = '../graphs/final/plotlc_'+skid+'_ap'+sap+'_grp'+sskygroup+'.eps'
   	graph.save,filenm,border=1
   endif
     ; Plot of SDF
     for q = q3[0], q3[1] do begin
	 whnanq= where(nanq eq q)
	 if whnanq ne -1 then continue
	 sq = strtrim(string(q),2)
	 ; Restore file with sfphot, tau, sd, binFreq, binSDF, freq, yfit
         file='../sf/phot/sf_'+skid+'_'+sq+'_'+sfast+'.sav'
         restore,file
	 if (q eq q3[0]) then begin
	    ; Now start SDF plot
	    nt = N_ELEMENTS(tout)
	    ; Plot of binned SDF for first quarter
	    sdfplot = plot(binFreq,binSDF,thick=2,symbol='plus',linestyle='-',$
		    /xlog,/ylog,xtitle='Frequency [Day$^{-1}$]',ytitle='SDF',font_size=16, font_name='Palatino-Roman')
	    ; Overplot powell fit (skip first point)
	    ;sdfplot = plot(/overplot,freq[1:*],yfit,thick=2)
	    text = text(.6,.8,'KIC '+skid, font_size=16)
	    sdtot = sd
	    freqtot = freq
	 endif else begin
            ; For all other quarters
	    ; Plot binned data
	    sdfplot = plot(/overplot,binFreq,binSDF,symbol='plus',linestyle='-',thick=2)
	    ;sdfplot = plot(/overplot,freq[1:*],yfit,thick=2)
	    sdtot = [sdtot,sd]
	    freqtot = [freqtot,freq]
	 endelse
   endfor

   ; Fit powerlaws to sdtot and freqtot
   ;pars=[1d2,1d0,1d0,1d0]
   ;xi = dblarr(4,4)
   ;aa = [1d-1,replicate(0.0,3)]
   ;for j=0,3 do xi[j,*] = shift(aa,j)
   ;ftol=1d-5
   ;pdf0 = sdtot
   ;frq = freqtot
   ;POWELL,pars,xi,ftol,fmin,'brokenpowerlawfit',/double
   ;chi = brokenpowerlawfit(pars,yfit=yfit)
   ;sdfplot = plot(/overplot,frq,pdf0,linestyle='-',thick=4,color='red')
   ;;;
   minlf = alog10(freq[1])
   maxlf = alog10(max(freqtot))
   nlf = 18
   logf = 10.^((findgen(nlf)+1.)/nlf*(maxlf-minlf)+minlf)
   binFreq = 10.^((findgen(nlf)+1.5)/nlf*(maxlf-minlf)+minlf)
   binSDF = fltarr(nlf-1)
   for i=0,nlf-2 do $
	binSDF[i] = mean(sdtot[where(freqtot gt logf[i] and freqtot lt logf[i+1])],/nan)
   sdfplot = plot(/overplot,binFreq,binSDF,linestyle='-',symbol='square',thick=4,color='red',/current)
;
   if ps then begin
        filenm = '../graphs/final/plotsdf_'+skid+'_ap'+sap+'.eps'
	sdfplot.save,filenm,border=1
	;spawn,'eps2eps '+filenm+' '+'tmp.eps'
	;spawn,'mv -f '+'tmp.eps '+filenm
        print,'allforone: filename: ',filenm
   endif

   ;oplot,tauphotss1,sfphotss1,linestyle=1,color=!clr.red,thick=3
   ;oplot,taupdc1,sfpdc1,linestyle=2,color=!clr.red,thick=3
 
   ;xyouts,/data,tauphots[-1],sfphots[-1],'5x5pix Flux',sym_size=1.8,sym_thick=2
   ;xyouts,/data,taupdc[-10]+50,sfpdc[-10],'PDCsap Flux',sym_size=1.8,sym_thick=2
   ;xyouts,/data,tauphotss[-10]+50,sfphotss[-10],'1 Year Differences',sym_size=1.8,sym_thick=2
    
   return
   end
