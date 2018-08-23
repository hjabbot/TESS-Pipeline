pro read_corners,file
openr,/get_lun,runit,file
openw,/get_lun,wunit,'centers.txt'
ra=dblarr(4)
de=dblarr(4)
for j = 1, 352/4 do begin
	modd = 0
   for i = 0, 3 do begin
   	readf,runit,mod0,mod1,mod2,ra1,dec1
	ra[i] = ra1 
	de[i] = dec1
	if (modd eq 0) then continue
	if (mod0 ne modd) then begin
		print, 'Problem'
		stop
	endif
	modd = mod0
   endfor
   rac = total(ra)/4.
   dec = total(de)/4.
   printf,wunit, mod0, mod1, mod2, rac,dec
endfor
close,runit
close,wunit
free_lun,runit
free_lun,wunit
return
end

