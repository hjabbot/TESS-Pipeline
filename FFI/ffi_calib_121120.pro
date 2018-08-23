
<!-- saved from url=(0094)https://dl-web.dropbox.com/get/Kepler%20Mission/Keplerpros/ffi_calib.pro?w=34cd4f6b&sjid=35009 -->
<html><head><meta http-equiv="Content-Type" content="text/html; charset=US-ASCII"></head><body><pre style="word-wrap: break-word; white-space: pre-wrap;">PRO ffi_calib,ffis,startchannel=startchannel,endchannel=endchannel,$
         set=set,phot=phot,noread=noread,selfcal=selfcal,nocal=nocal,save=save

nch=84
if ~keyword_set(startchannel) then startchannel=1
if ~keyword_set(endchannel) then endchannel=nch
if ~keyword_set(noread) then noread=0
if ~keyword_set(selfcal) then selfcal = 0
if ~keyword_set(nocal) then nocal = 0
if ~keyword_set(save) then save = 0
n_ffis = 41
wset,0
nffis = n_elements(ffis)
nstars=0
count0 = 1d8
mag0 = 11.8d0-6.4d0
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
close,13

;zeroPts[14:*,5:8] = -.09d0
;zeroPts[26,41]=-.09d0

for i = 0,nffis-1 $
	do nozpt = where(zeroPts[ffis[i],startchannel:endchannel] eq -0.9,nnozpt)
if (nnozpt ne 0) then begin
	print,' Bad channel in ffi ',ffis[nozpt]
	cc = indgen(nffis)+startchannel
	print,' channel ',cc[nozpt]
	return
endif


for chan=startchannel,endchannel do begin
  if (noread eq 1) then goto,skipread
	set=list()
	matcharr = []
	for i=0,nffis-1 do begin
		ffi = ffis[i]
		; Read photometry data
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

	; Go through entire matchlist.  If in any ffi there is no match to
	; a particular kepid, then we will remove that kepid 
	whmatch = [0]
	; star steps through each star in the kepid of the first nffi
	for star=0,nstars1-1 do begin
		; whnone is -1 if all ffis match to this kepid
		whnone = where(matchlist[*,star] eq -1,none)
		; We add to whmatch, if all ffis have matches
		if (none eq 0) then whmatch = [whmatch,star]
	endfor
	whmatch = whmatch[1:*]
	; keep only kepid's with matches in all ffis
	kepid = kepid[whmatch]
	nstars1 = n_elements(kepid)
	struct=set[0]
	struct=struct[whmatch]
	set[0] = struct
	
	; Keep matches only for remaining kepids
	matchlist = matchlist[*,whmatch]
	for i=1,nffis-1 do begin
		struct=set[i]
		struct=struct[matchlist[i,*]]
		set[i] = struct
	endfor

skipread:
struct=set[0]
nstars1=n_elements(struct)
phot = dblarr(nffis,nstars1)
for i=0,nffis-1 do begin
      struct=set[i]
      phot[i,*]=struct.phot+zeroPts[ffis[i],chan]
endfor
; PLOT mmag deviation vs mag
kepmag=struct.kepmag
varian = DBLARR(nstars1)
shifts=dblarr(nffis)
if (selfcal eq 1) then kepmaglo = 11 else kepmaglo=12
wh = where(kepmag gt kepmaglo,nstars2)
varian2=dblarr(nstars2)
nstands = [3000,2000,600,400,300,300,300,300,300,300,300,300,300]
if (selfcal eq 1) then nstands = nstands/3
nstands = [nstands,replicate(50,10)]
checkvariance:
for nn = 0,n_elements(nstands)-1 do begin
  nstand = nstands[nn]


  FOR star = 0, nstars2-1 DO $
      varian2[star] = VARIANCE(phot[*,wh[star]],/nan,/double)

      for star=0, nstars1-1 DO $
        varian[star] = VARIANCE(phot[*,star],/nan,/double)

      PLOT,phot[0,*],SQRT(varian)*1e3&gt;.02,psym=3,/ylog,xtitle='Kepler Magnitude',$
        ytitle='Log RMS Variance [mmag] ',charsize=1.5,yrange=[.01,1e3],$
        symsize=0.3,xstyle=1,xrange=[9,17]

	if (nocal eq 1) then continue
      ; Improve on standards by using best 1000 stars
      sort_varian = SORT(varian2)

      standards = wh[sort_varian[0:nstand]]

      if (selfcal eq 1) then $
      	for i=0,nffis-1 do shifts[i] = MEAN(phot[0,standards]-phot[i,standards],/double,/nan) $
	else $
      for i=0,nffis-1 do shifts[i] = MEDIAN(kepmag[standards]-phot[i,standards],/double)
      for i=0,nffis-1 do phot[i,*] = phot[i,*]+shifts[i]
      wset,1
      plot,kepmag[standards],phot[0,standards],psym=1,xrange=[10,17],yrange=[10,17]
      oplot,[0,100],[0,100]
      wset,0
      zeroPts[ffis,chan] += shifts
      if (save eq 1) then begin
      	 openw,13,'zeroPts.txt'
      	 for i = 0, n_ffis-1 do begin
         	row=zeroPts[i,*]
	 	printf,13,format='(i3,85d12.8)',i,transpose(row)
      	 endfor
      	 close,13
      endif

  endfor ; end standards check, loop on nstand

endfor ; next channel (chan)
end
</pre></body></html>