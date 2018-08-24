pro read_targ,gotablearr,quarters,skygroups,apsize,phothash=phothash,ps=ps,pdf=pdf,slope=slope,$
	kid=kid,noplot=noplot,something=something,vlim=vlim,tv=tv,findsharp=findsharp,$
	fittime=fittime

if keyword_set(phothash) then print,phothash
if ~keyword_set(something) then something = 0
if ~keyword_set(tv) then tv = 0
if ~keyword_set(vlim) then vlim = 0

close = 0
if (size(gotablearr,/type) EQ 0) THEN BEGIN
	print,'no gotablearr'
	stop
  if !version.os ne "Win32" then $
    dir = "/home/eshaya/Documents/Dropbox/Kepler Mission/" $
  else $
    dir = "C:\Users\eshaya\Dropbox/Kepler Mission/"
   stop
	mastxmlfiles = ['/home/eshaya/Documents/Kepler/MAST_GO20058.xml', $
                 '/home/eshaya/Documents/Kepler/MAST_GO30032.xml', $
                 '/home/eshaya/Documents/Kepler/MAST_GO40057.xml' ]
	;; Read GO table for 1 proposal year
	table0 = read_votable8(mastxmlfiles[0])
	table1 = read_votable8(mastxmlfiles[1])
	table2 = read_votable8(mastxmlfiles[2]) 
	gotablearr = list(table0,table0,table1,table2)
endif

print,'read_targ: Starting quarters ',quarters[0],' to ',quarters[1]
for q = quarters[0],quarters[1] do begin
	if (q ge 2 and q le 5) then year = 0 
	if (q ge 6 and q le 9) then year = 1 
	if (q ge 10 and q le 13) then year = 2 
	if (q ge 14 and q le 17) then year = 3 

	sg1=strtrim(string(skygroups[0]),2)
	sg2=strtrim(string(skygroups[1]),2)
	sq1=strtrim(string(quarters[0]),2)
	sq2=strtrim(string(quarters[1]),2)
	sap=strtrim(string(apsize),2)

	dir = string('../Q',q,format='(a4,I02)')
	cd, dir
        for g = skygroups[0],skygroups[1] do begin
		;print,'read_targ: Skygroup: ', g
		;print,'read_targ: Quarter = ',q
		if (g eq skygroups[1]) then close = 1
        	apphot = photaquarter(gotablearr[year],q,g,apsize,findsharp=findsharp,slope=slope,$
			phothash=phothash,pdf=pdf,ps=ps,tv=tv,vlim=vlim,$
			kid=kid,noplot=noplot,fittime=fittime)
		if (n_elements(apphot) gt 1) then something = 1

	endfor
	if (pdf eq 1) then begin
		squarter = strtrim(string(i),1)
		sap = strtrim(string(apsize),1)
		graphic=plot(/overplot,[1,1],[1,1],linestyle='none',axis_style=0)
		if file_search('graph') eq !null then file_mkdir,'graph' 
		graphic.save,'graphs/q'+squarter+'a'+sap+'.pdf',/append,/close
	endif

endfor

;if keyword_set(phothash) then begin
;   openw,/get_lun,unit,'../phothash_q'+sq1+'q'+sq2+'g'+sg1+'g'+sg2+'a'+sap+'.xml'
;   phothash_write,phothash,unit=unit
;   free_lun,unit
;endif

return
end
