pro pds_lc,photst,name,c1=c1,plt=plt
if ~keyword_set(c1) then c1 = 1d0
lc = photst[*,0]
times = photst[*,1]
lc2=conditionlc(lc,times,times2)
interval = times2[2]-times2[1]
interval=interval*24.*60*60.
ps=powerspectrum(lc2,interval,freq)
pos = where(freq gt 0)
freq = freq[pos]
ps = ps[pos]
ps = ps/c1
plt=plot(freq,ps,/ylog,/xlog,font_size=14,xtitle='Frequency  [Hz]',ytitle='Power Density [rms!U2!N Hz!U-1!N]',title=name,symbol='plus',linestyle='',sym_size=0.50) 
i1 = where(freq gt 3e-6)
i1 = i1[0]
f1 = freq[i1]
gamma=-2.7
c1 = 1d0
plt=plot(/overplot,freq,(mean(ps[i1-100:i1+250])-c1)*(freq/f1)^gamma + c1,color=!color.orange,thick=2)
return
end

