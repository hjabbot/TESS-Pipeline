function strucfuncbase,x,dtime=dtime,tau1=tau1,tau2=tau2,dtau=dtau
; Structure Function 
; Assumes time series is fully sampled at constant cadence
; But there can be NaNs
; x is time series
; tau1 is shortest delay time
; tau1 is longest delay time
; dt is time interval of consecutive elements in x
; dtau is step in tau
dt = dtime
nx = n_elements(x)
if ~keyword_set(dt) then dt = 1
if ~keyword_set(tau1) then tau1 = dt
if ~keyword_set(tau2) then tau2 = dt*(nx-1)
if ~keyword_set(dtau) then dtau = dt
x = double(x)
av = total(x,/nan)/total(finite(x))
x = x/av
x2 = x
sf = dblarr((tau2-tau1)/dtau + 1)
ntau = n_elements(sf)
tau = dindgen(ntau)*dtau + tau1
j = 0
for i = tau1, tau2, dtau do begin
	dx = dtau/dt
	x2 = shift(x2,dx)
	x2[0:dx-1] = !values.d_nan
	diff2 = (x2 - x)^2
	nnt = total(finite(diff2))
	if nnt le 1 then print,j,nnt
	sf[j++] = total(diff2,/nan)/total(finite(diff2))
endfor
sfpair = [[tau],[sf]]
return,sfpair
end
	
