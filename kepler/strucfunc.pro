function strucfunc, t, x, tau1=tau1, tau2=tau2, dtau=dtau, sdevmax = sdevmax
; This routine regrids the light curve x and then
; calls strucfuncbase
; t is corresponding times for x
; tau1 is first delay time
; tau2 is second delay time
; dtau is step in delay time
; sdevmax - put NaN where x deviates by  more than  sdevmax standard deviations

if ~keyword_set(sdevmax) then sdevmax = 5d0
mom = moment(x,/nan,maxmoment=2, sdev=sdev, mean=mean,/double)
x0 = x
x0[where(ABS(x0-mean) GT sdevmax*sdev,/null)] = !VALUES.D_NAN

t0 = t[where(finite(t))]
t0 = t0 - t0[0]
x0 = x0[where(finite(t))]
dt = median(t0 - shift(t0,1))
print, 'strucfunc: time steps in minutes: ', dt*24*60
nt = t0[-1]/dt - 1
print, 'strucfunc: number of time steps: ', nt
x2 = dblarr(nt)
t2 = dindgen(nt)*dt
tcomb = [t2,t0]
xcomb = [x2,x0]
isrt = sort(tcomb)
tcombsrt =  tcomb[isrt]
xcombsrt = xcomb[isrt]
; It is from x if isrt > nt - 1
original = where(isrt ge nt)
; It is from x2 if isrt < nt
new = where(isrt lt nt)
x2[0] = x0[0]
for i = 1, nt - 1 do begin
	j = new[i]
	; Test if j-1 is from original x
	if (isrt[j-1] ge nt) then $
		dta = tcombsrt[j]  - tcombsrt[j-1] $
		else dta = 1d3
	; Test if j+1 is from original x
	if (isrt[j+1] ge nt) then $
		dtb = tcombsrt[j+1] - tcombsrt[j]   $
		else dtb = 1d3
	dtc = dta < dtb
	if (dtc le dt/2d0) then begin
		if (dta le dtb) then x2[i] = xcombsrt[j-1]
		if (dta gt dtb) then x2[i] = xcombsrt[j+1]
	endif else x2[i] = !values.d_nan
endfor
;plt = scatterplot(t2,x2,symbol='square',sym_color='red')
;plt = scatterplot(/overplot,t0,x0,symbol='plus')
sfpair = strucfuncbase(x2,dtime=dt,tau1=tau1,tau2=tau2,dtau=dtau)
return,sfpair
end


