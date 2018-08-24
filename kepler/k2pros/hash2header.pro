FUNCTION hash2header,hash,comments

; Create a simple header of 80 nulls with just first card plus END.
;header=''
;header1=' '  
;FOR i=0,79 DO header = header+header1
;header2 = header
;header = header.Insert("SIMPLE  =                    T / conforms to FITS standards",0)
;header = [header , header2.Insert("END",0)]

; Add each element of hash and comment hash to fits header
i=0
FOREACH value, hash, key DO BEGIN
	CASE SIZE(hash[key],/tname) OF
	   'INT': format = 'I'
	   'STRING': format = 'A'
	   'LONG': format = 'I'
	   'FLOAT': format = 'G14.7'
	   'DOUBLE': format = 'G19.12'
        ENDCASE
	IF comments.haskey(key) THEN $
		sxaddpar,header,key,hash[key],comments[key],format=format $
	ELSE $
		sxaddpar,header,key,hash[key]
ENDFOREACH

RETURN,header
END
