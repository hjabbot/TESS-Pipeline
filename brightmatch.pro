FUNCTION brightmatch,index,mag
; Select brightest objects of merged objects
; from index of mergers
; index contains the same integer value if two objects are merged
; We return where in index one gets unique stars
select=[]
for i=0, max(index) do begin
	wh=where(index eq i,count)
	if (count eq 1) then $
		whmin=0 $
	else $
		min=min(mag[wh],whmin)
	select=[select,wh[whmin]]
endfor
return,select
end
