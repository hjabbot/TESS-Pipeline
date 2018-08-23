PRO ffi_calquads,ffis,startchannel=startchannel,endchannel=endchannel,$
              set=set,phot=phot,noread=noread,selfcal=selfcal,nocal=nocal
n_ffis=41
count0 = 1d8
mag0 = 11.8d0-6.4d0

; Read zeropts
ii=0
cch=0
zeroPts = dblarr(n_ffis,nch+1)
openr,13,"zeroPts.txt"
row=dblarr(nch+1)
dummy= ''
for i = 0, n_ffis-1 do begin
	readf,13,ii,dummy
	reads,dummy,row
	zeroPts[i,*] = row
endfor

for area = startarea, endarea do begin
	for i=0,nffis-1 do begin
		ffi = ffis[i]
		; Read photometry data
		chan =  channelInArea[quarter[ffi],area]
		read_photfile,ffi,chan,struct,nstars
		; Remove those with NaN in positions
		struct=struct[where(finite(struct.xc))]
		
		if (ffi le 28) then struct.phot = struct.phot/1625d0
		struct.phot = -2.5*alog10(struct.phot/count0)+mag0
		
		; Sort, brightest first
		srtbright = sort(struct.kepmag)
		struct=struct[srtbright]
		
		; If stars within N pixels, keep only the brightest
		index=matchpos(struct.xc,struct.yc,5.) 
		wh=brightmatch(index,struct.kepmag)
		struct=struct[wh]
		
		; Matchup by kepid
		if (i eq 0) then begin
			nstars1 = n_elements(wh)
			print,'Nstars1 = ',nstars1
			matchlist = lonarr(nffis,nstars1)
			kepid = struct.kepid
		endif else begin
		   	for star = 0,nstars1-1 do begin
				matchlist[i,star]=where(struct.kepid eq kepid[star])
			endfor
		endelse
		set.Add,struct,/no_copy
	endfor; next ffi





