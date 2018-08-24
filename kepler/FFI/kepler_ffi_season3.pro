j=7
season = 3
goto,starthere
dir = '/home/eshaya/Documents/Dropbox/Kepler\ Mission/Kepler_FFI/'
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-04-24_17:48:33.986_sea_3_cha_19_sml_sou_FFI_000.idlsave'
ffindices = [0]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-04-24_20:48:35.994_sea_3_cha_19_sml_sou_FFI_001.idlsave'
ffindices = [ffindices,1]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-04-25_00:26:13.887_sea_3_cha_19_sml_sou_FFI_002.idlsave'
ffindices = [ffindices,2]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-04-25_05:36:16.637_sea_3_cha_19_sml_sou_FFI_003.idlsave'
ffindices = [ffindices,3]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-04-25_08:06:20.497_sea_3_cha_19_sml_sou_FFI_004.idlsave'
ffindices = [ffindices,4]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-04-25_13:11:22.456_sea_3_cha_19_sml_sou_FFI_005.idlsave'
ffindices = [ffindices,5]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-04-25_17:36:11.624_sea_3_cha_19_sml_sou_FFI_006.idlsave'
ffindices = [ffindices,6]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-04-26_03:59:24.074_sea_3_cha_19_sml_sou_FFI_007.idlsave'
ffindices = [ffindices,7]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-06-19_04:39:15.178_sea_0_cha_59_sml_sou_FFI_008.idlsave'
;ffindices = [ffindices,8]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-08-19_19:48:31.175_sea_0_cha_59_sml_sou_FFI_009.idlsave'
;ffindices = [ffindices,9]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-09-17_00:08:00.434_sea_0_cha_59_sml_sou_FFI_010.idlsave'
;ffindices = [ffindices,10]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-10-19_02:04:29.995_sea_1_cha_67_sml_sou_FFI_011.idlsave'
;ffindices = [ffindices,11]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-11-18_23:30:47.068_sea_1_cha_67_sml_sou_FFI_012.idlsave'
;ffindices = [ffindices,12]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2009-12-17_00:52:45.084_sea_1_cha_67_sml_sou_FFI_013.idlsave'
;ffindices = [ffindices,13]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-01-19_22:55:02.726_sea_2_cha_27_sml_sou_FFI_014.idlsave'
;ffindices = [ffindices,14]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-01-20_00:50:46.885_sea_2_cha_27_sml_sou_FFI_015.idlsave'
;ffindices = [ffindices,15]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-02-18_18:23:02.560_sea_2_cha_27_sml_sou_FFI_016.idlsave'
;ffindices = [ffindices,16]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-03-19_17:45:24.065_sea_2_cha_27_sml_sou_FFI_017.idlsave'
;ffindices += [ffindices,17]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-04-21_12:50:26.874_sea_3_cha_19_sml_sou_FFI_018.idlsave'
ffindices = [ffindices,18]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-05-20_10:16:31.648_sea_3_cha_19_sml_sou_FFI_019.idlsave'
ffindices = [ffindices,19]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-06-23_16:41:13.657_sea_3_cha_19_sml_sou_FFI_020.idlsave'
ffindices = [ffindices,20]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-07-22_01:22:15.137_sea_0_cha_59_sml_sou_FFI_021.idlsave'
;ffindices = [ffindices,21]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-08-22_19:27:45.145_sea_0_cha_59_sml_sou_FFI_022.idlsave'
;ffindices = [ffindices,22]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-09-22_19:53:56.610_sea_0_cha_59_sml_sou_FFI_023.idlsave'
;ffindices = [ffindices,23]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-10-23_19:21:19.102_sea_1_cha_67_sml_sou_FFI_024.idlsave'
;ffindices = [ffindices,24]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-11-22_18:17:28.493_sea_1_cha_67_sml_sou_FFI_025.idlsave'
;ffindices = [ffindices,25]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2010-12-22_02:01:28.558_sea_1_cha_67_sml_sou_FFI_026.idlsave'
;ffindices = [ffindices,26]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2011-01-24_13:49:26.540_sea_2_cha_27_sml_sou_FFI_027.idlsave'
;ffindices = [ffindices,27]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2011-02-22_17:44:01.167_sea_2_cha_27_sml_sou_FFI_028.idlsave'
;ffindices = [ffindices,28]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2011-04-26_10:10:37.284_sea_3_cha_19_sml_sou_FFI_029.idlsave'
ffindices = [ffindices,29]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2011-05-25_14:57:58.067_sea_3_cha_19_sml_sou_FFI_030.idlsave'
ffindices = [ffindices,30]
restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2011-06-26_10:31:44.607_sea_3_cha_19_sml_sou_FFI_031.idlsave'
ffindices = [ffindices,31]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2011-07-27_10:58:01.814_sea_0_cha_59_sml_sou_FFI_032.idlsave'
;ffindices = [ffindices,32]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2011-08-28_17:48:27.421_sea_0_cha_59_sml_sou_FFI_033.idlsave'
;ffindices = [ffindices,33]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2011-09-28_18:44:06.262_sea_0_cha_59_sml_sou_FFI_034.idlsave'
;ffindices = [ffindices,34]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2011-10-30_18:42:45.910_sea_1_cha_67_sml_sou_FFI_035.idlsave'
;ffindices = [ffindices,35]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2011-11-30_17:40:43.055_sea_1_cha_67_sml_sou_FFI_036.idlsave'
;ffindices = [ffindices,36]
;restore,dir+'Kepler_Pos_RA_285.016050_DE_44.535587_2012-01-04_20:11:47.245_sea_1_cha_67_sml_sou_FFI_037.idlsave'
;ffindices = [ffindices,37]

