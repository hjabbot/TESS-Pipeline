function read_llcdev

IF (!VERSION.OS_FAMILY EQ 'Windows') THEN $
	file = 'C:\Users\eshaya\Dropbox\Kepler Mission\targ\llcdev.txt' $
ELSE $
	file = '~/Documents/Dropbox/Kepler Mission/targ/llcdev.txt'

openr,/get_lun,runit, file

pstruc={skygroup:0,kid:0L,cps:1.0,std:dblarr(12)}
nr = file_lines(file)
pdcstruc = replicate(pstruc,nr-1)
line = ''
readf,runit,line
readf,runit,pdcstruc
free_lun,runit
return,pdcstruc
end

