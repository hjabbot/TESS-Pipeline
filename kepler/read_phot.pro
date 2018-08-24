pro read_phot,file,phot,time
openr,/get_lun,unit,file
readf,unit,nt
in = {phot:1d0,time:1d0}
in = replicate(in,nt)
	readf,unit,format='(2d10.4)',in
phot = in.phot
time = in.time
return
end

