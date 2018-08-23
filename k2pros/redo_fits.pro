pro redo_fits,kid,campaign,npca

scamp = STRTRIM(STRING(campaign),2)
snpca = STRING(npca,format='(I1)')
scampaign = 'Campaign'+STRTRIM(STRING(campaign),2)
skid = STRING(kid,format='(i9)')

pdc_flux=read_k2llc(kid,campaign,time,xc,yc,sap_flux,data=data) 
nt = n_elements(time)
k2sff = read_fitswhole('k2sff.fits',/nonumbers)
k2sff_0 =  headertohash(k2sff.header,comments=k2sff_comments)
k2sff_bestap =  headertohash(k2sff.bestaper.header,comments=hash_lc_comments)
k2sff_ap =  headertohash(k2sff.prf_aper_tbl.header,comments=hash_ap_comments)
removed = k2sff_bestap.Remove('WCSN9P')
removed = k2sff_bestap.Remove('WCAX9P')
removed = k2sff_bestap.Remove('1CTY9P')
removed = k2sff_bestap.Remove('2CTY9P')
removed = k2sff_bestap.Remove('1CUN9P')
removed = k2sff_bestap.Remove('2CUN9P')
removed = k2sff_bestap.Remove('1CRV9P')
removed = k2sff_bestap.Remove('2CRV9P')
removed = k2sff_bestap.Remove('1CDL9P')
removed = k2sff_bestap.Remove('2CDL9P')
removed = k2sff_bestap.Remove('1CRP9P')
removed = k2sff_bestap.Remove('2CRP9P')
removed = k2sff_bestap.Remove('WCAX9')
removed = k2sff_bestap.Remove('1CTYP9')
removed = k2sff_bestap.Remove('2CTYP9')
removed = k2sff_bestap.Remove('1CRPX9')
removed = k2sff_bestap.Remove('2CRPX9')
removed = k2sff_bestap.Remove('1CRVL9')
removed = k2sff_bestap.Remove('2CRVL9')
removed = k2sff_bestap.Remove('1CUNI9')
removed = k2sff_bestap.Remove('2CUNI9')
removed = k2sff_bestap.Remove('1CDLT9')
removed = k2sff_bestap.Remove('2CDLT9')
removed = k2sff_bestap.Remove('11PC9')
removed = k2sff_bestap.Remove('12PC9')
removed = k2sff_bestap.Remove('21PC9')
removed = k2sff_bestap.Remove('22PC9')

; Header data for this kid
hdr_0 = data.header
hdr_lc = data.lightcurve.header
hdr_ap = data.aperture.header

fitsfile = scampaign+'/FITS/KEGS_K2_lightcurve_'+skid+'_C'+scamp+'_v1.fits'
; Datatable
datatable5 = {time:0d0, cadenceno: 0L, fraw:0d0, fcor1:0d0, $
		fcor2:0d0,fcor3:0d0, fcor4:0d0, fcor5:0d0 }
datatable5 = replicate(datatable5,nt)
;datatable5.time = time
;datatable5.cadenceno = data.lightcurve.data.cadenceno

if file_test(fitsfile,/regular) then $
	fits = read_fitswhole(fitsfile,/nonumbers) $
else $
	return

datatable5.fraw = fits.targettables5[0].data.fraw
datatable5.time = fits.targettables5[0].data.time
datatable5.cadenceno = fits.targettables5[0].data.cadenceno

hdr_0 = fits.header
hash_ap = headertohash(fits.aperture5[0].header,$
	comments=hash_ap_comments)
hash_lc = headertohash(fits.targettables5[0].header,$
	comments=hash_lc_comments)
datatable5.fcor1 = fits.targettables5[0].data.fcor1
datatable5.fcor2 = fits.targettables5[0].data.fcor2
datatable5.fcor3 = fits.targettables5[0].data.fcor3
datatable5.fcor4 = fits.targettables5[0].data.fcor4
datatable5.fcor5 = fits.targettables5[0].data.fcor5

