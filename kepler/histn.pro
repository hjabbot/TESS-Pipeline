function histn,gotablearr,quarts
nn = 12
quarts = 6 + indgen(nn)
inds = (quarts - 6)/4 + 1
nqs = intarr(nn)
for i = 0,nn-1 do begin
   q = quarts[i]
   indi = inds[i]
   wh = where(gotablearr[indi].quarter eq q,nq)
   nqs[i] = nq
endfor
plt=barplot(quarts,nqs,ytitle='Number of Galaxies',font_size=16, margin=[0.15,0.15,0.15,.2], xtitle='Kepler Quarter')
ax = plt.axes
ax[2].hide = 1

xaxis = AXIS('X', coord_transform = [2009.10,.25], LOCATION='top',minor=0, tickfont_size=14)
return,nqs
end
   
