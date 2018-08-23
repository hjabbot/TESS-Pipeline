pro histquarters, gotablearr
kids = []
for i=0,3 do kids = [kids,gotablearr[i].kepler_id]
kids = kids[uniq(kids,sort(kids))]
nkids = n_elements(kids)
nqs = intarr(nkids)
for i = 0, nkids -1 do nqs[i] = n_elements(quartersof(gotablearr,kids[i]))
plt = plot(indgen(12)+1,histogram(nqs,binsize=1), /histogram,xtitle='Number of Kepler Quarters of Monitoring',ytitle='Number of Galaxies', font_size=16,/stairstep,thick=3,fill_background=1)
return
end
