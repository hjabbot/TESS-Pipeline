function quartersof,gotablearr,kid,ccd=ccd
qs = []
ccd = []
for i = 0,n_elements(gotablearr)-1 do begin
     qs = [qs,gotablearr[i].quarter[where(gotablearr[i].kepler_id eq kid,/null)]]
     ccd = [ccd,gotablearr[i].channel[where(gotablearr[i].kepler_id eq kid,/null)]]
endfor
return,qs
end
