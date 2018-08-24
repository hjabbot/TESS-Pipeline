pro write_fits_lc,kid,campaign,npca,hdr_0,hdr_lc,hdr_ap,cadenceno,raw,phot,hdr_targ,time,fullp,apmask
scampaign = 'Campaign'+STRTRIM(STRING(campaign),2)
skid = STRING(kid,format='(i9)')
scamp=string(campaign,format='(I02)')

; The MAST fitsfile name
fitsfile = scampaign+'/FITS/hlsp_kegs_k2_lightcurve_'+skid+'-c'+scamp+'_kepler_v2_llc.fits'

; Datatable for 1st extension
datatable5 = {time:0d0, cadenceno: 0L, fraw:0d0, fcor1:0d0, $
		fcor2:0d0,fcor3:0d0, fcor4:0d0, fcor5:0d0 }
nt = n_elements(time)
datatable5 = replicate(datatable5,nt)

; Change KEPLERID to TARGNAME
targ_comment = ' unique Kepler target identifier'
sxaddpar,hdr_0,'TARGNAME',kid,targ_comment,after='OBJECT'
sxdelpar,hdr_0,'KEPLERID'
sxaddpar,hdr_lc,'TARGNAME',kid,targ_comment,after='OBJECT'
sxdelpar,hdr_lc,'KEPLERID'
sxaddpar,hdr_targ,'TARGNAME',kid,targ_comment,after='OBJECT'
sxdelpar,hdr_targ,'KEPLERID'
sxaddpar,hdr_ap,'TARGNAME',kid,targ_comment,after='OBJECT'
sxdelpar,hdr_ap,'KEPLERID'
	
; Change RA_OBJ to RA_TARG
object = sxpar(hdr_0,'OBJECT',comment=object_comment)
print,object,'********************'
ra = sxpar(hdr_0,'RA_OBJ',comment=ra_comment)
sxaddpar,hdr_0,'RA_TARG',ra,ra_comment,after='TARGNAME'
sxdelpar,hdr_0,'RA_OBJ'
sxaddpar,hdr_targ,'RA_TARG',ra,ra_comment,after='TARGNAME'
sxdelpar,hdr_targ,'RA_OBJ'
sxaddpar,hdr_lc,'RA_TARG',ra,ra_comment,after='TARGNAME'
sxdelpar,hdr_lc,'RA_OBJ'
sxaddpar,hdr_ap,'RA_TARG',ra,ra_comment,after='TARGNAME'
sxdelpar,hdr_ap,'RA_OBJ'
	
; Change DEC_OBJ to DEC_TARG
dec = sxpar(hdr_0,'DEC_OBJ',comment=dec_comment)
sxaddpar,hdr_0,'DEC_TARG',dec,dec_comment,after='RA_TARG'
sxdelpar,hdr_0,'DEC_OBJ'
sxaddpar,hdr_targ,'DEC_TARG',dec,dec_comment,after='RA_TARG'
sxdelpar,hdr_targ,'DEC_OBJ'
sxaddpar,hdr_lc,'DEC_TARG',dec,dec_comment,after='RA_TARG'
sxdelpar,hdr_lc,'DEC_OBJ'
sxaddpar,hdr_ap,'DEC_TARG',dec,dec_comment,after='RA_TARG'
sxdelpar,hdr_ap,'DEC_OBJ'

; hashes of values and comments from llc extension 1 
kid_lc = header2hash(hdr_lc,keydefs=lc_comments)
	
