function kepler_mag_bv,m1,m2,b_v
; Convert from B,V or g,r-bands to Kepler magnitudes
; m1 is either g or b
; m2 is either r or v
; if b_v is 1, the using B,V else using g,r
IF (b_v) THEN BEGIN
	g = 0.548*m1 + 0.46*m2 - 0.07
	r = -0.44*m1 + 1.44*m2 + 0.12
ENDIF ELSE BEGIN
	g = m1
	r = m2
ENDELSE
IF (g-r LE 0.8) THEN $
	kp = 0.2*g + 0.8*r $
ELSE $
	kp = 0.1*g + 0.9*r

return,kp
end
