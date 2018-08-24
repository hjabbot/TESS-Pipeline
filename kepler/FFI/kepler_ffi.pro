ffi=0
goto,starthere

nffi = N_ELEMENTS(ffindices)
ffindex = ffindices[ffi]
IF (ffindex LE 9) THEN res = 'res_00000'+string(ffindex,FORMAT='(i1)')
IF (ffindex ge 10) THEN res = 'RES_0000'+string(ffindex,FORMAT='(i2)')
result = execute('res ='+res)
gm = res.kep_gm
rm = res.kep_rm
im = res.kep_im
kx = res.kep_xx
ky = res.kep_yy
kid = res.kep_kepid
;gindex = LONARR(46)
;FOR i = 0,45 DO gindex[i]=WHERE(tmx_kepid[i] EQ kid)
ra = res.kep_ra
de = res.kep_de
;kep_gal = res.kep_gal
tmx_kepid = res.tmx_kepid
tmx_x = res.tmx_xx
tmx_y = res.tmx_yy
tmx_kepmag = res.tmx_kepmag
nstars = res.n_objs
ft = DBLARR(nstars,nffi)
a1 = DBLARR(nstars,nffi)
a2 = DBLARR(nstars,nffi)
a3 = DBLARR(nstars,nffi)
a4 = DBLARR(nstars,nffi)
xc_arr2 = DBLARR(nstars,nffi)
yc_arr2 = DBLARR(nstars,nffi)
e_ft = DBLARR(nstars,nffi)
e_a1 = DBLARR(nstars,nffi)
e_a2 = DBLARR(nstars,nffi)
e_a3 = DBLARR(nstars,nffi)
e_a4 = DBLARR(nstars,nffi)
xc0=res.xc
yc0=res.yc
xc = res.xx_ov
yc = res.yy_ov
match = LONARR(nstars) - 1
mjd_arr = DBLARR(nffi)
nomatch = [0]
season_arr = INTARR(nffi)
FOR ffi = 0,nffi-1 DO BEGIN
   ffindex = ffindices[ffi]
   IF (ffindex LE 9) THEN res = 'res_00000'+string(ffindex,FORMAT='(i1)')
   IF (ffindex ge 10) THEN res = 'RES_0000'+string(ffindex,FORMAT='(i2)')
   PRINT,res
   result = execute('res ='+res)
   mjd_arr[ffi] = res.mjd_start
   PRINT,'season = ',res.season
   season_arr[ffi] = res.season
   xc0=res.xc
   yc0=res.yc
   wx = res.wx_ov
   wy = res.wy_ov
   e_x = res.xx_oe
   e_y = res.yy_oe
   xc1 = res.xx_ov
   yc1 = res.yy_ov

   ;  Look FOR stars matching to the ones on the first FFI
   FOR i = 0, nstars -1 DO match[i] = WHERE((xc1 - xc[i])^2 + (yc1 - yc[i])^2 LT 3.)
   matches = WHERE(match NE -1, nmatch)
   PRINT, ffi,' Number of matches ',nmatch
   nomatchtest = WHERE(match EQ -1, nnomatch)
   PRINT, ffi,' Number of no matches ',nnomatch
   ; Concatenate all of the nomatches
   IF (nnomatch NE 0) THEN begin
        match[nomatchtest] =  0
   	nomatch = [nomatch,nomatchtest]
   ENDIF
   wx = wx[match]  
   wy = wy[match]  
   ft[*,ffi] = res.ft_ov[match]  
   e_ft[*,ffi] = res.ft_oe[match]  
   a1[*,ffi] = res.a1_ov[match]
   e_a1[*,ffi] = res.a1_oe[match]
   a2[*,ffi] = res.a2_ov[match]
   e_a2[*,ffi] = res.a2_oe[match]
   a3[*,ffi] = res.a3_ov[match]
   xc_arr2[*,ffi] = res.xx_ov[match]
   yc_arr2[*,ffi] = res.yy_ov[match]
   help,a3
   e_a3[*,ffi] = res.a3_oe[match]
   a4[*,ffi] = res.a4_ov[match]
   e_a4[*,ffi] = res.a4_oe[match]
   e_x = e_x[match] 
   e_y = e_y[match] 
   xc1 = xc1[match] 
   yc1 = yc1[match] 
