 function binlc,photst,box
 time=photst[*,1] & phot=photst[*,0]
  nt = n_elements(time)
; Create regular grid of time
 del=time[1]-time[0]
 tout=time[0]+del*(findgen(nt)+1)

 nans = where(finite(phot,/nan),complement=nonans)
; Interpolate on regular grid with Spline
 yint=spline(time[nonans],phot[nonans],tout,3)
 ; Find touts that are next to nans
 for i = 0, nt -1 do begin
	wh = where(abs(time[nans]-tout[i]) le del)
	if (wh[0] ne -1) then  yint[i] = !VALUES.D_NAN
  endfor

; Rebin with smooth by box
 x=smooth(tout,box,/nan)                                                        
 x=x[0:-1:box]
 y=smooth(yint,box,/nan) 
 y=y[0:-1:box]/mean(phot[0:1600],/nan) 

 p1=plot(x,y,yrange=[.99,1.04],symbol='dot',linestyle='',font_size=14,xtitle='Time [Julian Day - 2,454,833]',ytitle='Counts/Pre-event Counts',title='KSN2011d',xrange=[1030,1090])
 p1=plot(/overplot,[1000,1300],[1.,1.])

return,[[y],[x]]
end
