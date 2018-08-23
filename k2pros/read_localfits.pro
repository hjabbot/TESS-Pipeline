function read_localfits,k_id,compress=compress,nonumbers=nonumbers,kepler=kepler
if ~keyword_set(kepler) then kepler = 0
ss = ''
if (kepler) then pre = 'kplr*' else pre = 'ktwo*'
if compress then $
	file = file_search(pre+strtrim(string(k_id),2)+'*.fits.gz') $
else $
	file = file_search(pre+strtrim(string(k_id),2)+'*.fits')
if n_elements(file) gt 1 then begin
	PRINT,'read_localfits: Too many files to read',file
	return,0
endif
if file EQ '' then begin
	PRINT,'read_localfits: No file found for ',k_id
	stop
;	READ,'Continue? ',ss
	ss = 'y'
	if (ss eq 'n' or ss eq 'N') then stop else return,0
endif
result = read_fitswhole(file[0],compress=compress,nonumbers=nonumbers,nextensions=2)
close,/all
return,result
end

