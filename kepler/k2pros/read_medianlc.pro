function read_medianlc,campaign,ccd,time
   scampaign = 'Campaign'+strtrim(string(campaign),2)
   openr,/get_lun,runit,scampaign+'/medianlc/medianlc_'+strtrim(string(ccd),2)+'.txt'
   readf,runit,nt
   medianlc = fltarr(nt)
   for i = 0, nt - 1 do begin
	readf,runit,time0,medianlc0
	time[i] = time0
	medianlc[i] = medianlc0
   endfor
return,medianlc
end