;seas_arr = RES_000000.seas_arr 
;idlsav_arr = RES_000000.idlsav_arr
;ffindices = where(seas_arr eq season,nffi)
;savesets = idlsav_arr[ffindices]
;for i = 0,nffi-1 do restore,savesets[i]
nffi = N_ELEMENTS(ffindices)
ffindex = ffindices[j]
IF (ffindex le 9) then res = 'res_00000'+string(ffindex,format='(i1)')
IF (ffindex ge 10) then res = 'RES_0000'+string(ffindex,format='(i2)')
result = execute('res ='+res)
gm = res.kep_gm
rm = res.kep_rm
im = res.kep_im
kx = res.kep_xx
ky = res.kep_yy
kid = res.kep_kepid
;gindex = lonarr(46)
;for i = 0,45 do gindex[i]=where(tmx_kepid[i] eq kid)
ra = res.kep_ra
de = res.kep_de
;kep_gal = res.kep_gal
tmx_kepid = res.tmx_kepid
tmx_x = res.tmx_xx
tmx_y = res.tmx_yy
tmx_kepmag = res.tmx_kepmag
nstars = res.n_objs
a1 = dblarr(nffi,nstars)
a2 = dblarr(nffi,nstars)
a3 = dblarr(nffi,nstars)
a4 = dblarr(nffi,nstars)
e_a1 = dblarr(nffi,nstars)
e_a2 = dblarr(nffi,nstars)
e_a3 = dblarr(nffi,nstars)
e_a4 = dblarr(nffi,nstars)
xc=res.xc
yc=res.yc
match = lonarr(nstars) - 1
mjd_arr = fltarr(nffi)
for j = 0,nffi-1 do begin
   ffindex = ffindices[j]
   IF (ffindex le 9) then res = 'res_00000'+string(ffindex,format='(i1)')
   IF (ffindex ge 10) then res = 'RES_0000'+string(ffindex,format='(i2)')
   result = execute('res ='+res)
   mjd_arr[j] = res.mjd_start
   print,'season = ',res.season
   xc1=res.xc
   yc1=res.yc
   wx = res.wx_ov
   wy = res.wy_ov
   ft = res.ft_ov
   e_ft = res.ft_oe
   e_x = res.xx_oe
   e_y = res.yy_oe
   xfit = res.xx_ov
   yfit = res.yy_ov

   ;  Look for stars matching to the ones on the first FFI
   for i = 0, nstars -1 do match[i] = where(abs(xc1 - xc[i])^2 lt 3. and abs(yc1 - yc[i])^2 lt 3.)
   matches = where(match ne -1, nmatch)
   print, j,' Number of matches ',nmatch
   nomatch = where(match eq -1, nnomatch)
   print, j,' Number of no matches ',nnomatch
   if (nomatch[0] ne -1) then begin
   	nomatch = match[where(match eq -1, nnomatch)]
        match[nomatch] =  0
   endif
   wx = wx[match]  
   wy = wy[match]  
   ft = ft[match]  
   e_ft = e_ft[match]  
   a1[j,*] = res.a1_ov[match]
   e_a1[j,*] = res.a1_oe[match]
   a2[j,*] = res.a2_ov[match]
   e_a2[j,*] = res.a2_oe[match]
   a3[j,*] = res.a3_ov[match]
   e_a3[j,*] = res.a3_oe[match]
   a4[j,*] = res.a4_ov[match]
   e_a4[j,*] = res.a4_oe[match]
   e_x = e_x[match] 
   e_y = e_y[match] 
   xfit = xfit[match] 
   yfit = yfit[match] 

   if (nnomatch[0] ne 0) then begin
   wx[nomatch] = !values.f_nan
   wy[nomatch] = !values.f_nan
   ft[nomatch] = !values.f_nan
   e_ft[nomatch] = !values.f_nan
   a1[j,nomatch] = !values.f_nan
   e_a1[j,nomatch] = !values.f_nan
   a2[j,nomatch] = !values.f_nan
   e_a2[j,nomatch] = !values.f_nan
   a3[j,nomatch] = !values.f_nan
   e_a3[j,nomatch] = !values.f_nan
   a4[j,nomatch] = !values.f_nan
   e_a4[j,nomatch] = !values.f_nan
   e_x[nomatch] = !values.f_nan
   e_y[nomatch] = !values.f_nan
   xfit[nomatch] = !values.f_nan
   yfit[nomatch] = !values.f_nan
   endif
