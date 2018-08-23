function read_llc,kid,quarters,llctime,kepler=kepler
if ~keyword_set(kepler) then kepler = 0
llcl = list() 
llctime = list()
for q = quarters[0], quarters[1] do begin
	dir = string('../Q',q,format='(a4,I02)')
	cd, dir
	cd, 'llc'
	data=read_localfits(kid,/compress,kepler=kepler)
	if (size(data,/tname) ne 'STRUCT') then begin
		print, 'read_llc: llc file not found in ',dir,'/llc for ',kid
	;	stop
	endif
	cd, '..'
	if (size(data,/type) ne 8) then begin
		llcl.add, !values.d_nan
		llctime.add, !values.d_nan
		continue
	endif
	lc = data.LIGHTCURVE_1.data.pdcsap_flux
	lc[where(data.lightcurve_1.data.sap_quality ne 0)] = !values.d_nan
	timecorr = data.lightcurve_1.data.timecorr
	timslice=sxpar(data.lightcurve_1.header,'TIMSLICE')
        time = double(data.lightcurve_1.data.time)- $
		timecorr+(0.25+0.52*(5.-timslice))/86400.
	llcl.add,lc
	llctime.add,time
endfor
return,llcl
end
	
