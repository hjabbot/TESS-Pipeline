pro plot_k2browse,pdc_stats,k2data

IF N_PARAMS() LT 2 THEN BEGIN
	PRINT,'PLOT_K2BROWSE,pdc_stats,k2data'
	RETURN
ENDIF
symbols = ['+','*','dot','D','Triangle','s','X','>','<','td','tl','tr',$
	'Tu','Td','Tl','Tr','d','p','h','H','|','_','S','o']
win2 = getwindows('SDEV')
if isa(win2) then win2.setcurrent
if ~isa(win2) then win2=window(window_title='SDEV') else win2.erase
FOR module = 1, 24 do begin
	wh = where(k2data.module eq module,nmod)
	if (nmod gt 0) then $
	p2 = scatterplot(/current,/overplot,k2data[wh].kep_mag,$
		pdc_stats[wh].sdev,/ylog,symbol=symbols[module-1],sym_size=1.3)
ENDFOR
high = where(pdc_stats.sdev gt .025,nhigh)
name = string(format='(I4)',high)
print,' N high' , nhigh
text = text(k2data[high].kep_mag,pdc_stats[high].sdev,name,$
	/data,font_size=8)

win3 = getwindows('SMDEV')
if isa(win3) then win3.setcurrent
if ~isa(win3) then win3=window(window_title='SMDEV') else win3.erase
FOR module = 1, 24 do begin
	wh = where(k2data.module eq module,nmod)
	if (nmod gt 0) then $
	  p3 = scatterplot(/current,/overplot,k2data[wh].kep_mag,$
	  	pdc_stats[wh].smdev,/ylog,symbol=symbols[module-1],sym_size=1.3)
endfor
high = where(pdc_stats.smdev gt 25.,nhigh)
name = string(format='(I4)',high)
print,' N high' , nhigh
text = text(k2data[high].kep_mag,pdc_stats[high].smdev,name,$
	/data,font_size=8)

win2.setcurrent
return
end