; If fits file already exists, read it.
if file_test(fitsfile,/regular) then begin
	fits = read_fitswhole(fitsfile,/nonumbers,nextensions=2)
	fitshdr_0 = fits.header
	sxaddpar,fitshdr_0,'OBJECT',object

	hdr_0 = fitshdr_0

	fitshdr_lc = fits.targettables5[0].header
	fitshdr_ap = fits.aperture5[0].header

	;;;; Temporary FIX
	; Change KEPLERID to TARGNAME
	;sxaddpar,fitshdr_lc,'OBJECT',object
	;sxaddpar,fitshdr_ap,'OBJECT',object
	;sxaddpar,fitshdr_lc,'TARGNAME',kid,targ_comment,after='OBJECT'
	;sxdelpar,fitshdr_lc,'KEPLERID'
	;sxaddpar,fitshdr_ap,'TARGNAME',kid,targ_comment,after='OBJECT'
	;sxdelpar,fitshdr_ap,'KEPLERID'
	;	
	;; Change RA_OBJ to RA_TARG
	;sxaddpar,fitshdr_lc,'RA_TARG',ra,ra_comment,after='TARGNAME'
	;sxdelpar,fitshdr_lc,'RA_OBJ'
	;sxaddpar,fitshdr_ap,'RA_TARG',ra,ra_comment,after='TARGNAME'
	;sxdelpar,fitshdr_ap,'RA_OBJ'
	;	
	; Change DEC_OBJ to DEC_TARG
	;sxaddpar,fitshdr_lc,'DEC_TARG',dec,dec_comment,after='RA_TARG'
	;sxdelpar,fitshdr_lc,'DEC_OBJ'
	;sxaddpar,fitshdr_ap,'DEC_TARG',dec,dec_comment,after='RA_TARG'
	;sxdelpar,fitshdr_ap,'DEC_OBJ'
	;;;;

	hash_lc = header2hash(fitshdr_lc,keydefs=hash_lc_comments)
	hdr_ap5 = fitshdr_ap

	datatable5= fits.targettables5[0].data

	apmask2 = fits.aperture5[0].data
	; Check that the apmask in the fits file is 2 dimensional
	; if not use the apmask that was passed in.
	IF SIZE(apmask2,/n_dim) EQ 2 THEN apmask=apmask2


; If first time, create a fits file for this kid
endif else begin

	; Create headers
	; Primary header
	; Gather header keywords and comments needed to write to fits.
	k2sff = mrdfits('k2sff.fits',0,k2sff_hdr)
	sxaddpar,k2sff_hdr,'TARGNAME',kid,targ_comment,after='OBJECT'
	sxaddpar,k2sff_hdr,'RA_TARG',ra,ra_comment,after='TARGNAME'
	sxaddpar,k2sff_hdr,'DEC_TARG',dec,dec_comment,after='RA_TARG'
	k2sff_0 =  header2hash(k2sff_hdr,keydefs=k2sff_comments)
	removed=k2sff_0.Remove('KEPLERID')
	removed=k2sff_0.Remove('RA_OBJ')
	removed=k2sff_0.Remove('DEC_OBJ')
	
	k2sff = mrdfits('k2sff.fits',1,k2sff_hdr)
	k2sff_hdr2=[k2sff_hdr[0:10],k2sff_hdr[173:*]]
	sxaddpar,k2sff_hdr2,'TARGNAME',kid,targ_comment,after='OBJECT'
	sxaddpar,k2sff_hdr2,'RA_TARG',ra,ra_comment,after='TARGNAME'
	sxaddpar,k2sff_hdr2,'DEC_TARG',dec,dec_comment,after='RA_TARG'
	k2sff_lc =  header2hash(k2sff_hdr2,keydefs=hash_lc_comments)
	removed=k2sff_lc.Remove('KEPLERID')
	removed=k2sff_lc.Remove('RA_OBJ')
	removed=k2sff_lc.Remove('DEC_OBJ')
	
	k2sff = mrdfits('k2sff.fits',2,k2sff_hdr)

	hash_0 = ORDEREDHASH()
	kid_0 = header2hash(hdr_0,keydefs=kid_comments)
 
	; For each key in k2sff put value from target llc file
        FOREACH value, k2sff_0, key DO hash_0[key] = kid_0[key] 
	;hash_0['OBJECT'] = kid_0['OBJECT']

	; Turn hash_0 into primary header
	hdr_0 = hash2header(hash_0,k2sff_comments)

	; Data table header
	hash_lc = ORDEREDHASH()
	kid_lc = header2hash(hdr_lc,keydefs=lc_comments)
	kid_targ = header2hash(hdr_targ)
        FOREACH value, k2sff_lc, key DO BEGIN
		IF kid_0.haskey(key) then hash_lc[key] = kid_0[key]
		IF kid_lc.haskey(key) then hash_lc[key] = kid_lc[key]
		IF kid_targ.haskey(key) then hash_lc[key] = kid_targ[key]
	ENDFOREACH

	hash_lc['TTYPE2'] = 'CADENCENO'
	hash_lc['TTYPE3'] = 'FRAW'
	hash_lc['TTYPE4'] = 'FCOR1'
	hash_lc['TTYPE5'] = 'FCOR2'
	hash_lc['TTYPE6'] = 'FCOR3'
	hash_lc['TTYPE7'] = 'FCOR4'
	hash_lc['TTYPE8'] = 'FCOR5'

	hash_lc['TFORM2'] = 'J'
	hash_lc['TFORM3'] = '255E'
	hash_lc['TFORM4'] = '255E'
	hash_lc['TFORM5'] = '255E'
	hash_lc['TFORM6'] = '255E'
	hash_lc['TFORM7'] = '255E'
	hash_lc['TFORM8'] = '255E'

	hash_lc['NAXIS1'] =  60
	hash_lc['TFIELDS'] = 8 
	hash_lc['EXTNAME'] = 'TARGETTABLES5'
	hash_lc['OBJECT'] = kid_0['OBJECT']

	keys = hash_lc.Keys()
	foreach key, keys do begin
		if strmatch(key,'1*') or strmatch(key,'2*') $
				or strmatch(key,'W*') then begin
			removed = hash_lc.Remove(key)
		endif
	endforeach
	hash_lc['TUNIT1'] = 'd'
	hash_lc['TUNIT3'] = 'DN/s'
	hash_lc['TUNIT4'] = 'DN/s'
	hash_lc['TUNIT5'] = 'DN/s'
	hash_lc['TUNIT6'] = 'DN/s'
	hash_lc['TUNIT7'] = 'DN/s'
	hash_lc['TUNIT8'] = 'DN/s'

	; Aperture header
	sxaddpar,hdr_ap,'EXTNAME','APERTURE5'
	hdr_ap5 = hdr_ap

	; Put raw LC into datatable5
	datatable5.time = time
	datatable5.cadenceno = cadenceno
	datatable5.fraw = raw


