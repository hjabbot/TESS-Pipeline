pro write_cbvfits,campaign,ap
; Write fits file of cbvs
; Campaign - which campaign of K2
; pcavecs - 2 dimensional array of [Nvectors,


spawn,'date -Idate',date
date=date[0]
version = 1

scampaign = strtrim(string(campaign),2)
sc = string(campaign,format='(I02)')
sap = string(ap,format='(I1)')
sbin = '0'

keys = ['SIMPLE','BITPIX','NAXIS','EXTEND','NEXTEND','EXTNAME','EXTVER','ORIGIN',$
	'DATE','CREATOR','TELESCOP','INSTRUME','CAMPAIGN','DATA_REL','OBSMODE', $
	'HLSPLEAD']

values = List('T',8,0,'T',0,'PRIMARY',1,'U. of Maryland',date,'run_phot.pro','Kepler','Kepler Photometer',scampaign,version,'long cadence','Edward J. Shaya')

sxaddpar,hdr_0,'HLSPHEAD','Edward J. Shaya',' Lead of HLSP project'
hash_0 = orderedhash(keys,values)

cmnts = List(' conforms to FITS standards', $
  ' array data type', $
  ' number of array dimensions', $
  ' file contains extensions', $
  ' number of standard extensions', $
  ' name of extension', $
  ' extension version number (not format version)', $
  ' institution responsible for creating this file', $
  ' file creation date.', $
  ' program used', $
  ' telescope', $
  ' detector type', $
  ' Observing campaign number', $
  ' data release version number', $
  ' observing mode', $
  ' Lead of HLSP Project')
cmnthash_0 = orderedhash(keys,cmnts)
hdr_0 = hash2header(hash_0,cmnthash_0)

fitsfile = 'FITSCBV/hlsp_kegs_k2_lightcurve_cbvs-c'+sc+'-ap5_kepler_v2_llc.fits'
; WRITE primary header
c=0
sxdelpar,hdr_0,'CHECKSUM'
mwrfits,c,fitsfile,hdr_0,/create

;Keys and comments for each channel are all in common, but values change somewhat

keys = ["XTENSION", "BITPIX", "NAXIS", "NAXIS1", "NAXIS2", "PCOUNT", "GCOUNT", "TFIELDS", $
 "TTYPE1", "TTYPE2", "TTYPE3", "TTYPE4", "TTYPE5", "TTYPE6", "TTYPE7", "TTYPE8", "TTYPE9", "TTYPE10", $
 "TTYPE11", $
 "TFORM1", "TFORM2", "TFORM3", "TFORM4", "TFORM5", "TFORM6", "TFORM7", "TFORM8", "TFORM9", "TFORM10", $
 "TFORM11", $
 "TUNIT1", "TDISP1", "TDISP2", "TDISP3", "TDISP4", "TDISP5", "TDISP6", "TDISP7",  "TDISP8", $
 "TDISP9", "TDISP10", "TDISP11", "INHERIT", "EXTNAME", "EXTVER", "LC_START", "LC_END", "MODULE", $
	"OUTPUT", "CHANNEL", "TELAPSE", "BVVER"] 

; Read project cbv fits file
projcbvdir = 'projcbv/'
filenm=FILE_SEARCH(projcbvdir + 'ktwo-c'+sc+'-d*_lcbv.fits',/fully_qualify_path)
stop
projcbv = read_fitswhole(filenm,/nonumbers,nextensions=84)

data0 = {time_mjd: 1d0, cadenceno: 0L, gapflag: 1L, vector1: 0.0,vector2: 0.0, $
vector3: 0.0,vector4: 0.0,vector5: 0.0,vector6: 0.0,vector7: 0.0,vector8: 0.0 }
for i=1, 84 do begin

  ; Get headers from project cbvs
  hh_cbvp = headertohash(projcbv.(i).header,comments=cmnts_cbvp)
  ccd = hh_cbvp['CHANNEL']

  IF (ccd LE 9) THEN sccd = '0'+ STRING(ccd,format='(I1)') $
  ELSE sccd = STRING(ccd,format='(I2)')
	
  cbvfile = 'Campaign'+scampaign+'/pca/cbv_ap'+sap+'_rebin'+sbin+'_ccd'+sccd+'.sav'
  test0 = file_search(cbvfile,count=count)
  IF count NE 0 THEN BEGIN
    restore,cbvfile
    pcavec = cbv
  ENDIF ELSE BEGIN
    ; If no pca vectors then stop
      PRINT,'run_phot:  No CBV File:', cbvfile
      continue
  ENDELSE
  
  datap = projcbv.(i).data

  sz = size(pcavec,/dim)
  nt = sz[1]


   hh_cbv = orderedhash()
   foreach key, keys do hh_cbv[key] = hh_cbvp[key]
   hh_cbv['NAXIS1'] = 48
   hh_cbv['NAXIS2'] = nt
   hh_cbv['TFIELDS'] = 11
   hh_cbv['BVVER'] = '1.0.0'

  hdr_cbv=hash2header(hh_cbv,cmnts_cbvp)
  
  nt2 = n_elements(datap.time_mjd)
  if nt ne nt2 then stop
  data = REPLICATE(data0,nt)
  

  data.time_mjd = datap.time_mjd
  data.cadenceno = datap.cadenceno
  data.gapflag = datap.gapflag
  pcavec = transpose(pcavec)
  nvecs = (size(pcavec,/dim))[1]
  print,'Nvecs', ccd, nvecs
  for j = 0, (nvecs-1) < 7 do begin
      data.(j+3) = pcavec[*,j]  
   endfor
              
  mwrfits,data,fitsfile,hdr_cbv
  
endfor
return 
 
end
