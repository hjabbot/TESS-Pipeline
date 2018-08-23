function convert_phothash,xmlhash
quarters=xmlhash['phot','quarter']
q_hash = hash(fix(quarters[0,'id']))
IF ISA(quarters,'HASH') THEN quarters = LIST(quarters)
foreach q,quarters do begin
	groups = q['group']
	qid = fix(q['id'])	
	IF ISA(groups,'HASH') THEN groups = list(groups)
	g_hash = 0
	foreach g,groups do begin
	  if (total(strmatch((g.keys()).toarray(),'target')) eq 0) then continue 
		targets = g['target']
    gid = fix(g['id'])
		IF ISA(targets,'HASH') THEN targets = list(targets)
		t_hash = 0
		foreach  t,targets do begin
			tid = long(t['id'])
			aps = t['ap']
			IF ISA(aps,'HASH') THEN aps = list(aps)
			ap_hash = 0
			foreach ap, aps do begin
				bkgnd = long(strsplit(ap['bkgnd','_text'],' ',/extract))
				phot  = long(strsplit(ap['phot' ,'_text'],' ',/extract))
				stop
				apsize = fix(ap['id'])
				IF ~ISA(ap_hash,'HASH') THEN $
				  ap_hash = HASH(apsize,hash('bkgnd',bkgnd,'apphot',phot)) $
				ELSE $
				  ap_hash += hash(apsize,hash('bkgnd',bkgnd,'apphot',phot))
			endforeach
			IF ~ISA(t_hash,'HASH') THEN $
			  t_hash = HASH(tid,ap_hash) $
			ELSE $
			  t_hash += hash(tid,ap_hash)
		endforeach
		IF ~ISA(g_hash,'HASH') THEN $
		   g_hash = hash(gid,t_hash) $
		else $
		   g_hash += hash(gid,t_hash)
	endforeach
	IF ~ISA(q_hash,'HASH') THEN $
	  q_hash = HASH(gid,g_hash) $
	ELSE $
	  q_hash += hash(qid,g_hash)
endforeach
return,q_hash
end
