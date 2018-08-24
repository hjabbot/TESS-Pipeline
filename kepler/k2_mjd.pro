pro k2_mjd,k2d,mjd,use_jd=use_jd,to_k2d=to_k2d,caldate=caldate
;  Procedure to convert from Kepler Julian Date to MJD and back

; 6.2.4 Barycentric Kepler Julian Date
; The contemporary value of BJD (~2.5 million days) is too large to be stored with milli-second precision in
; an eight byte, double precision, floating point number1. To compensate, in the target pixel files, Kepler
; reports the value of BJD-2454833.0. This time system is referred to as Barycentric Kepler Julian Date
; (BKJD). The offset is equal to the value of JD at midday on 2009-01-01. BKJD has the added advantage
; that it is only used for corrected dates, so it is more difficult to confuse BKJD dates with uncorrected JD or
; MJD. In the light curve files, the Barycentric Reduced Julian Date (BRJD, BJD-2400000.0) is reported.

; if use_jd is set then mjd becomes jd instead.
; if to_k2d is set then one is converting from either jd or mjd into k2 date.
;  use_jd  to_k2d  outcome
;   0        0      k2d => mjd
;   1        0      k2d => jd
;   0        1      mjd => k2d
;   1        1      jd  => k2d

; If caldate is set then calendar date is printed

; Conversion to MJD = JD - 2400000.5

if ~keyword_set(to_k2d) then to_k2d = 0
if ~keyword_set(use_jd) then use_jd = 0
if ~keyword_set(caldate) then caldate = 0
if use_jd then convert = 2454833.0d0 else convert = 2454833.0d0 - 2400000.5d0 
if ~to_k2d then $
	mjd = k2d + convert  $
else k2d = mjd -  convert
if use_jd then jd=mjd else jd=mjd+2400000.5d0

if caldate then begin
	caldat,jd,month,day,year
	month=strtrim(string(month),2)
	day=strtrim(string(day),2)
	year=strtrim(string(year),2)
	print,month+'/'+day+'/'+year
endif
return
end
