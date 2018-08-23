PRO run_photbykic,outfile,kicarr,adjust,noplot,agnflag=agnflag,istart=istart,result=result
; outfile - name of file to store results for each object
; kicarr -  array of kic numbers identifying the objects of interest
; adjust - 0 for no adjustment, 1 for using means for each season, 
;          2 for normalizing by first year.
; noplot - prevents plotting of results
; agnflag  - ??
; istart -   allows one to continue on from an interruption and append to previous outfile.
if ~keyword_set(istart) then istart=0
if ~keyword_set(agnflag) then agnflag=0
if istart eq 0 then begin
	openw,/get_lun,wunit,outfile 
	openw,/get_lun,wun2,outfile+'_full' 
endif else begin
	openw,/get_lun,/append,wunit,outfile
	openw,/get_lun,/append,wun2,outfile+'_full'
endelse
;printf,wunit,format='(a5,4a9,40i9)','KIC', 'KEPMAG','goldens', 'Median(an)','Max(an)',indgen(40)
printf,wunit,format='(a6,4a9)','KIC', 'KEPMAG', 'goldens', 'Median','Max'
for i=istart,n_elements(kicarr)-1 do begin
	result = photbykic(kicarr[i],adjust=adjust,noplot=noplot,wunit=wunit,agnflag=agnflag,wun2=wun2)
	if ((i mod 100) eq 0) then begin
		print,i
		free_lun,wunit
		free_lun,wun2
		openw,/append,wunit,outfile
		openw,/append,wun2,outfile+'_full'
	endif
endfor
free_lun,wunit
free_lun,wun2
return
end
