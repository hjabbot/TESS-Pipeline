pro medianlc,campaign,ccds,time,apsize=apsize,mask=mask,xmldata=xmldata, rebin=rebin,phots=phots

if ~keyword_set(rebin) then rebin = 0
nt =  n_elements(time)
nt = nt/rebin
time2 = congrid(time,nt)
for ccd = ccds[0],ccds[1] do begin
	PRINT,'medianlc: CCD = ',ccd
	phots = run_phot(campaign,apsize=apsize,mask=mask,xmldata=xmldata,$
	 ccd=ccd,pstep=1,/noplot,rebin=rebin)
	if (phots[0] eq -1) then continue
	if isa(phots,/null) then continue
	dims = size(phots,/dim)
	ntargs = dims[1]
	if (dims[0] ne nt) then stop
	mns = fltarr(ntargs)
	for i = 0, ntargs-1 do mns[i] = mean(phots[*,i],/nan)
	med_mns = median(mns)
	photsa = phots
	for i=0,ntargs-1 do photsa[*,i] = phots[*,i]/mns[i]
	pb = photsa                                                  
	for i=0,ntargs-1 do pb[*,i] = smooth(pb[*,i],48*1.5/rebin,/nan,/edge_truncate)
	;pbtop = pb[*,where(mns ge med_mns,ntop)]	
	medianpb = median(pb,dim=2)                                  
	;rms = fltarr(ntop)                                             
	;for i=0,ntop-1 do rms[i] = sqrt(total((pbtop[*,i]-medianpb)^2,/nan))
	;good = where(rms lt .5,ngood)
	;pbg = pbtop[*,good]
	;medianpb = median(pbg,dim=2)                                  
	scampaign = 'Campaign'+strtrim(string(campaign),2)
	p = plot(time2,medianpb,color='red',thick=2,yrange=[.95,1.05],$
		xtitle='BKJD [Day]',title=string(ccd))
	;for i = 0, ntargs-1 do p = plot(/overplot,time,2pb[*,i],symbol='dot',linestyle='',color='grey')
	for i = 0, ntargs-1 do p = plot(/overplot,time2,pb[*,i],thick=alog10(mns[i]/100.))
;	for i = 0, ntargs-1 do p = plot(/overplot,time2,pbtop[*,i],thick=2)
	p = plot(/overplot,time2,medianpb,color='red',thick=2)
	openw,/get_lun,wunit,scampaign+'/medianlc/medianlc_'+strtrim(string(ccd),2)+'.txt'
	printf,wunit,nt
	for i = 0,nt-1 do printf,wunit,time2[i],medianpb[i]
	close,wunit
	free_lun,wunit
endfor
return
end


