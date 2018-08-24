function read_golist
file='Kepler_Galaxies_SNR_Name_Q10-14.dat'
delimiter = ' '
skip = 62
nrows = 393
tagnames = ['kepid','agn_id','chisq','kepmag','kepm_jhk','seq', 'cnt']
colvector = [     0,       1,      2,      11,        12,   16,    26]
vals =        '0L  ,      "",     1.,      1.,       1d0,   1,     0L'

output=read_delimited(file,delimiter,skip,nrows,colvector,tagnames,vals)
return,output
end
