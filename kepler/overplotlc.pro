pro overplotlc, phothash,quarters,skygroup,apsize

kids=phothash[10,skygroup].keys()
nkids = n_elements(kids)
; nq is number of quarters to cover
nq = quarters[1]-quarters[0]+1
g=skygroup

first =1

for i = 0, nkids -1 do begin

	kid = kids[i]
	; Make lists of the each data from phothash
	tl = list(phothash(quarters[0],g,kid,apsize,'time'))
	photl = list(phothash(quarters[0],g,kid,apsize,'phot'))
	bkgndl = list(phothash(quarters[0],g,kid,apsize,'bkgnd'))
	for q = quarters[0]+1, quarters[1] do begin
		if (where(phothash[q,g].keys() eq kid) EQ -1) then continue
		tl.add,phothash(q,g,kid,apsize,'time')
		photl.add,phothash(q,g,kid,apsize,'phot')
		bkgndl.add,phothash(q,g,kid,apsize,'bkgnd')
	endfor
	; nq is now number of quarters obtained
	nq = n_elements(photl)

	; Turn list into an array for times and lc
	times=tl[0]
	mn = mean(photl[0],/nan)

	if mn lt 3000 then continue
;	if i ne 14 then continue
	print,i,mn,kid
	smphots = smooth(photl[0],48,/nan,/edge_mirror)-mn
	for q = 1,nq-1 do begin
		times = [times,tl[q]]
		mn = mean(photl[q],/nan)
		smphot = smooth(photl[q],48,/nan,/edge_mirror)-mn
		smphots =  [smphots,smphot]
	endfor

	means = mean(smphots,/nan)
	mm = minmax(smphots/means,/nan)
	if (first eq 1) then $
	plot=	plot(times[0:-1:50],smphots[0:-1:50],yrange=[-100,100],xtitle='Time [Days]',ytitle='Normalized Counts',symbol='dot',linestyle='') $
	else $
	plot = 	plot(times[0:-1:50],smphots[0:-1:50],/overplot,symbol='dot',linestyle=i mod 7)
	first = 0
endfor
return
end
