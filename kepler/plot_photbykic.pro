pro plot_photbykic,kw

wh = where(kw.agn eq 1,complement=whnot)
; FFImag vs Medians
plot,kw[whnot].ffimag,kw[whnot].med,psym=3,/ylog,xrange=[10,18],charsize=1.5,$
	xtitle='5x5 Kepler Pixel Aperture [Mag]',ytitle='Median(Abs Yearly Differences) [Mag]'
oplot,kw[wh].ffimag,kw[wh].med,psym=4,thick=2 
dum=''
; FFImag vs gold
read,'Continue? ',dum
plot,kw[whnot].ffimag,kw[whnot].gold,psym=3,/ylog,xrange=[10,18],charsize=1.5,$
	xtitle='5x5 Kepler Pixel Aperture [Mag]',ytitle='FFI 0-8 (Abs Differences) [Mag]'
oplot,kw[wh].ffimag,kw[wh].gold,psym=4,thick=2 
read,'Continue? ',dum
; FFImag vs Median/Gold
plot,kw[whnot].ffimag,kw[whnot].med/kw[whnot].gold,psym=3,/ylog,xrange=[10,18],charsize=1.5,$
	xtitle='5x5 Kepler Pixel Aperture [Mag]',ytitle='Median Yearly/FFI 0-8'
oplot,kw[wh].ffimag,kw[wh].med/kw[wh].gold,psym=4,thick=2 
read,'Continue? ',dum
; FFImag vs Max
;plot,kw[whnot].ffimag,kw[whnot].max,psym=3,/ylog,xrange=[10,18],charsize=1.5,$
;	xtitle='5x5 Kepler Pixel Aperture [Mag]',ytitle='Max Abs Yearly Difference [Mag]'
;oplot,kw[wh].ffimag,kw[wh].max,psym=4,thick=2 
return
end
