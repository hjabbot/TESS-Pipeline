pro run_redo_fits,ccds,campaign,npca,k2data,just_headers=just_headers

npca0 = npca
if (just_headers) then begin
	phot = 0
	fullp0 = 0
	npca0 = 0
endif
for ccd = ccds[0],ccds[1] do begin
	PRINT, 'run_redo_fits: Starting CCD ******************',ccd
	set = WHERE(k2data.channel EQ ccd,nkids)
	if nkids eq 0 then begin
		print,'run_redo_fits: No targets on channel ',ccd
		continue
	endif
        kids = k2data[set].k2_id
	; If we are only modifying the headers set just_headers
	foreach kid, kids do begin
		; We get llc data and time here
		pdc_flux=read_k2llc(kid,campaign,time,xc,yc,sap_flux,data=llcdata) 
		hdr_0 = llcdata.header
		hdr_lc = llcdata.lightcurve.header
		hdr_ap = llcdata.aperture.header
		cadenceno = llcdata.lightcurve.data.cadenceno
		; We get targdata.  Don't take the apmask here, it is the project's apmask.
		k2cube = read_k2targ(kid,campaign,time,quality,flux_bkg,apmask,data=targdata)
		
		write_fits_lc,kid,campaign,npca0,hdr_0,hdr_lc,hdr_ap,$
			cadenceno, raw, phot,targdata.targettables.header,time,fullp0
	endforeach
endfor
return
end



