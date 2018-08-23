function read_k2llc,kid,campaign,llctime,xcenter,ycenter,sap_flux,sap_bkg,data=data
	if campaign ge 10 then format ='(I2)' else format='(I1)'
	sdir = 'Campaign'+string(format=format,campaign)
	cd, sdir+'/llc'
	data=read_localfits(kid,/compress,/nonumbers)
	if (size(data,/tname) ne 'STRUCT') then begin
		print, 'read_k2llc: llc file not found in ',sdir,'/llc for ',kid
	;	stop
	endif
	cd, '../..'
	quality = data.lightcurve.data.sap_quality
	quality[where(quality eq 32768)] = 0
	lc = data.LIGHTCURVE.data.pdcsap_flux
	xcenter = data.LIGHTCURVE.data.mom_centr1
	ycenter = data.LIGHTCURVE.data.mom_centr2
	lc[where(quality ne 0)] = !values.d_nan
	timecorr = data.lightcurve.data.timecorr
	timslice=sxpar(data.lightcurve.header,'TIMSLICE')
        llctime = double(data.lightcurve.data.time)- $
		timecorr+(0.25+0.52*(5.-timslice))/86400.
	sap_flux = data.lightcurve.data.sap_flux
	sap_bkg = data.lightcurve.data.sap_bkg
return,lc
end
	
