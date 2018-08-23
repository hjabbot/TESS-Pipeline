pro examinelist,file
openw,/get_lun,wunit,'badlist.txt'
d=read_delimited(file=file,nskip=3,delimiter=",")
dum=''

for i = 0, n_elements(d) do begin
		spawn,"firefox " +"'"+"http://ned.ipac.caltech.edu/cgi-bin/imgdata?objname=&in_csys=Equatorial&in_equinox=J2000.0&lon="+string(format='(f10.6)',d[i].ra)+"d&lat="+string(format='(f10.5)',d[i].dec)+"d&width=5.0&height=5.0&search_type=DSS+Image"+"'"
		read,' Bad?',dum
		if dum eq 'y' then print,wunit,d[i]
		if dum eq 'y' then printf,wunit,d[i]
		if dum eq 'q' then break
endfor
close,wunit
end
