pro download_targs,gotable,quarter,quartersuffix
down = gotable.kepler_id[where(gotable.quarter EQ quarter)]
a1='wget http://archive.stsci.edu/missions/kepler/target_pixel_files/'
b1='wget http://archive.stsci.edu/missions/kepler/lightcurves/'
a2='-'+quartersuffix
a3= '_lpd-targ.fits.gz'
b3 = '_llc.fits'
down = strtrim(string(down,format='(i09)'),2)
first4 = strmid(down,0,4)
openw,/get_lun,lun,'gettargQ'+strtrim(string(quarter),2)
for i=0,n_elements(down)-1 do printf,lun,a1+first4[i]+'/'+down[i]+'/kplr'+down[i]+a2+a3
printf,lun,'cd llc'
for i=0,n_elements(down)-1 do printf,lun,b1+first4[i]+'/'+down[i]+'/kplr'+down[i]+a2+b3
printf,lun,'gzip *.fits'
printf,lun,'cd ..'
close,lun
return
end


