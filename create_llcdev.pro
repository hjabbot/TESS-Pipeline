pro create_llcdev,ukids,quarters,skygroups
	
nq = quarters[1]-quarters[0]+1
day = 48
nsmooth = 10
nsig =5
ii = 0
openw,/get_lun,wunit,"../llcdevG.txt"
foreach kid, ukids do begin
	stdevarr = dblarr(12) + !values.d_nan
	cps = fltarr(nq)
	print,kid
	llcl = read_llc(kid,quarters,llctime,/kepler)
	for q = 0, nq-1 do begin
           if (total(finite(llcl[q])) eq 0) then continue
	   ; Just remove first day and last point
	   llcl[q] = llcl[q,day:-1]
	   llctime[q] = llctime[q,day:-1]
	   ; Iterate 3 times on replacing nsig deviations with smooth fit
	   for rrr = 0, 3 do begin
		smfot=smooth(llcl[q],day*nsmooth,/nan,/edge_mirror)
		subfot = llcl[q]-smfot
		stdev = stddev(subfot,/nan)
		nogood = where(abs(subfot)/stdev gt nsig, nnogood)
		if (nnogood gt 0) then llcl[q,nogood] = smfot[nogood]
	   endfor
	   cps[q] = mean(llcl[q],/nan)
           stdevarr[q] = stddev(llcl[q],/nan)
       endfor

       printf,wunit,skygroups[ii++],kid,mean(cps,/nan),stdevarr,format='(i2,1x,i9,13e10.3)'
endforeach
free_lun,wunit
end
