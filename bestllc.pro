pro bestllc,gotablearr,day1,day2,best=best,sfpdc1=sfpdc1,sfpdc2=sfpdc2,pstr=pstr,kid=kid

   
   sday2 = strtrim(string(day2),2)
   ; Read llcdev.txt (output on llcdev std deviations)
   pstr2=read_llcdev()
   ; Take those observed in 3 or more quarters
   pstr=pstr2[where(total(finite(pstr2.std),1) ge 3)]
    stars = [5893799, 10132973, 4036050 ]
    badtargs = [stars, 11231834,11231852, 11284067]
    for i = 0, n_elements(badtargs)-1 do pstr = rmelement(pstr,where(pstr.kid eq badtargs[i]))

   ; Take only if rate less than 1e4 e/s (others are stars)
   pstr=pstr[where(pstr.cps lt 1e4)]
   pstr[where(pstr.kid eq 11068393)].std[5] = !VALUES.D_NAN
   pstr[where(pstr.kid eq 8345656)].std[5] = !VALUES.D_NAN
   
   if keyword_set(kid) then pstr = pstr[where(pstr.kid eq kid)]
   nn = n_elements(pstr)
   print,'Number with 3 quarters =',nn
   best = dblarr(nn)
   whbest = lonarr(nn)
   
   day = 48
   for i=0, nn-1 do begin
   	best[i]=min(pstr[i].std[0:10],whb,/nan)           
   	if (pstr[i].std[whb] lt 0.5d0) then begin
   		pstr[i].std[whb] = !values.d_nan
   		best[i]=min(pstr[i].std[0:10],whb,/nan)           
   	endif
   	whbest[i] = whb + 6
   endfor
   if (~isa(sfpdc1) || size(sfpdc1,/dim) ne nn) then sfpdc1=dblarr(nn)
   if (~isa(sfpdc2) || size(sfpdc2,/dim) ne nn) then sfpdc2=dblarr(nn)
   for i=0,nn-1 do begin
        llcl = read_llc(pstr[i].kid,[1,1]*whbest[i],llctime,/kepler)
        llcl=llcl[0] & llctime=llctime[0]
        ; smooth and remove extremes
        smllcl = smooth(llcl,day*5,/nan)
        dif = llcl - smllcl
        std = stddev(dif,/nan)
        llcl[where(dif gt 3.*std)] = !values.d_nan
        ; instant needs to be multiple of cadence 0.020434 days
	smth = 4
        llclsm = smooth(llcl,smth,/nan)
	llcl0 = llclsm[smth/2:-smth/2:smth]
	llc0time = llctime[smth/2:-smth/2:smth]
	avg = mean(llcl,/nan)
        sfpdc1[i]=double(smth+1)*sf(llc0time,llcl0/avg,tau=tau1,nnt=nnt,$
	       fast=0,instant=day1*.998736)
	smth = 4
        llclsm = smooth(llcl,smth,/nan)
	llcl0 = llclsm[smth/2:-smth/2:smth]
	llc0time = llctime[smth/2:-smth/2:smth]
        sfpdc2[i]=double(smth+1)*sf(llc0time,llcl0/avg,tau=tau2,nnt=nnt,$
	       fast=0,instant=day2*.998736)
        if (i mod 10 eq 0) then print,i,format='(i3,$)'
   endfor
   ratio:
   ratio = sfpdc2/sfpdc1
   for i=0,1 do begin
   	stdev = stddev(ratio,/nan) & mean1 = mean(ratio,/nan)
   	ratio[where(abs(mean1 - ratio) gt 3d0*stdev)] = !values.d_nan
	print,stdev
   endfor
   stdev = stddev(ratio,/nan) & mean1 = mean(ratio,/nan)
   nsigma = 2.5d0
   print,''
   print,'Mean ratio: ',mean1
   print,'stdev: ',stdev
   print,'nsigma: ',nsigma
   print,'Mean ratio + nsigma * stdev: ',mean1+nsigma*stdev
   
   
   dd1=where(sfpdc2/sfpdc1 ge mean1+stdev*nsigma) 
   dd1 =dd1[reverse(sort(sfpdc2[dd1]/sfpdc1[dd1]))]
   nd1 = n_elements(dd1)
   ind1 = indgen(nd1)+1
   sday2 = strtrim(string(day2,format="(f4.1)"),2)
   shr1 = strtrim(string(day1*24,format="(f3.1)"),2)
   
   ; Plot Count Rate vs Std. Deviation
   p1=plot(pstr.cps,best,symbol='+',linestyle='none',/xlog,/ylog,font_size=14,font_name="Times",$
   	xrange=[1e2,1e4],yrange=[1e-1,1e2],xtitle='Count Rate [$e^-/s$]',$
	margin=[.15,.10,.05,.10], ytitle='Standard Deviation [$e^-/s$]',$
	title='Variation in "best" quarter')                                       
   for i=0,nd1-1 do text=text(pstr[dd1[i]].cps,1.1*best[dd1[i]],string(ind1[i],format='(i2)'),/data,$
	   font_size=14,font_name="Times",alignment=.5,color='red')
