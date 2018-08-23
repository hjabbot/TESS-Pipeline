function skygroupof,gotablearr,kid
grp = -1L
for i = 0,n_elements(gotablearr)-1 do $
     grp = [grp,gotablearr[i].skygroup_id[where(gotablearr[i].kepler_id eq kid,/null)]]
IF (n_elements(grp) ge 2) then grp=grp[1]
return,grp
end
