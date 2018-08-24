pro plot_color_ratio,c1,c2 ,kicwisecat,photout
;kicwisecat='KIC_WISE_Extra_Galactic_Sources.dat' 
kicwise=read_kicwisecat(kicwisecat)
;photout='photbykic.out'
kw = read_photbykic(photout,1)
nkw = n_elements(kw)
color = fltarr(nkw)
whkic = lonarr(nkw)
for i=0,nkw-1 do whkic[i] = where(kicwise.kic eq kw[i].kic)
Result = Execute('for i=0,nkw-1 do color[i]=kicwise[whkic[i]].'+c1+'mag - kicwise[whkic[i]].'+c2+'mag')
wh = where(kw.agn eq 1,complement=whnot)
plot,color[whnot],alog10(kw[whnot].med/kw[whnot].gold),psym=3,xtitle='J-W2 [mag]',$
	ytitle='Log(Median(Variation!D1yr!N)/Variation!DGold!N)',charsize=1.5,xrange=[1,6]
oplot,color[wh],alog10(kw[wh].med/kw[wh].gold),psym=4
oplot,[1,7],[0,0] 
return
end
