FUNCTION get_channel,kid
RETURN,get_info(kid,'channel')
END
FUNCTION get_ra,kid
RETURN,get_info(kid,'ra')
END
FUNCTION get_dec,kid
RETURN,get_info(kid,'dec')
END
FUNCTION get_kepmag,kid
RETURN,get_info(kid,'kepmag')
END
	

FUNCTION get_info,kid,infotype

; Allowed infotypes: 'ra', 'dec', 'rmag', 'jmag', 'jmagerr', 'kepmag', 'channel',  'all' or ''
COMMON k2common,k2data,campaign
if ~keyword_set(infotype) then infotype = 'all'
if ~keyword_set(kid) then begin
	print,'get_info: Need argument kid '
	return,-1
endif

indx=WHERE(k2data.k2_id EQ kid)
indx = indx[0]
IF indx ne -1 THEN BEGIN
    CASE infotype OF
	'ra': out = k2data[indx].ra
	'dec': out = k2data[indx].dec
	'rmag': out = k2data[indx].rmag
	'rmagerr': out = k2data[indx].rmagerr
	'jmag': out = k2data[indx].jmag
	'jmagerr': out = k2data[indx].jmagerr
	'kepmag': out = k2data[indx].kepmag
	'channel': out = k2data[indx].channel
	'all': begin
		out = k2data[indx]
		help,out
		help,indx
		end
	ELSE: print,' no infotype with this name'
    ENDCASE
ENDIF ELSE BEGIN
	PRINT, 'Target ',kid,' not in k2data'
	return,0
ENDELSE
IF (infotype NE 'all') THEN PRINT,infotype+' = ',out
RETURN,out
END
