function sf,time,x,tau=tau,nnt=nnt,fast=fast,instant=instant

   ; instant keyword to get sf(instant) at one instant of time
   if ~keyword_set(instant) then instant = 0
   if (instant ne 0) then fast = 0
   if ~keyword_set(fast) then fast = 0
   ; Structure Function analysis of light curves
   nt = n_elements(time)
   
   ; Find first nonNAN time value
   first =  0
   while finite(time[first],/nan) do first++
   	
   sfarr = dblarr(nt)
   nnt = dblarr(nt)
   tau = dblarr(nt)
   interval = median(time-shift(time,1))
   halfinterval = interval*0.5d0
   maxtau =  (time[-1]-time[0])/2.0d0
   k = 2
   j = 0
   spread = 1.20
   ; If instant on, set firt k value right before instant time
   if (instant ne 0) then k = fix(instant/(spread*interval)) > 1
   ; Increment tauj
   time2 = time
   x2 = x
   while (tau[j-1] le maxtau) do begin
   	if (fast) then $
   		tau[j]  =  interval * exp(double(k)/4d0) $
   	else $
   		tau[j]  =  interval * double(k)
   	if ((instant gt 0) && (tau[j] gt instant*spread)) then break
   	if ((instant gt 0) && (tau[j] lt instant/spread)) then begin
		k++
		continue
	endif
   		
	nnt2 = 0L 
   	v = 0d0
   	; Consider each point in the data set for tau[j]
	tauj = tau[j]
	; Quickly take care of simple cases where tau is k elements away
	if (fast eq 0) then begin
		t_plus_tau = time + tauj
		neat = where(abs(t_plus_tau - shift(time,-k)) le halfinterval,nneat,complement=comp)
		v += total((x[neat+k] - x[neat])^2,/nan)
		time2 = time[comp]
		x2 = x[comp]
		nnt2 += nneat
	endif
   	for i=0, n_elements(time2)-1 do begin
		; IF NaN then skip over
   		if finite(x2[i],/nan) then continue
		t_plus_tau = time2[i] + tauj
		if (t_plus_tau gt time2[-1]) then break
		k2 = where(abs(time2 - t_plus_tau) le halfinterval,nk2)
		k20 = k2[0]
   		if (k20 eq -1 || finite(x2[k20],/nan) || k20 eq i ) then continue
   		v += (x2[k20] - x2[i])^2
   		nnt2++
   	endfor
   	nnt[j] = nnt2
   	sfarr[j] = v/double(nnt2)
	k++
   	j++
   endwhile
   if (instant gt 0) then sfarr[j] = v/double(nnt2)
   null = where(nnt lt 3,/null)
   sfarr[null] = !VALUES.D_NAN
   tau[null] = !VALUES.D_NAN
   tau=tau[0:j-2]
   sfarr=sfarr[0:j-2]
   nnt=nnt[0:j-2]
   ;print,instant
   ;print,'sf=',sf,'tau=',tau,'nnt=',nnt
   if (instant ne 0) then begin
   	sfarr = mean(sfarr,/nan)
   	tau = mean(tau,/nan)
   endif
return,sfarr
end