ENDFOR

nomatch = nomatch[uniq(nomatch,sort(nomatch))]
nnomatch = N_ELEMENTS(nomatch)
PRINT,"Total nomatches",nnomatch
FOR ffi = 0,nffi-1 DO BEGIN
   IF (nnomatch NE 0) THEN BEGIN
   wx[nomatch] = !values.f_nan
   wy[nomatch] = !values.f_nan
   ft[nomatch,ffi] = !values.f_nan
   e_ft[nomatch,ffi] = !values.f_nan
   a1[nomatch,ffi] = !values.f_nan
   e_a1[nomatch,ffi] = !values.f_nan
   a2[nomatch,ffi] = !values.f_nan
   e_a2[nomatch,ffi] = !values.f_nan
   a3[nomatch,ffi] = !values.f_nan
   e_a3[nomatch,ffi] = !values.f_nan
   a4[nomatch,ffi] = !values.f_nan
   e_a4[nomatch,ffi] = !values.f_nan
   e_x[nomatch] = !values.f_nan
   e_y[nomatch] = !values.f_nan
   ;xfit[nomatch] = !values.f_nan
   ;yfit[nomatch] = !values.f_nan
   ENDIF
ENDFOR
starthere:
season = season_arr[doffi[0]]
print,'Seasons: ',season_arr[doffi]
ndoffi = n_elements(doffi)
;a0 = a2[*,WHERE(season_arr EQ season,ndoffi)]
a0 = ap2[*,doffi]
maxx = fix(max(xc1))+1
maxy = fix(max(yc1))+1
print,' minmax x,y', minmax(xc1), minmax(yc1)
mags = DBLARR(nstars)
count0 = 1d8
mag0 = 11.8d0
mags=-2.5*ALOG10(a0[*,0]/count0/1625.35d0)+mag0
;FOR i = 0, nstars-1 DO BEGIN
;	IF (FINITE(a0[i,0])) THEN BEGIN
;		mags[i]=-2.5*ALOG10(a0[i,0]/count0/1625.35d0)+mag0
;	ENDIF ELSE BEGIN
;		mags[i] = 0
;	ENDELSE
;ENDFOR
nsects = 1
xx1 = 0 & xx2 = maxx/nsects
yy1 = 0 & yy2 = maxy/nsects
insect = where(xc1 ge xx1 and xc1 le xx2 and  yc1 ge yy1 and yc1 le yy2)
a0 = a0[insect,*]
nstars2 = n_elements(insect)
magsin = mags[insect]

mjd_arr0 = mjd_arr[doffi]
hipts = WHERE(a0[*,0] gt 4e9 AND a0[*,0] LT 4e10,nhi) & PRINT,nhi  
;xfithi = xfit[hipts]
;yfithi = yfit[hipts]

; Start analysis on a particular aperture
;Find quiet stars FOR standards
; Use all stars on first pass
k=0

IF (SIZE(standards,/type) EQ 0) THEN standards = hipts
avg2 = MEAN(a0[standards,0],/double,/nan)
;avg2 = MEDIAN(a0[standards,0],/double)
; Normalize
FOR ffi = 1, ndoffi-1 DO a0[*,ffi] = a0[*,ffi]*avg2/MEAN(a0[standards,ffi],/double,/nan)
;FOR ffi = 0, ndoffi-1 DO a0[*,ffi] *= avg2/MEDIAN(a0[standards,ffi],/double)

; PLOT Normalized Counts FOR 100 stars
PLOT,a0[k,*]/a0[k,*],yrange=[.8,1.2],/nodata 
FOR i = 0, 50 DO OPLOT,a0[i+k,*]/mean(a0[i+k,*],/double),psym=2 & k += 100
dum = ''
WAIT,2
avga0 = DBLARR(nhi)

;Average FOR each star across FFIs
;FOR star=0,nhi-1 DO avga0[star] = mean(a0[star,*],/nan,/double)
;FOR star=0,nhi-1 DO avga0[star] = median(a0[star,*],/double)

FOR ffi=0,ndoffi-1 DO $
	PRINT,MEANABSDEV(a0[*,ffi]/(a0[*,0]),/nan,/double) 

