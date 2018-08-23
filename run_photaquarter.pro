pro run_photaquarter,quarters,skyGroups,apsize,phothash=phothash,ps=ps,pdf=pdf,gotablearr=gotablearr,kid0=kid0

; This reads in targs for a range of quarters and skygroups

mastxmlfiles = ['/home/eshaya/Documents/Kepler/MAST_GO20058.xml', $
                 '/home/eshaya/Documents/Kepler/MAST_GO30032.xml', $
                 '/home/eshaya/Documents/Kepler/MAST_GO40057.xml' ]

close = 0
for i = quarters[0],quarters[1] do begin
	if (i ge 6 and i le 9) then year = 0 
	if (i ge 10 and i le 13) then year = 1 
	if (i ge 14 and i le 17) then year = 2 
	;; Read GO table for 1 proposal year
        if ~keyword_set(gotablearr) then begin
		table0 = read_votable8(mastxmlfiles[0])
	        table1 = read_votable8(mastxmlfiles[1])
		table2 = read_votable8(mastxmlfiles[2]) 
	        gotablearr = list(table0,table1,table2)
	endif
	if ~keyword_set(gotablearr[year]) then $
		gotablearr[year] = read_votable8(mastxmlfiles[year])
	if ((where(gotablearr[year].quarter EQ i))[0] eQ -1) then $
		gotablearr[year] = read_votable8(mastxmlfiles[year])
	for j = skyGroups[0],skyGroups[1] do begin
		print,' Skygroup: ', j
		if (j eq skyGroups[1]) then close = 1
		apphot = photaquarter(gotablearr[year],i,j,apsize,phothash=phothash,ps=ps,pdf=pdf,$
			close=close,kid0=kid0)
	endfor
squarter = strtrim(string(i),1)
sap = strtrim(string(apsize),1)
if (pdf eq 1) then begin
	graphic=plot([1,1],[1,1],linestyle='none',axis_style=0)
	graphic.save,'graphs/q'+squarter+'a'+sap+'.pdf',/append,/close
endif
endfor
return
end