endfor
; Only the hi ones
hipts = where(a2[8,*] gt 5e9,nhi) & print,nhi  
a1hi = a1[*,hipts] 
a2hi = a2[*,hipts]
a3hi = a3[*,hipts]
a4hi = a4[*,hipts]
xfithi = xfit[hipts]
yfithi = yfit[hipts]

;Avg of first two
avg2 = avg(a2hi[0,*]+a2hi[1,*]+a2hi[2,*],/double,/nan)/3d0
; Normalize
for i = 0, nffi-1 do a2hi[i,*] *= avg2/avg(a2hi[i,*],/double,/nan)
k=200
plot,a2hi[*,i+k]/a2hi[0,i+k],yrange=[.9,1.1],/nodata 
for i = 0, 100 do oplot,a2hi[*,i+k]/(a2hi[1,i+k]+a2hi[0,i+k])*2,psym=2 & k += 100
dum = ''
read,'Ready?', dum
avga2 = dblarr(nhi)

;Average for each star across FFIs
for j=0,nhi-1 do avga2[j] = avg(a2hi[*,j],/nan)
; Remove 10% deviants
;deviant = lonarr(nffi,nhi) - 1
;devlist = -1
;for i=0,nffi-1 do $
;	devlist += where(abs(a2hi[i,*]/avga2 - 1d0) gt .1,ndev)
;help,devlist
;devlist = devlist[where(devlist ne -1) ]
;help,devlist
;;devlist = devlist[uniq(devlist,sort(devlist))] 
;help,devlist
;for i=0,nffi-1 do $
;	a2hi[i,devs[uniq(devs,sort(devs))]] = !values.f_nan
;for i=0,nffi-1 do $
;	print,meanabsdev(a2hi[i,*]/(a2hi[1,*]+a2hi[0,*])*2d0,/nan) 
; Work on galaxies
readcoo,'gals.coo',gal_x,gal_y,ngals
ngals = n_elements(gal_x) & print,'ngals = ',ngals
gindex = lonarr(ngals)
for i = 0,ngals-1 do $
	gindex[i] = where((gal_x[i]-xfithi)^2+(gal_y[i]-yfithi)^2 lt 2)
gindex2 = gindex[where(gindex ne -1)]
ngals = n_elements(gindex2) & print,'ngals = ',ngals
g_a2hi = a2hi[*,gindex2]
for i=0,nffi-1 do $
	print,meanabsdev(g_a2hi[i,*]/(g_a2hi[1,*]+g_a2hi[0,*])*2d0,/nan) 
plot,mjd_arr-mjd_arr[0],g_a2hi[*,0],yrange=[0,1e10],/nodata 
for i = 0,ngals-1 do $
     oplot,mjd_arr-mjd_arr[0],g_a2hi[*,i],psym=-1 
print,'Ready? ',dum
starthere:
for i = 0, ngals-1 do begin
     plot,mjd_arr-mjd_arr[0],g_a2hi[*,i]/g_a2hi[0,i],psym=-1 ,yrange=[.9,1.1]
     wait,3
endfor
for i = 0, ngals-1 do $
     oplot,mjd_arr-mjd_arr[0],g_a2hi[*,i]/g_a2hi[0,i],psym=-1 
end
