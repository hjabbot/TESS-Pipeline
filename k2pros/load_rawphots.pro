function load_rawphots,campaign,bin,ap
   if n_params() eq 0 then begin
	   print,'Usage: rawphots = load_rawphots(campaign,bin,ap)'
	   return,0
   endif
   if  ~oneof(ap,[1,3,4,5,7,9,11]) then begin
	   print,'ap not an accepted value. ap =',ap
	   return,0
   endif
   ; Restore rawphots from save file 
   scampaign = strtrim(string(campaign),2)
   scamp = 'Campaign'+scampaign
   sbin = string(bin,format='(I1)')
   apstr = string(ap,format='(I1)')


   rawfile= scamp +'/rawphots_c'+scampaign+'_bin'+sbin+'_ap'+apstr+'.sav'
   test0 = file_search(rawfile,count=count)
   if count ne 0 then begin
	restore, file = rawfile
	rawphots = rawphots_m
    endif else begin
	print,'Now rawphots file: ',rawfile
	rawphots = 0
    endelse
return, rawphots
end

