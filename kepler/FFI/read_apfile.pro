FUNCTION READ_APFILE,ffi,channel,ffilist
; Reads the file with the aperture photometry into the apstr structure
; select it by the ffi and channel number.

if (n_params() eq 0) then begin
	print,' Usage: apstr=READ_APFILE(ffi,channel,ffilist)'
	return,''
endif
apfile = 'apdir/k'+STRMID(ffilist[ffi],4,13)+'_ch'+$
			STRTRIM(STRING(channel),2)+'.ap'
openr,/get_lun,apunit,apfile
dum=''
fitsfile=''
readf,apunit,format='(a30,1x,a7,i12)',fitsfile,dum,channel
readf,apunit,count
readf,apunit,dum
apstr = {apstruc, kepid:0L, ra:1d0, dec:1d0, x:0.0, y:0.0, kepmag:0.0}
apstr = replicate(apstr,count)
readf,apunit,apstr
free_lun,apunit
return,apstr
end
    
