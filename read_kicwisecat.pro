function read_kicwisecat,file
delimiter=' '
tagnames=['KIC','is_AGN','D','RA','Dec','GLON','GLAT','KEPMAG','rmag','imag','jmag','hmag','kmag','w1mag','w2mag','w3mag']
colvector=indgen(16)
nrows=12821L  
skip=10
vals='382804,  0,  0.933, 297.490360, 36.224743,  71.341066, 5.055222, 16.554, 16.575, 16.069, 16.241,  15.820, 15.186, 14.394, 13.933, 9.998'

output=read_delimited(file,delimiter,skip,nrows,colvector,tagnames,vals)
return,output
end

