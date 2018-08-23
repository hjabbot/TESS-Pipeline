function phot_k2targ,campaign,kid,sum,apsize=apsize,mask=mask,k2data=k2data,$
	time=time,noplot=noplot,centroids=centroids,peak=peak,nollc=nollc,$
	data=data,apmask=apmask,quicklook=quicklook,bkg=bkg,sky=sky,$
	k2cube = k2cube

; Photometry on a single target

; Inputs
; campaign - K2 campaign number
; kid - K2 ID 
; apsize - size of box in each dimension to sum over, odd number (usually 3 or 5)
; mask - [[i],[j]] indices to sum over instead of using a box aperture

if N_PARAMS() EQ 0 THEN BEGIN
	PRINT,'phot = PHOT_k2TARG(campaign,kid,sum,apsize=apsize,mask=mask,k2data=k2data,time=time)'
	RETURN,0
ENDIF

if keyword_set(apsize) and keyword_set(mask) then begin
	PRINT,'phot_k2targ: Can not set both apsize and mask'
	RETURN,0
endif
if keyword_set(apsize) then ap = (apsize-1)/2
if keyword_set(mask) then ap = max(mask[*,0])

if ~keyword_set(peak) then peak = [0,0]
if ~keyword_set(mask) then mask = 0
; Get into starting directory
cd,!workdir

scampaign = 'Campaign'+strtrim(string(campaign),2)

; Where to put plots
plotdir = scampaign+'/plots/'
skid = string(kid,format='(i9)')

i0 = where(k2data.k2_id) eq kid
;kepmag = k2data[i0].kepmag
;ra = k2data[i0].RA
;dec = k2data[i0].dec
k2cube = read_k2targ(kid,campaign,time,quality,flux_bkg,apmask1,data=data)
k2cube = double(k2cube)

; Get size of k2cube
dims = size(k2cube,/DIM)
xs = dims[0]
ys = dims[1]
nt = dims[2]

; Accept "no fine point" quality by changing that flag to 0
quality = quality AND NOT 32768L

; Accept rolling band in full frame, flag 18
quality = quality AND NOT 262144L

quality = quality AND NOT 131072L

; Put NANs at all other bad quality frames.
bad = where(quality,/null,nbad)
print,' Number with bad quality: ',nbad
k2cube[*,*,bad] = !VALUES.D_NAN

; Putting NANs at saturated pixels'
sat = where(k2cube gt 5e5,nhi,/null)
k2cube[*,*,sat] = !VALUES.D_NAN

;Remove Background if quicklook set.
if quicklook then begin
	; Create bkg array of median values with nt values.
	; Form array of pixels at all 4 edges.  Ok to double count corners.
;;;;;;;  For removal of rolling bands
	top = reform(k2cube[1:*,-1,*])
	bottom = reform(k2cube[1:*,0,*])
	right = reform(k2cube[-1,1:*,*])
	left = reform(k2cube[0,1:*,*])

	;;; Remove bottom
	;;bkg = [top,right,left]

	;bkg = [top,bottom,right,left]
	; Special case for SN2018oh
	if (kid EQ 228682548) then bkg = [bottom,right]
	right2 = reform(k2cube[-2,2:-2,*])
	left2 = reform(k2cube[1,2:-2,*])
	;bkg = [bkg,right2,left2]
	bkg = [right,left,right2,left2]

	;Sort and take just the lower 2/3rds in intensity
	sz = size(bkg,/dimension)
	bkglow = dblarr(3*sz[0]/4,nt)
	for i=0,nt-1 do bkglow[*,i] = bkg[(sort(bkg[*,i]))[1:3*sz[0]/4],i]
	bkg = median(bkglow,dimension=1)
	bkg = smooth(bkg,16,/nan,/edge_truncate)

	; Remove 3 sigma deviations from bkg
	;bkgmean = mean(bkg,/nan,dimension=1,/double)
	;sgma = STDDEV(bkg, dimension=1, /double, /nan )	
	;for i=0,nt-1 do begin
	;	if i eq 67 then stop
	;	wh = where((bkg[*,i]-bkgmean[i]) gt 3.*sgma[i],/null)
	;	bkg[wh,i] = !VALUES.D_NAN
	;endfor
		;bkg[where(ABS(bkg[*,i]-bkgmean[i]) gt 3.*sigma[i],/null),i] = !VALUES.D_NAN
	; Now we can take the mean on each frame
	;bkg =  mean(bkg,/nan,dimension=1)
endif 


if nhi gt 0 then begin
	print,'phot_k2targ: ',nhi, ' Saturated Pixels in stamp.'
endif
if (campaign eq 3) then begin
	if kid eq 206233462 then begin
	    bad=[882,883,884,886,887,888,889,890,891,892,893,894,895,896,897,898,899,900,901,902,903,904,905,906,907,908,1144,1145,1146,1147,1148,1150,1151,1152,1153,1154,1155,1156,1157,1158,1159,1160,1162,1163,1164,1165,1166,1167]
		k2cube(*,*,bad) = !VALUES.D_NAN
	endif
endif
sum = total(k2cube,3,/nan)
x1 = xs/2
y1 = ys/2
if (kid eq 206260138) then x1 = 10
if (kid eq 206145681) then begin
       	x1 = 4
	y1 = 4
