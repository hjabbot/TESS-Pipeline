;  Looking just at x components of centroids here
; Clean out NANS
 indx = indgen(nstars)
for i = 0, n_elements(doffi)-1 do $
 	indx[where(finite(xc_arr[*,doffi[i]]) ne 1)] = -1
 for i = 0, n_elements(doffi)-2 do $
	 indx[where(abs(xc_arr[*,doffi[i]]-xc_arr[*,doffi[i+1]]) gt 3)] = -1
indx = indx[where(indx ne -1)]

; Selecting stars near edges of pixels (best)
 best=indx[where((xc_arr[indx,doffi[0]]-fix(xc_arr[indx,doffi[0]])) lt 0.2)]
 best=[best,indx[where((xc_arr[indx,doffi[0]]-fix(xc_arr[indx,doffi[0]])) gt 0.8)]]
 ; Selecting bright stars
 best2 = indx[where(mags[indx] lt 14.0 and mags[indx] gt 13.5)]

 ; Selecting galaxies near edges
 gbest = gindex[where((xc_arr[gindex,doffi[0]]-fix(xc_arr[gindex,doffi[0]])) lt 0.2)]
 gbest=[gbest,gindex[where((xc_arr[gindex,doffi[0]]-fix(xc_arr[gindex,doffi[0]])) gt 0.8)]]
  
; Get averages for each FFI
 avgx = dblarr(3)
 avgx[0]=mean(xc_arr[best2,doffi[0]],/double,/nan)
 avgx[1]=mean(xc_arr[best2,doffi[1]],/double,/nan)
 avgx[2]=mean(xc_arr[best2,doffi[2]],/double,/nan)

 ; Days are MJD of each observation
 days = mjd_arr[doffi] - mjd_arr[doffi[0]]
 xx0=xc_arr[indx,doffi[0]]-avgx[0]                  
 xx1=xc_arr[indx,doffi[1]]-avgx[1]                  
 xx2=xc_arr[indx,doffi[2]]-avgx[2]                  
 xx01 = xx1 - xx0
 xx02 = xx2 - xx0
 xxerr = xx01 - day[1]/day[2]*xx02
 goto, plotpm
 if (!d.name eq 'X') then wset,0
 ;plot,mags[indx],xxerr*3.98d3,psym=3,yrange=[-.01,.01]*3.98d3,xrange=[9,17],charsize=1.5,xtitle='Magnitude',$
;	ytitle='X2011 - (X2010 + X2012)/2 [Pixels]',title='Kepler position errors' 
; oplot,mags[gindex],xxerr[gindex]*3.98d3,psym=1,symsize=2,thick=2

; Plot of difference between 3rd position and prediction from first two positions, as a funcition of magnitude
 plot,mags[indx],xxerr*3.98d3,psym=3,yrange=[-.005,.005]*3.98d3,xrange=[9,17],$
	 charsize=1.5,xtitle='Magnitude',$
	ytitle='X2011 - X2010 - days1/days2(X2012 - X2010) [mas]',title='Kepler position errors' 
;wait,3
; Same plot but absolute magnitude of position error
 plot,mags[indx],abs(xxerr*3.98d3),psym=3,yrange=[0,.005]*3.98d3,xrange=[9,17],$
	 charsize=1.5,xtitle='Magnitude',$
	ytitle='X2011 - X2010 - days1/days2(X2012 - X2010) [mas]',title='|Kepler position errors|' 
var_mas = dblarr(11)
vindx = where(abs(xxerr) lt 40./4e3)
vxxerr = xxerr[vindx]
 for i = 8, 18 do $
	 var_mas[i-8] = meanabsdev(vxxerr[where(mags[indx[vindx]] ge i and mags[indx[vindx]] lt (i+1))],/double,/nan)
 print,var_mas*3.98e3
 oplot,indgen(11)+8,var_mas*3.98e3,thick=2,psym=10
; if (!d.name eq 'X') then wset,1
; plot,mags[indx[best]],xxerr[best]*3.98e3,psym=3,yrange=[-.005 ,.005]*3.98e3,$
;	 xrange=[9,17],charsize=1.5,xtitle='Magnitude',$
;	ytitle='X2011 - X2010 - days1/days2(X2012 - X2012) [mas]',title='Kepler position errors, 0.2 from edge'   
;;wait,3
; plot,mags[indx[best]],abs(xxerr[best])*3.98e3,psym=3,yrange=[-.00 ,.005]*3.98e3,$
;	 xrange=[9,17],charsize=1.5,xtitle='Magnitude',$
;	ytitle='X2011 - X2010 - days1/days2(X2012 - X2012) [mas]',title='Kepler position errors, 0.2 from edge'   
vindx = best[where(abs(xxerr[best]) lt 40./4e3)]
vxxerr = xxerr[vindx]
 for i = 8, 18 do $
	 var_mas[i-8] = meanabsdev(vxxerr[where(mags[indx[vindx]] ge i and mags[indx[vindx]] lt (i+1))],/double,/nan)
; oplot,indgen(11)+8,var_mas*3.98e3,thick=2,psym=10
 print,var_mas*3.98e3
 ;oplot,mags[gbest],abs(xxerr[gbest]*3.98d3),psym=1,symsize=2,thick=2
 if (!d.name eq 'X') then wset,2
 plotpm:
if (overplot) then goto,overplot
 plot,mags[indx],xx02*3.98d3,psym=1,yrange=[-200,200],xrange=[9,11],$
	 charsize=1.5,xtitle='Magnitude',ystyle=1,$
	ytitle='X2012 - X2010 [mas]',title='Proper Motions' 
 oploterr,mags[indx],xx02*3.98d3,abs(xxerr)*3.98e3*2,1
 goto,skipoplot
 overplot:
 oplot,mags[indx],xx02*3.98d3,psym=1,color=2
 oploterr,mags[indx],xx02*3.98d3,abs(xxerr)*3.98e3*2,1
 !p.color=255
 skipoplot:
 print,i
 end