;   p1.save,'../graphs/counts_stdev2.eps',resolution=200
   
   ; Plot SF(day1) vs SF(day2)
   p2=plot(sfpdc1,sfpdc2/sfpdc1,/xlog,/ylog,symbol='plus',linestyle='none',$
   xtitle='SF('+shr1+' hr)',ytitle='SF('+sday2+' days)/SF('+shr1+' hr)',$
   xrange=[1e-7,1e-4],font_size=14,font_name="Times")
   p2=plot(/overplot,/current,[1e-8,1e-2],[mean1,mean1])
   for i=0,nd1-1 do text4=text(sfpdc1[dd1[i]],1.10*sfpdc2[dd1[i]]/sfpdc1[dd1[i]],string(ind1[i],format='(i2)'),$
	   font_size=14,font_name="Times",alignment=0.5,/data)
   p2.save,'../graphs/sf_'+shr1+'_'+sday2+'.eps',resolution=200
;   
;   ; Plot close up of SF(day1) vs SF(day2)
   p3=plot(sfpdc1,sfpdc2/sfpdc1,/xlog,symbol='plus',linestyle='none',$
	   xtitle='SF('+shr1+' hr)',ytitle='SF('+sday2+' days)/SF('+shr1+' hr)',$
	   yrange=[0.5,2.0],xrange=[1e-7,1e-4],font_size=14,font_name="Times")
   p3=plot(/overplot,/current,[1e-8,1e-2],[mean1,mean1],thick=2)
   text2=text(sfpdc1[dd1],sfpdc2[dd1]/sfpdc1[dd1]+0.04,string(ind1,format='(i2)'),$
	   font_size=14,font_name="Times",alignment=0.5,/data)
 p3=plot(/overplot,[1e-7,1e-4],[mean1-nsigma*stdev, mean1-nsigma*stdev],linestyle='--')
 p3=plot(/overplot,[1e-7,1e-4],[mean1+nsigma*stdev, mean1+nsigma*stdev],linestyle='--')

   ;p3.save,'../graphs/sf_'+shr1+'_'+sday2+'_zoom.eps',resolution=200
   print,''
   kids=pstr[dd1].kid
   ccds=intarr(nd1)
   sg=intarr(nd1)
   for i=0,nd1-1 do begin
   	qs = quartersof(gotablearr,kids[i],ccd=ccd)
   	sg[i] = skygroupof(gotablearr,kids[i])
   	ccds[i] = ccds[where(qs eq whbest[i])]
   endfor
   print,'     ind      KIC       SG       ratio           Best Q      CCD'
   forprint,ind1,pstr[dd1].kid,sg, sfpdc2[dd1]/sfpdc1[dd1],whbest[dd1],sfpdc1[dd1],sfpdc2[dd1]

   i = where(pstr.kid eq 10062936)
   print,pstr[i].kid,sg, sfpdc2[i]/sfpdc1[i],whbest[i],sfpdc1[i],sfpdc2[i]
   i = where(pstr.kid eq 5438603)
   print,pstr[i].kid,sg, sfpdc2[i]/sfpdc1[i],whbest[i],sfpdc1[i],sfpdc2[i]
return
end