endif
if (kid eq 206169077) then x1 = 10
if (kid eq 206048097) then begin
       	x1 = 10
	y1 = 9
endif
if (kid eq 206454901) then y1 = 11
if (kid eq 206476450) then y1 = 11
; Find peak flux nearest to the center
if peak[0] eq 0 then begin
	peak = peakup(sum,x1,y1,/smooth,nsteps=8) 
	; if no peak, try again without smoothing
	if peak[0] eq -1 then $
		peak = peakup(sum,x1,y1,nsteps=7)
endif else print,'phot_k2targ: Using input Peak value',peak

; Check if too close to the edge, then move in
IF peak[0] NE -1 THEN BEGIN
	IF peak[0] + ap GE xs THEN peak[0] = xs - ap - 1
	IF peak[0] - ap LT 0 THEN peak[0] = ap
	IF peak[1] + ap GE ys THEN peak[1] = ys - ap - 1 
	IF peak[1] - ap LT 0  THEN peak[1] = ap
ENDIF

; We create our own aperture mask.
; We multiply by 3 rather than set pixels to 3 so that 0s stay 0s.
apmask = apmask1
if (peak[0] ge 0 AND mask[0] ne -1) then begin
   print,'peakup: Peak at ',peak
   ; Remove old aperture pixels
   apmask[where(apmask1 EQ 3)] = 1
   if keyword_set(mask) then begin  
	nmask = N_ELEMENTS(mask[*,0])
	if mask[0] NE -1 then $
	     for i = 0, nmask-1 do $
		apmask[mask[i,0]+peak[0],mask[i,1]+peak[1]] *= 3 
   endif else  begin
	apmask[peak[0]-ap:peak[0]+ap,peak[1]-ap:peak[1]+ap] *= 3
   endelse
endif else begin
	apmask = intarr(xs,ys)
	apmask[where(finite(k2cube[*,*,210]),/null)] = 3
	print,'phot_k2targ: No peak, using whole stamp'
endelse
;;;;;; TEST whole aperture
;if mask[0] EQ -1 THEN BEGIN
;        print,'phot_k2targ: No peak, using K2 project aperture mask'
;	apmask[*,*] = 3
;	apmask[10,8] = !VALUES.D_NAN
;	apmask[10,0] = !VALUES.D_NAN
;	apmask[10,1] = !VALUES.D_NAN
;endif

; Convert apmask to double and 1 for in aperture an 0 for out of apeture
apmask2 = INTARR(xs,ys)
apmask2[where(apmask EQ 3)] = 1

; Here if apsize eq 7, just use ntop pixels within the 7 x 7 box.
if apsize EQ 7 then begin
	ntop = 35
	max = max(sum,/nan)
	sum2 = sum
	sum2[where(apmask2 NE 1)] = max
	for i= 0, 49-ntop-1 do begin
		lowest = min(sum2,/nan,wh)
		apmask2[wh] = 0
		sum2[wh] = max
	endfor
;	if kid eq 212072155 then apmask2 = shift(apmask1/3,-1)
endif


; Total flux in aperture
; We do not use /nan in TOTAL because we want a NAN if any NANs are within the apmask2.
; subtract variations at the edge of the stamp if background is not subtracted well.
;smedge = dblarr(nt)
;for i=0, nt-1 do  smedge[i] = mean(k2cube[1,*,i])
;smedge = smooth(smedge,24,/nan,/edge_truncate)
;for i = 0, nt-1 do k2cube[*,*,i] = k2cube[*,*,i]-smedge[i]

phot = dblarr(nt)

;;;for i = 0, nt-1 do phot[i] = TOTAL((k2cube[*,*,i])[WHERE(apmask2 EQ 1d0)])
; Using REBIN to Replicate apmask2 by NT.
; and find location of 0s in apmask2.
maskindices = where(rebin(apmask2,xs,ys,nt) EQ 0)
; Zero out all unwanted pixels.
k2cube2 = k2cube
k2cube2[maskindices] = 0d0
; Total all wanted pixels in 2 dimensions, creating a light curve.
phot = total(total(k2cube2,1),1)
if quicklook then begin
	nmask = TOTAL(apmask2)
	phot = total(total(k2cube2,1),1) - nmask*bkg
endif else phot = total(total(k2cube2,1),1)

; Total all wanted pixels in 2 dimensions, creating a bkg light curve.
sky = flux_bkg
sky[maskindices] = 0d0
sky = total(total(sky,1,/nan),1,/nan)
if ~quicklook then bkg = fltarr(nt)

if (peak[0] eq -2) then phot[where(phot eq 0.0,/null)] = !VALUES.D_NAN

; Drop measurement if more than tol from 2 day mean
;tol = 0.20
;smphot = smooth(phot,48*2,/nan,/edge_truncate)
;nbad = 0
;morebad= where(abs(phot-smphot)/mean(phot,/nan) gt tol,nbad)
;IF (nbad gt 0) then begin
;	print, 'phot_k2targ: Events with counts outside',tol, nbad
;	phot[morebad] = !VALUES.D_NAN
;ENDIF


; Plot LC (if noplot is off)
if ~keyword_set(noplot) then $
	p = scatterplot(time,phot,symbol='dot',title='KTWO '+skid,xtitle='KJD [Days]',ytitle='Counts')
return,phot
end
