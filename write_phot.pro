pro write_phot,phot,time,file
openw,/get_lun,unit,file
nt = n_elements(time)
printf,unit,nt
for i = 0,nt-1 do $
       printf,unit,format='(2f10.4)',phot[i],time[i]
close,unit
free_lun,unit
return
end
