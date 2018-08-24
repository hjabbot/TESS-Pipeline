function conditionlc,lc,times,times2

; lc - input light curve
; times - input times for light curve
; times2 - output times with no gaps
; Return  - output interplated lc at times2

; Calculate interval in times
; In case nans near beginning of times
fine = WHERE(FINITE(times))
j=0
WHILE (fine[j+1] NE fine[j]+1) DO j++
interval = times[j+1] - times[j]
nt = (times[fine[-1]]-times[fine[0]])/interval+1
times2 = times[0] + DINDGEN(nt)*interval
lc2 = INTERPOL(lc,times,times2,/nan,/lsquadratic)
RETURN,lc2
END

