pro merge_eps,quarters,skygroups,apsize,gotablearr,phothash,findsharp=findsharp,llc=llc,slope=slope,nanq=nanq,noplot=noplot,vlim=vlim,bcon=bcon,stitch=stitch,kids=kids

if (N_PARAMS() eq 0) THEN BEGIN
	print,'Usage:  merge_eps,quarters,skygroups,apsize,gotablearr,phothash,findsharp=findsharp,llc=llc,slope=slope,nanq=nanq,noplot=noplot,vlim=vlim,bcon=bcon,stitch=stitch,kids=kids'
	return
endif

if ~keyword_set(findsharp) then findsharp=0d0
if ~keyword_set(slope) then slope=0d0
if ~keyword_set(nanq) then nanq=0d0
if ~keyword_set(bcon) then bcon=0d0
if ~keyword_set(noplot) then noplot=0
sap = strtrim(string(apsize),2)

for skygroup=skygroups[0],skygroups[1] do begin
   sgrp = strtrim(string(skygroup),2)
   something = 0
   if ~(skygroup le 0) then begin
	   print,'merge_eps: Starting read_targ on skygroup ',skygroup
	   read_targ,gotablearr,quarters,[skygroup,skygroup],apsize,$
		   phothash=phothash,/ps,noplot=noplot,findsharp=findsharp,$
		   something=something,vlim=vlim
   endif

   if something eq 0 then begin
	   print,"merge_eps: No data found for skygroup: ",skygroup
	   continue
   endif
   ; If no entities in the last quarter(s), have to reduce quarters[1]
   q3=intarr(2)
   q2=intarr(2)

   ; Find first quarter with data in this skygroup
   qq = quarters[0]
   while (phothash[qq] eq !NULL || where(phothash[qq].keys() eq skygroup) eq -1) do qq++
   q2[0] = qq
   ; Find last quarter with data in this skygroup
   qq = quarters[1]
   while (phothash[qq] eq !NULL || where(phothash[qq].keys() eq skygroup) eq -1)  do qq--
   q2[1] = qq

   kidl = list()
   for j=q2[0],q2[1] do begin
	   if (phothash[j] EQ !NULL ||  $
	   	where(phothash[j].keys() eq skygroup) eq -1) then continue
	   kidl = kidl + phothash[j,skygroup].keys()
   endfor
   kida = kidl.ToArray()
   kids = kida[uniq(kida, sort(kida))]
   nkids = n_elements(kids)
   squart1 = strtrim(string(q2[0]),2)
   squart2 = strtrim(string(q2[-1]),2)
   for i=0,nkids-1 do begin
	kid=kids[i]
	skid = strtrim(string(kid),2)
   	; Find first quarter with data in this kid
	qq = q2[0]
        while (phothash[qq] eq !NULL ||  where(phothash[qq].keys() eq skygroup) eq -1 $
	|| where(phothash[qq,skygroup].keys() eq kid) eq -1) do qq++
	q3[0] = qq
   	; Find last quarter with data in this kid
	qq = q2[1]
        while (where(phothash[qq].keys() eq skygroup) eq -1 $
	|| where(phothash[qq,skygroup].keys() eq kid) eq -1) do qq--
	q3[1] = qq

	ps = 0
	shiftsub = 0
   	if (where(phothash[q3[0],skygroup].keys() eq kid) eq -1) then continue 
		p=plotlc(kid,phothash,q3,skygroup,apsize,stitch=stitch,/norm,$
			shiftsub=shiftsub,noplot=noplot,llc=llc,slope=slope,graph=graph,$
			nanq=nanq,bcon=bcon,ps=ps,c2=c2,write=1,findsharp=findsharp,vlim=vlim)
	restore,'../lc/lc_KIC'+skid+'_ap'+sap+'.sav'
	ps = 1
	fast = 1
	sfphots=sf(times,phots/mean(phots,/nan),tau=tauphots,nnt=nnt,fast=fast)

	restore,'../pdc/pdcKIC'+skid+'.sav'
	sfpdc=sf(llctimes,llcs/mean(llcs,/nan),tau=taupdc,nnt=nnt,fast=fast)

	if (shiftsub and q3[1]-q3[0] gt 3) then begin
    		restore,'../shiftsub/lcs_KIC'+skid+'_ap'+sap+'.sav'
    		sfphotss=sf(times,photss/mean(photss,/nan),tau=tauphotss,nnt=nnt,$
		fast=fast)
    		graph = plot(tauphotss,sfphotss,/current,layout=[1,4,4],$
		/xlog,/ylog,thick=3,sym_thick=2,margin=[0.20,0.30,0.03,0.0],$
	 	xtitle='$\tau$ [Days]',ytitle='Structure Fn',font_size=12,color='blue',$
	 	yrange=[min([sfphots,sfphotss,sfpdc],/nan)*.9,max([sfphots,sfphotss,sfpdc],/nan)*1.1])
    		graph = plot(/overplot,/current,taupdc,sfpdc,linestyle='Dashed',$
		thick=2,color='green')
	endif else begin
    		graph = plot(taupdc,sfpdc,/current,layout=[1,3,3],$
		/xlog,/ylog,thick=3,sym_thick=2,margin=[0.20,0.20,0.03,0.00],$
	 	xtitle='$\tau$ [Days]',ytitle='Structure Fn',font_size=12,$
	 	color='green', $
	 	yrange=[min([sfpdc,sfphots],/nan)*.9,max([sfpdc,sfphots],/nan)*1.1])
	endelse
	; Plot SF of phots in black
	graph = plot(/overplot,/current,tauphots,sfphots,linestyle='0',$
		thick=2)
	filenm = '../graphs/plotlc_'+skid+'_ap'+sap+'_grp'+sgrp+'_llc.eps'
	filenm2 = '../graphs/plotlc_'+skid+'_ap'+sap+'_g'+sgrp+'_llc.eps'
	graph.save,filenm,resolution=200,border=1
	spawn,'eps2eps '+filenm+ ' '+filenm2
	spawn,'mv -f '+filenm2+' '+filenm
   endfor ; loop over kids

   ; Merge epsfiles with same skygroup
   if ps eq 1 then begin
   	cd,'~/Documents/Kepler/targ/graphs'
   	if llc then  $
      		epsfiles = file_search('plotlc*ap'+sap+'_grp'+sgrp+'_llc.eps') $
   	else $
       		epsfiles = file_search('plotlc*ap'+sap+'_grp'+sgrp+'.eps')
   	outfile ="q"+squart1+"_"+squart2+"g"+sgrp+"a"+sap+"merge_llc.eps" 
   	spawn,"gs -dBATCH -dNOPAUSE -dSAFER -sOutputFile="+outfile+$
		" -sDEVICE=epswrite "+strjoin(epsfiles,' ')
   	spawn,"gv "+outfile+" &"
	print,outfile
   	cd,'~/Documents/Kepler/targ/Q10'
   endif
endfor ; end loop over skygroups
return
end
