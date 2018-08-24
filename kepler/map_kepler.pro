function map_Kepler,gotablearr,ukids,nkids,psym=psym

IF ~keyword_set(psym) then psym = 1
ramax =  -58d0
ramin = -80d0
decmin = 36.
decmax = 53.
limit = [decmin,-ramax,decmax,-ramin]
centerra= -70d0
centerdec = 46d0
map1 = map('Orthographic', limit=limit,label_format='mapgrid_labels_reverse',$
	label_position = .1)

grid = map1.mapgrid
grid.linestyle = "dotted"
grid.font_size = 12
grid.grid_longitude=5
grid.grid_latitude=4

ra = dblarr(nkids)
dec = dblarr(nkids)
jmag = dblarr(nkids)
for i = 0, 3 do begin
   wh = []
	 for k = 0, nkids-1 do begin
		 wh1 = where(gotablearr[i].kepler_id eq ukids[k],nwh)
		 if (nwh ne 0) then wh = [wh,wh1[0]]
	 endfor
	 if (n_elements(wh) ne 0) then begin
	 ra = gotablearr[i].RA__J2000_[wh]
	 dec = gotablearr[i].DEC__J2000_[wh]
   jmag = gotablearr[i].j_MAG[wh]
   stop
   map1 = plot(/overplot,-ra,dec,symbol=i+4,linestyle='')
   endif else print, 'no galaxies for i = ',i
endfor
return,map1
end
