function sharpfunc, x
	common scom,phot,asym,flatness,mid,cut,meanphot
	if (abs(x[1]) gt cut) then x[1] = cut*signum(x[1])
	phot0 = phot*(1e0+flatness*x[1])*(1e0+asym*x[0]) 
	phot0 = phot0*meanphot/mean(phot0,/nan)
	smphot = smooth(phot0,48,/nan,/edge_mirror)
	smphot = smphot(0:-1:48)

	; Goodness is standard dev 
;	sf2 = meanabsdev(smphot,/nan)

	; Goodness is SF at 20 days
	sm2 = (smphot - shift(smphot,-20))^2
	sf2 = total(sm2[0:-21],/nan)
;	sf2 = total(sm2,/nan)

return, sf2
end


