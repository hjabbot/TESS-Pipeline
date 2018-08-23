pro stitch,a,b,t1,t2,delta0,c
	delta1 = delta0 < n_elements(a)/2
	delta2 = delta0 < n_elements(b)/2
	repeat begin
	    delta1--
	    if (delta1 le 0) then begin
		    print,'stitch: delta1 went to 0'
		    c = -1
		    return
	    endif
	    a1 = mean(a[-delta1:-1],/nan)
	    a2 = mean(a[-2*delta1:-delta1-1],/nan)
	endrep until (total(finite([a1,a2,t1[-delta1]])) eq 3) 

	repeat begin
	    delta2--
	    if (delta2 le 0) then begin
		    print,'stitch: delta2 went to 0'
		    c = -1
		    return
	    endif
	    b1 = mean(b[0:delta2-1],/nan)
	    b2 = mean(b[delta2:2d0*delta2],/nan)
	endrep until (total(finite([b1,b2,t2[delta2]])) eq 3) 

	rate1 = (a1 - a2)/$
	       (mean(t1[-delta1:-1],/nan)- mean(t1[-2*delta1:-delta1-1],/nan))
	valuea = (a1+a2)/2d0 + rate1*(t2[0]-t1[-delta1])

	rate2 = (b1 - b2)/$
	       (mean(t2[0:delta2-1],/nan)- mean(t2[delta2:2d0*delta2],/nan))
	valueb = (b1+b2)/2d0 + rate2*(t2[0]-t2[delta2])

	c = b*valuea/valueb
	if (~finite(valuea) ) then stop
	if (~finite(valueb) ) then stop
return
end

