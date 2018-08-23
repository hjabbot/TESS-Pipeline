pro runallforone,n1,n2,kid,gotablearr,phothash,skips=skips

if n_params() eq 0 then begin
	print,'Usage: runallforone,n1,n2,kid,gotablearr,phothash'
	return
endif
if ~keyword_set(skips) then skips = intarr(19)


for n=n1,n2 do begin
	agncandidates,n,kid,quarters,vlim,nanq,apsize,bestq
	allforone,kid,apsize,gotablearr,phothash,quarters=quarters,write=write,$
	skip=skips[n],/fast,/stitch,/llc,vlim=vlim,/ps,/norm,nanq=nanq,bestq=bestq
	skips[n] = 1

	s=''
	;while s ne 'y' do begin
	;read,'Continue? :',s
	;endwhile
	stop
endfor

end
