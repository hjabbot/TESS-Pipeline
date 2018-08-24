pro read_tpfs, files
dir = 'Campaign16/tpf/'
openw,/get_lun,lun,'G16tmp.txt'
files = file_search(dir,"*.fits.gz")
forward_function fxpar
printf,lun,'K2_ID, CHANNEL'
printf,lun,'long, integer'
printf,lun, '''
foreach file, files,indx do begin
  data = read_fitswhole(file,/nonum,nextensions=2,/compress)
   head = data.header
   print,indx
   ccd = fxpar(head,'CHANNEL')
   id = fxpar(head,'KEPLERID')
   printf,lun,id,',',ccd
endforeach
close,lun
free_lun,lun

return
end
