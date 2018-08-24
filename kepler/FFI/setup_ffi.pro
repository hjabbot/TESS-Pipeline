pro setup_ffi,quarter,season,startime,dateobs,ffilist,n_ffis
if (n_params() eq 0) then begin
	print,'Usage: setup_ffi,quarter,season,startime,dateobs,ffilist,n_ffis'
	return
endif
CD, '/home/eshaya/Documents/Kepler/Kepler_FFI'
spawn,'ls -1 FFIs',ffilist
;n_ffis = n_elements(ffilist)
n_ffis = 41
quarter=intarr(n_ffis)
season=intarr(n_ffis)
startime=dblarr(n_ffis)
dateobs=strarr(n_ffis)
openr,13,'quarter.txt'
readf,13,quarter
close,13
openr,13,'season.txt'
readf,13,season
close,13
openr,13,'startime.txt'
readf,13,startime
startime = startime - 54833.
close,13
openr,13,'dateobs.txt'
readf,13,dateobs
close,13
end
