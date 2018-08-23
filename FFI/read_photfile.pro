PRO read_photfile,ffi,channel,struct,nstars
spawn,'ls -1 FFIs',ffilist
fitsfile=ffilist[ffi]
rootname = strmid(fitsfile,4,13)
s_channel = strtrim(string(channel),2)
spawn,'ls -1 phot/*'+rootname+'*_c'+s_channel+'.phot',photfile
;print,' Reading ',photfile
;openr,/get_lun,rdunit,photfile
rdunit=120
openr,rdunit,photfile
readf,rdunit,nstars
header=''
readf,rdunit,header
struct1 = {kepid:0L,ra:1d0,dec:1d0,kepmag:1e0,xc:1e0,yc:1e0,xpeak:1,ypeak:1,phot:1d0}
struct=replicate(struct1,nstars)
for i=0,nstars-1 do begin
  readf,rdunit,struct1
  struct[i] = struct1
  endfor
free_lun,rdunit
end
