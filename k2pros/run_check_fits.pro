pro run_check_fits,ccds,campaign,k2data

openw,/get_lun,unit,'check_fits.txt'
for ccd = ccds[0],ccds[1] do begin
	PRINT, 'run_check_fits: Starting CCD ',ccd
	PRINTF, unit,'run_check_fits: Starting CCD ',ccd
	set = WHERE(k2data.channel EQ ccd,nkids)
	if nkids eq 0 then begin
		print,'run_check_fits: No targets on channel ',ccd
		continue
	endif
        kids = k2data[set].k2_id
	; If we are only modifying the headers set just_headers
	foreach kid, kids do begin
		PRINTF, unit,'run_check_fits: ',kid
		check_fits,kid,campaign,unit
	endforeach
endfor
PRINTF,unit,'run_check_fits: done'
close,unit
free_lun,unit
return
end



