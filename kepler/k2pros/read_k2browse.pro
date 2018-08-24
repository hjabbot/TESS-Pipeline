function read_k2browse,campaign
if (campaign eq 3) then begin
	openr,/get_lun,runit,'C3_sm96.txt'
	ng = 4144
endif
pdc_stat = {kid: 0L, sdev: 1e0, smdev: 0.0}
pdc_stats = replicate(pdc_stat,ng)
dum=''
readf,runit,dum
for j = 0, ng-1 do begin
	readf,runit,format='(i5,i12,f8.3,i3,1x,E10.2,1x,E10.2)',$
	    	 i,kid,kepmag,channel,sdev,smdev
	pdc_stats[j].kid = kid
	pdc_stats[j].sdev = sdev
	pdc_stats[j].smdev = smdev
endfor
return,pdc_stats
end




