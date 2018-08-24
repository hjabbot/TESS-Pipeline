pro hist_photbykic,file
skip=1
kw=read_photbykic(file,skip)
wh=where(kw.agn eq 1,complement=whnot)
hist=histogram(alog10(kw[whnot].med/kw[whnot].gold),min=-2.,bin=.25,locations=locs,/nan)
histagn=histogram(alog10(kw[wh].med/kw[wh].gold),min=-2.,bin=.25,locations=locsagn,/nan)
plot,locs,hist/total(hist),psym=10,xtitle='Log(|Diffs(Yearly Pairs)|/|Diffs(Golden FFIs)|)',ytitle='Fraction',charsize=1.5,xrange=[-2,3],thick=2
oplot,locsagn,histagn/total(histagn),psym=10,linestyle=1,thick=2
xyouts,1,.3,'AGN',charsize=1.5
oplot,[1.5,2.5],[.305,.305],linestyle=1,thick=2
xyouts,.6,.34,'nonAGN',charsize=1.5
oplot,[1.5,2.5],[.345,.345],linestyle=0,thick=2
return
end


