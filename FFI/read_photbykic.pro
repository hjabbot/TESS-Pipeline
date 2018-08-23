function read_photbykic,file,skip
delimiter=' '
spawn,'wc -l '+file,nrows
nrows = nrows[0] - skip
tagnames=['kic','kepmag','gold','med','max','ffimag','agn']
vals = '0L,1d0,1d0,1d0,1d0,1d0,1'
colvector = indgen(7)
out=read_delimited(file,delimiter,skip,nrows,colvector,tagnames,vals)
return,out
end