; Plot of fractional variance vs counts
;varian = DBLARR(nstars2)
;FOR i = 0, nstars2-1 DO $
;	varian[i] = SQRT(VARIANCE(a0[i,*],/nan,/double))/a0[i,0]
;plot,a0[*,0],varian,psym=3,/xlog,/ylog

; PLOT mmag deviation vs mag
varian = DBLARR(nstars2)
FOR i = 0, nstars2-1 DO $
	varian[i] = VARIANCE(-2.5*ALOG10(a0[i,*]),/nan,/double)
PLOT,magsin,SQRT(varian)*1e3,psym=3,/ylog,xtitle='Kepler Magnitude',$
	ytitle='Log RMS Variance [mmag] ',charsize=1.5,yrange=[.01,1e2],$
	xrange=[10,18],symsize=0.3
; Overplot theory
magt = FINDGEN(100)/5.
signal = count0*10.^(-(magt-mag0)/2.5d0)
noise = SQRT(signal)+60.+sqrt(8.4d6)*25./sqrt(10.)
vart = 2.5*ALOG10((noise+signal)/signal)
OPLOT,magt,vart*1d3,thick=3

READ,'Ready? ',dum

; Improve on standards by using best 1000 stars
sort_varian = SORT(varian)
standards = sort_varian[0:3000]
standards = standards[WHERE(magsin[standards] GT 10.0 AND magsin[standards] LT 15.0)]

; Work on galaxies
readcoo,'gals.coo',gal_x,gal_y,ngals
ngals = N_ELEMENTS(gal_x) & PRINT,'ngals = ',ngals
gindex = LONARR(ngals)
FOR gal = 0,ngals-1 DO $
	gindex[gal] = WHERE((gal_x[gal]-xc1)^2+(gal_y[gal]-yc1)^2 LT 3)
id = WHERE(gindex NE -1)
gal_x_id = gal_x[id]
gal_y_id = gal_y[id]
gindex2 = gindex[id]
ngals = N_ELEMENTS(gindex2) & PRINT,'ngals = ',ngals
g_a0 = a0[gindex2,*]
mag = magsin[gindex2]
FOR ffi = 0, ndoffi-1 DO $
	PRINT,MEANABSDEV(g_a0[*,ffi]/(g_a0[*,0]),/nan,/double) 
;PLOT,mjd_arr0-mjd_arr0[0],g_a0[0,*],yrange=[0,1e8],/nodata 
;FOR gal = 0, ngals-1 DO $
;     OPLOT,mjd_arr0-mjd_arr0[0],g_a0[gal,*]/g_a0[gal,0],psym=-1 
;PRINT,'Ready? ',dum
;WAIT,2
;FOR gal = 0, ngals-1 DO BEGIN
;     PLOT,mjd_arr0-mjd_arr0[0],g_a0[gal,*]/g_a0[gal,0],psym=-1 ,yrange=[.8,1.2]
;     IF (finite(g_a0[gal,0])) THEN PLOT,mjd_arr0-mjd_arr0[0],g_a0[gal,*],psym=-1 
;     wait,2
;ENDFOR
;FOR gal = 0, ngals-1 DO $
;     IF (finite(g_a0[gal,0])) THEN OPLOT,mjd_arr0-mjd_arr0[0],g_a0[gal,*]/g_a0[gal,0],psym=-1 
vgal = dblarr(ngals,4)
FOR gal = 0, ngals-1 DO vgal[gal,season] = MEANABSDEV(-2.5*ALOG10(g_a0[gal,*]),/double,/nan)

sm = sort(mag)
PRINT,'Galaxy variance table'
PRINT,FORMAT='(a3,a7,2a9,4a8)','ID','mag','  X  ','  Y  ','Season0','Season1','Season2','Season3'
FOR gal = 0, ngals-1 DO PRINT,FORMAT='(i3,f7.1,2f9.2,4f8.3)',id[sm[gal]],mag[sm[gal]],$
	gal_x_id[sm[gal]],gal_y_id[sm[gal]],vgal[sm[gal],*]
;PLOT,mag,vgal[*,season]*1e3,psym=2,/ylog,ytitle='RMS variance [mmag]',charsize=1.5
oPLOT,mag,vgal[*,season]*1e3,psym=1,thick=2,symsize=2,color=2


END
