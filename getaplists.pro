PRO GETAPLISTS,startffi=startffi,endffi=endffi,startchannel=startchannel,endchannel=endchannel,addcr1=addcr1,addcr2=addcr2
if ~keyword_set(startchannel) then startchannel=1
if ~keyword_set(endchannel) then endchannel=84
; Get number of ffis
SPAWN, 'ls -1 FFIs', ffilist
nffis = N_ELEMENTS(ffilist)
DBOPEN,'kic'
if ~keyword_set(startffi) then startffi = 0
if ~keyword_set(endffi) then endffi = nffis-1
FOR i = startffi, endffi DO BEGIN
	PRINT, ' FFI = ',i
	data = read_fitswhole("FFIs/"+ffilist[i])
	tag = gettagsbyname(data, 'HEADER', root='data')
	FOR j = startchannel, endchannel do begin
		r = EXECUTE('hdr='+tag[j])
		SXDELPAR, hdr, 'PC1_1'
		SXDELPAR, hdr, 'PC1_2'
		SXDELPAR, hdr, 'PC2_1'
		SXDELPAR, hdr, 'PC2_2'
		SIP_List1=['A_ORDER','B_ORDER','A_2_0','A_0_2','A_1_1','B_2_0','B_0_2','B_1_1','AP_ORDER','BP_ORDER','AP_1_0','AP_0_1','AP_2_0','AP_0_2','AP_1_1','BP_1_0','BP_0_1','BP_2_0','BP_0_2','BP_1_1','A_DMAX','B_DMAX']	
		SIP_List2=['X_ORDER','Y_ORDER','X_2_0','X_0_2','X_1_1','Y_2_0','Y_0_2','Y_1_1','XP_ORDER','YP_ORDER','XP_1_0','XP_0_1','XP_2_0','XP_0_2','XP_1_1','YP_1_0','YP_0_1','YP_2_0','YP_0_2','YP_1_1','X_DMAX','Y_DMAX']	
		FOR p = 0, N_ELEMENTS(SIP_List1)-1 DO BEGIN
			v = SXPAR(hdr,SIP_List1[p], count=pcount)
			IF (pcount EQ 0) THEN BREAK
			IF (pcount GT 1) THEN BEGIN
				PRINT,' MORE THAN ONE ',SIP_LIST1[p]
				stop
			ENDIF
			SXADDPAR,hdr,SIP_List2[p],v[0]
			SXDELPAR,hdr,SIP_List1[p]
		ENDFOR
		s=SXPAR(hdr,'CTYPE1')
		IF (s EQ 'RA---TAN-SIP') THEN SXADDPAR,hdr,'CTYPE1','RA---TAN'
		s=SXPAR(hdr,'CTYPE2')
		IF (s EQ 'DEC---TAN-SIP') THEN SXADDPAR,hdr,'CTYPE2','DEc---TAN'
 		EXTAST, hdr, astr, noparam
		if (i eq 8) then begin
			;addcr1 = .005d0
			;addcr2 = .002d0
			astr.crval[0] += addcr1
			astr.crval[1] += addcr2
		endif
		print,' noparam = ',noparam
		XY2AD, 500., 500., astr, ra, dec 
		list = dbcircle(ra/15.,dec,55.)
		DBEXT,list,'KEPLER_ID,KEPMAG,RA,DEC',kid,kepmag,a,d
		a=a*15.
		AD2XY,a,d,astr,x,y
		in = WHERE( x gt 20 and x lt 1110 and y gt 20 and y lt 1040,count)
		print,'Channnel',j,': COUNT = ',count
		kid = kid[in] & kepmag = kepmag[in] 
		a = a[in] & d = d[in] 
		x = x[in] & y = y[in]
		file = 'apdir/k'+STRMID(ffilist[i],4,13)+'_ch'+STRTRIM(STRING(j),2)+'.ap'
		openw,/get_lun,unit,file
		PRINTF, unit, ffilist[i],' Channel ',j
		PRINTF, unit, count
		PRINTF, unit, format='(a8,2(a9,1x),2(a8,1x),2x,a8)','Kep_ID','RA','DEC','x','y','KepMag'
		FOR k = 0, count-1 DO $
	           printf,unit,format='(I8,2x,2(F9.5,1x),3(F8.3,1x))',kid[k],a[k],d[k],x[k],y[k],kepmag[k]
	        FREE_LUN, unit
	 ENDFOR  ; end loop on channels
 ENDFOR  ; end loop on ffis
 END

