pro check_fits,kid,campaign,unit

if ~keyword_set(unit) then unit = -1

scamp = STRING(campaign,format='(I02)')
scampaign = 'Campaign'+STRTRIM(STRING(campaign),2)
skid = STRING(kid,format='(i9)')

fitsfile = scampaign+'/FITS/hlsp_kegs_k2_lightcurve_'+skid+'-c'+scamp+'_kepler_v1_llc.fits'
if file_test(fitsfile,/regular) then begin
	fits = read_fitswhole(fitsfile,/nonumbers,nextensions=2) 
endif else begin 
	fitsfile2 = fitsfile+'.gz'
	if file_test(fitsfile2,/regular) then begin
		fits = read_fitswhole(fitsfile2,/compress,/nonumbers,nextensions=2) 
	endif else begin
		printf,unit,'check_fits: no fitsfile ',fitsfile
		print,'check_fits: no fitsfile ',fitsfile
		return
	endelse
endelse

fraw = fits.targettables5[0].data.fraw
time = fits.targettables5[0].data.time
cadenceno = fits.targettables5[0].data.cadenceno
printf,unit,'fraw:',string(size(fraw,/dim))
printf,unit,'time:',string(size(time,/dim))
printf,unit,'cadenceno:',string(size(cadenceno,/dim))

hdr_0 = fits.header
hdr_ap = fits.aperture5[0].header
hdr_lc = fits.targettables5[0].header

;hash_lc = headertohash(fits.targettables5[0].header,$
;	comments=hash_lc_comments)
;hash_ap = headertohash(fits.aperture5[0].header,$
;	comments=hash_ap_comments)
fcor1 = fits.targettables5[0].data.fcor1
fcor2 = fits.targettables5[0].data.fcor2
fcor3 = fits.targettables5[0].data.fcor3
fcor4 = fits.targettables5[0].data.fcor4
fcor5 = fits.targettables5[0].data.fcor5
printf,unit,'fcor1:',string(size(fcor1,/dim))
printf,unit,'fcor2:',string(size(fcor2,/dim))
printf,unit,'fcor3:',string(size(fcor3,/dim))
printf,unit,'fcor4:',string(size(fcor4,/dim))
printf,unit,'fcor5:',string(size(fcor5,/dim))

apmask = fits.aperture5[0].data
printf,unit,'apmask:',string(size(apmask,/dim))

object=sxpar(hdr_0,'OBJECT',comment=comment)
targname=sxpar(hdr_0,'TARGNAME',comment=comment)
ra=sxpar(hdr_0,'RA_TARG',comment=comment)
dec=sxpar(hdr_0,'DEC_TARG',comment=comment)
printf,unit,format='(A8,1X,a15,1X,I9,2D10.5)','PRIMARY: ',object,targname,ra,dec

object=sxpar(hdr_lc,'OBJECT',comment=comment)
targname=sxpar(hdr_lc,'TARGNAME',comment=comment)
ra=sxpar(hdr_lc,'RA_TARG',comment=comment)
dec=sxpar(hdr_lc,'DEC_TARG',comment=comment)
printf,unit,format='(A6,1X,a15,1X,I9,2D10.5)','Table: ',object,targname,ra,dec

object=sxpar(hdr_ap,'OBJECT',comment=comment)
targname=sxpar(hdr_ap,'TARGNAME',comment=comment)
ra=sxpar(hdr_ap,'RA_TARG',comment=comment)
dec=sxpar(hdr_ap,'DEC_TARG',comment=comment)
printf,unit,format='(A3,1X,a15,1X,I9,2D10.5)','AP: ',object,targname,ra,dec
; Write targettable5 data
;fits_add_checksum, hdr_lc5, datatable5, /FROM_IEEE
;mwrfits,datatable5,fitsfile,hdr_lc5

; WRITE aperture image
;fits_add_checksum, hdr_ap5, apmask, /FROM_IEEE
;mwrfits,apmask,fitsfile,hdr_ap5
return
end
