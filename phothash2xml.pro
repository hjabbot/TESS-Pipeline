PRO phothash2xml,hash,unit=unit,level=level
;-----------------------------------------------------------------------------
;+
; NAME:
;	PHOTHASH2XML
;
; PURPOSE:
;   
;
; CATEGORY:
;       Kepler data; XML 
;
; CALLING SEQUENCE:
;          
;	phothash2xml,hash,[unit=unit,level=level]
;
; INPUTS:
;       HASH - IDL version 8 or above hash.  The hash could contain IDL native 
;	values, hashes, IDL lists
;
; Keywords:
;	UNIT - If unit is set, it will print to file handled by UNIT.  
;		Otherwise, it prints to screen.
;       LEVEL - This is only used for recursion (ie internally)
;
; PACKAGE LOCATION:
;         http://www.astro.umd.edu/~eshaya/PDS/pds4readxml.tar
;
;
; IDL VERSIONS TESTED: 8.2
;
; MODIFICATION HISTORY:
;       Written Nov. 7, 2013 by Ed Shaya / U. of Maryland 
;-
;------------------------------------------------------------------

; Default for unit is to print to screen
IF ~KEYWORD_SET(unit) THEN unit = -1
IF ~KEYWORD_SET(level) THEN level = 0                     

elements = ['phot','quarter', 'group', 'target','ap']
if (level eq 0) then begin
  printf,unit,"<"+elements[level]+">"
  level++
endif
format = '(a'+STRTRIM(STRING(level*4-4),2)+',$)'
nextlevel = level + 1
FOREACH value, hash, key DO BEGIN
       IF ISA(key,/number) THEN skey = strtrim(string(key),2) ELSE skey = key
       PRINTF,unit,format=format,' '  ; Print indent ahead of time
       IF (level le 4) then begin
              PRINTF,unit,"<"+elements[level]+' id="'+skey+'">'
        ENDIF ELSE BEGIN
              IF (key EQ 'apphot') THEN BEGIN 
                nv = strtrim(string(n_elements(hash['apphot'])),2)
		      PRINTF,unit,format='(a8,'+nv+'I10)',"<phot>",hash['apphot']
	      	      PRINTF,unit,format=format,' '
	              printf,unit,'</phot>'
	      ENDIF
              IF (key EQ 'bkgnd') THEN BEGIN
		      PRINTF,unit,format='(a9,'+nv+'I10)',"<bkgnd>",hash['bkgnd']
	      	      PRINTF,unit,format=format,' '
	              printf,unit,'</bkgnd>'
	      ENDIF
	      continue
      ENDELSE
           
       ; If value of hash is a hash, send it to next level    
       IF ISA(value,'HASH') THEN BEGIN
              phothash2xml,value,unit=unit,level=nextlevel
       ; If value of hash is a list, send each item to next level       
       ENDIF ELSE BEGIN
           IF ISA(value,'LIST') THEN $
                FOREACH inList, value DO prettyhashofhash,inList,$
                        unit=unit,level=nextlevel 
       ENDELSE
       IF (level le 5) then $
       		PRINTF,unit,format=format,' '  
	        PRINTF,unit,'</'+elements[level]+'>'
ENDFOREACH
if (level eq 1) then printf,unit,"</phot>"
RETURN
END