apmask = fits.aperture5[0].data

; Remove SIMPLE header if it sneaked in
;if hash_lc.haskey('SIMPLE') then removed=hash_lc.Remove('SIMPLE')
;if hash_ap.haskey('SIMPLE') then removed=hash_ap.Remove('SIMPLE')

; Remove comment from hash
if hash_lc.haskey('COMMENT') then removed=hash_lc.Remove('COMMENT')

; Convert hash_lc to header for targettables
hdr_lc5 = hash2header(hash_lc,hash_lc_comments)

; Convert hash_ap to header for targettables
hdr_ap5 = hash2header(hash_ap,hash_ap_comments)


; Change KEPLERID to TARGNAME
kid=sxpar(hdr_0,'KEPLERID',comment=comment)
sxaddpar,hdr_0,'TARGNAME',kid,comment,after='KEPLERID'
sxdelpar,hdr_0,'KEPLERID'
sxaddpar,hdr_lc5,'TARGNAME',kid,comment,after='KEPLERID'
sxdelpar,hdr_lc5,'KEPLERID'
sxaddpar,hdr_ap5,'TARGNAME',kid,comment,after='KEPLERID'
sxdelpar,hdr_ap5,'KEPLERID'

; Change RA_OBJ to RA_TARG
ra=sxpar(hdr_0,'RA_OBJ',comment=comment)
sxaddpar,hdr_0,'RA_TARG',ra,comment,after='RA_OBJ'
sxdelpar,hdr_0,'RA_OBJ'
sxaddpar,hdr_lc5,'RA_TARG',ra,comment,after='RA_OBJ'
sxdelpar,hdr_lc5,'RA_OBJ'
sxaddpar,hdr_ap5,'RA_TARG',ra,comment,after='RA_OBJ'
sxdelpar,hdr_ap5,'RA_OBJ'

; Change DEC_OBJ to DEC_TARG
dec=sxpar(hdr_0,'DEC_OBJ',comment=comment)
sxaddpar,hdr_0,'DEC_TARG',dec,comment,after='DEC_OBJ'
sxdelpar,hdr_0,'DEC_OBJ'
sxaddpar,hdr_lc5,'DEC_TARG',dec,comment,after='DEC_OBJ'
sxdelpar,hdr_lc5,'DEC_OBJ'
sxaddpar,hdr_ap5,'DEC_TARG',dec,comment,after='DEC_OBJ'
sxdelpar,hdr_ap5,'DEC_OBJ'

for npca = 1, 5 do begin
	for j = 1, npca do begin
		npcas = string(npca,format='(I1)')
		js = string(j,format='(I1)')
		key = 'CBV' + npcas + '_' + js
		value=sxpar(hdr_lc5,key,comment=comment)
		comment = ' KEGS team CBV '+ js +' coefficient for FCOR'+npcas
		key2 = 'KEGCBV' + npcas + js
		sxaddpar,hdr_lc5,key2,value,comment,after=key
		sxdelpar,hdr_lc5,key
	endfor
endfor

; Add HLSPHEAD
sxaddpar,hdr_0,'HLSPHEAD','Edward J. Shaya',' Lead of HLSP project'
scamp=string(campaign,format='(I02)')
fitsfile = scampaign+'/FITS/hlsp_kegs_k2_lightcurve_'+skid+'-c'+scamp+'_kepler_v1_llc.fits'


; WRITE primary header 
sxdelpar,hdr_0,'CHECKSUM'
mwrfits,c,fitsfile,hdr_0,/create

; Write targettable5 data
sxdelpar,hdr_lc5,'CHECKSUM'
;fits_add_checksum, hdr_lc5, datatable5, /FROM_IEEE
mwrfits,datatable5,fitsfile,hdr_lc5

; WRITE aperture image
sxdelpar,hdr_ap5,'CHECKSUM'
;fits_add_checksum, hdr_ap5, apmask, /FROM_IEEE
mwrfits,apmask,fitsfile,hdr_ap5

return
end
