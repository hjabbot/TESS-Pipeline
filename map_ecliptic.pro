
ecl=findgen(3600)/10.
sgl=findgen(3600)/10.
gl=findgen(3600)/10.
; create ecliptic line
euler,ecl,0,ra0,dec0,4
MAP_SET, 0, 180, /AITOFF, /GRID,/ISOTROPIC, latdel=10,londel=10,label=3,TITLE= 'Equatorial Coordinates, Aitoff Projection',charsize=1
oplot,ra0,dec0
glactc,ra1,dec1,2000,sgl,0,2,/Supergalactic,/degree
oplot,ra1,dec1,thick=3
glactc,ra2,dec2,2000,gl,0,2,/degree
oplot,ra2,dec2,thick=3,linestyle=2
xyouts,ra2[2500],dec2[2500],'Galactic Plane',charsize=1,charthick=2
XYOUTS,ra1[2800],dec1[2800],'SuperGalactic Plane',charsize=1,charthick=2
XYOUTS,ra0[1200],dec0[1200],'Ecliptic Plane',charsize=1,charthick=2

glactc,ragalc,decgalc,2000,0,0,2,/degree
plots,ragalc,decgalc,psym=5,symsize=2,thick=2
shifts=[0,-100,-100,0,-100,-100]
shifts = shifts*0.
for j = 0,5 do plots,ra0[j*600+i+shifts[j]],dec0[j*600+i+shifts[j]],psym=6,symsize=4.2,thick=2
for j = 0,5 do print,ra0[j*600+i+shifts[j]],dec0[j*600+i+shifts[j]]
glactc,ra0,dec0,2000,glecl,gbecl,1,/degree
print,''

for j = 0,5 do print,glecl[j*600+i+shifts[j]],gbecl[j*600+i+shifts[j]]