pro write_zeropts,file,zeropts,n_ffis

if (n_params() eq 0) then begin
	print,' Usage:  write_zeropts,file,zeropts,n_ffis'
	return
endif

openw,/get_lun,unit,file
z=transpose(zeropts)
for i=0, n_ffis-1 do $
	printf,unit,format='(i3,85d12.8)',i,z[*,i]
close,unit
end


