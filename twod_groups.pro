FUNCTION twod_groups,x,y,r
i=0
n=n_elements(x)
ny=n_elements(y)
index = lonarr(n) - 1
if (n ne ny) then begin
	print,'nx =',nx,', ny = ',ny
	print,'Stopping'
	return,-1
endif
for s=0,n-1 do begin
	if (index[s] ne -1) then continue
	whx=where(abs(x-x[s]) lt r)
	why = where(abs(y[whx]-y[s]) lt r)
	wh = whx[why]
	index[wh] = i
	i++
endfor
return,index
end
	

	



