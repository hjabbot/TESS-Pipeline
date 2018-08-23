PRO READ_KIC,kic_str,build=build
filename='/home/eshaya/Documents/Kepler/KIC/kic10.txt'
OPENR,unit,/get_lun,filename
s=''
; Skip header
READF,unit,s
IF ~KEYWORD_SET(build) THEN build = 0

; ra_hrs F
; dec F
; pmra F
; pmdec F
; umapg F
; gmag F
; rmag F
; imag F
; zmag F
; gredmag F
; d51mag F
; jmag F
; hmag F
; kmag F
; kepmag F
; kepler_id J
; twomass_des J
; scpid J
; altid J
; altsource B
; galaxy B
; blend B
; variable B
; Teff I
; log_g F
; FeoH F
; Eb_v F
; Av F
; radius F
; Kepmag_src A
; Photom_qual B
; Ast_qual B
; Catalog_key J
; scp_key J
; parallax F
; glon F
; glat F
; pmtotal F
; grcolor F
; jkcolor F
; gkcolor F
; ra_deg F
; FOV_flag B
; twomass_id A

tagnames=['RA_hrs','DEC','PMRA','PMDEC','Umag',$
  'Gmag','Rmag','Imag','Zmag','Gredmag','D51mag','Jmag','Hmag',$
  'Kmag','KEPmag','Kepler_id','TWOMASS_des','SCP_id','alt_id','alt_source',$
  'galaxy','blend','variable','Teff','Log_g','FeoH','Eb_v',$
  'Av','radius','Kepmag_src','Phot_qual','Ast_qual','Catalog_key','scp_key','parallax',$
  'GLON','GLAT','pm_total','GRcolor','JKcolor','GKcolor','RA_deg',$
  'FOV_flag','TWOMASs_id']

; Tag descriptions
;  'A' for strings, 'B' or 'L' for unsigned byte integers, 'I' for integers, 
;  'J' for longword integers, 'K' for 64bit integers,
;   'F' or 'E' for floating point, 'D' for double precision  'C' for complex, 
;    and 'M' for double complex.
tag_descript = 'D,D,F,F,F,F,F,F,F,F,F,F,F,F,F,J,J,J,J,I,B,B,B,I,F,F,F,F,F,A,B,B,J,J,F,F,F,F,F,F,F,F,B,A'
descripts = strsplit(tag_descript,',',/extract)
dimen=13161029L
CREATE_STRUCT,kic_str, 'kic10',tagnames,tag_descript,dimen=dimen
j=0L
WHILE ~eof(unit) DO BEGIN
   READF,unit,s
   z = strsplit(s,'|',/extract,/preserve_null)
   FOR i = 0,N_ELEMENTS(tagnames)-1 DO BEGIN
        IF (z[i] EQ '') THEN BEGIN
            CASE descripts[i] OF
                'F': in = !VALUES.F_NAN
                'D': in = !VALUES.D_NAN
                'I': in = -1
                'J': in = -1
                'B': in = 0
                'A': in = ''
                ELSE: print, 'No such tag description ',$
                        descripts[i]
            ENDCASE
            kic_str[j].(i) = in   
        ENDIF ELSE BEGIN
            kic_str[j].(i) = z[i]
        ENDELSE
	 ;print,j,' ',i,' ',z[i],tagnames[i], descripts[i]
   ENDFOR
   j++
   IF (j MOD 100000 EQ 0) THEN PRINT,j
ENDWHILE
IF (build eq 1) THEN BEGIN
  !priv=2
  dbopen,'kic',1
  dbbuild,kic_str.kepler_id,kic_str.ra_hrs,kic_str.dec,kic_str.twomass_id,kic_str.fov_flag,$
  kic_str.pmra,kic_str.pmdec,kic_str.umag,kic_str.gmag,kic_str.rmag,kic_str.imag,kic_str.zmag,$
  kic_str.gredmag,kic_str.d51mag,kic_str.jmag,kic_str.hmag,kic_str.kmag,$
  kic_str.kepmag,kic_str.twomass_des,kic_str.scp_id,kic_str.alt_id,kic_str.alt_source,$
  kic_str.galaxy,kic_str.blend,kic_str.variable,$
  kic_str.teff,kic_str.log_g,kic_str.feoh,kic_str.eb_v,kic_str.av,kic_str.radius,kic_str.kepmag_src,$
  kic_str.phot_qual,kic_str.ast_qual,kic_str.parallax,kic_str.glon,kic_str.glat,$
  kic_str.pm_total,kic_str.grcolor,kic_str.jkcolor,kic_str.gkcolor,kic_str.ra_deg
ENDIF
return
END

