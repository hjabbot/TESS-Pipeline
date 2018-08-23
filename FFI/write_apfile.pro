PRO WRITE_APFILE,ffi,channel,apstr,ffilist

apfile = 'apdir/k'+STRMID(ffilist[ffi],4,13)+'_ch'+$
			STRTRIM(STRING(channel),2)+'.ap'
openw,/get_lun,unit,apfile
PRINTF, unit, ffilist[ffi],' Channel ',channel
PRINTF, unit, n_elements(apstr)
PRINTF, unit, format='(a8,2(a9,1x),2(a8,1x),2x,a8)','Kep_ID','RA','DEC','x','y','KepMag'
FOR i = 0, n_elements(apstr)-1 DO $
          printf,unit,format='(I8,2x,2(F9.5,1x),3(F8.3,1x))',apstr[i].kepid,$
		apstr[i].ra, apstr[i].dec, apstr[i].x, apstr[i].y, apstr[i].kepmag
FREE_LUN, unit
end