endelse

; Primary image is empty
c = 0L
; Add CBV coefficients to datatable hdr used in each this LC
FOR i = 1, npca do begin
	is = string(i,format='(I1)')
	npcas = string(npca,format='(I1)')
	key = 'KEGCBV' + npcas + is
	comment = ' KEGS Team CBV '+ is +' coefficient for FCOR'+npcas
	hash_lc[key] = fullp[i+6]
	hash_lc_comments[key] = comment
ENDFOR

; Present LC overwrites if needed
if npca ne 0 then datatable5.(npca+2) = phot

; Remove SIMPLE header if it sneaked in
if hash_lc.haskey('SIMPLE') then removed=hash_lc.Remove('SIMPLE')
sxdelpar,hdr_ap5,'SIMPLE'

sxdelpar,hdr_0,'CHECKSUM'
sxdelpar,hdr_ap5,'CHECKSUM'

; remove comment from hash
if hash_lc.haskey('COMMENT') then removed=hash_lc.Remove('COMMENT')
if hash_lc.haskey('CHECKSUM') then removed=hash_lc.Remove('CHECKSUM')

; Convert hash_lc to header for targettables
hdr_lc5 = hash2header(hash_lc,hash_lc_comments)

; Add HLSPHEAD
sxaddpar,hdr_0,'HLSPHEAD','Edward J. Shaya',' Lead of HLSP project'

; WRITE primary header
mwrfits,c,fitsfile,hdr_0,/create

; Write targettable5 data
sxdelpar,hdr_lc5,'CHECKSUM'
;fits_add_checksum, hdr_lc5, datatable5, /FROM_IEEE
mwrfits,datatable5,fitsfile,hdr_lc5

; WRITE aperture image
fits_add_checksum, hdr_ap5, apmask, /FROM_IEEE
mwrfits,apmask,fitsfile,hdr_ap5
return
end
