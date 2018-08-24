function get_centroids,ccds,k2data,campaign,cen=cen,noposcorr=noposcorr
;+
; NAME:
;	get_centroids
;
; DESCRIPTION:
;	Outputs a structure with the pointing motion of K2 as seen by
;   	each channel.  It averages centroids of targets on each 
;	channel.  Normally it uses project values in K2 llc files.
;	but with quicklook set, it will calculate centroids of each target
;       Works on a single K2 campaign.
;
; CATEGORIES:
;	K2 data processing, Astronomy
;
;
; PARAMS:
;	ccds : in, Type=2 element int array with the 
;	first and last channel numbers for it to work on.
;
;	k2data : in, Type=Structure.  Info on the campaign.
;       
;	campaign : in Type=Int. campaign number
; 
;
; KEYWORDS:
;
;     cen : in Type=structure.  If centroid structure given, then just show
;	plots of the K2 motion for each channel. 
;
;	noposcorr : in, Type=Int.  If set to 1, then solve for 
;	centroids of every target.  Used when project centroids are not available
;
;
; USES:
; 
;
; AUTHOR:
;  Edward J Shaya
;
;
; HISTORY:
; Created January 2013
;
;-

if n_params() eq 0 then begin
print,'Usage: centroids = get_centroids(ccds,k2data,campaign)'
return,0
endif
if keyword_set(cen) then centroids = cen
if ~keyword_set(noposcorr) then noposcorr = 0
for ccd = ccds[0],ccds[1] do begin
	print,''
	print,'Channel: ',ccd
	print,''
    if (campaign eq 10 and ccd eq 9) then continue
    if (campaign eq 10 and ccd eq 10) then continue
    if (campaign eq 10 and ccd eq 11) then continue
    if (campaign eq 10 and ccd eq 12) then continue
    whccd = where(k2data.channel eq ccd, nkids)
    if nkids eq 0 then continue
    kids = k2data[whccd].k2_id
    if ccd eq ccds[0] then begin
        if noposcorr then  $
        k2cube = read_k2targ(kids[0],campaign,time,quality,flux_bkg,apmask) $
     else $ 
        llc=read_k2llc(kids[0],campaign,time,xc,yc)
        nt = n_elements(time)
        centroids = dblarr(85,2,nt)
    endif
    xcs = 0.0d0
    ycs = 0.0d0
    xcs = []
    ycs = []
    nkids0 = nkids
    nodo = nodo_list(campaign,peakhash,undoable)		
    nodo = [nodo,229227744,212072155,212072271]
    nkids = 0
    fwhm = 1.5
    foreach kid, kids do begin
	if ~ISA(WHERE(nodo EQ kid,ndo,/null),/null) then continue 

        if ~noposcorr then begin
            llc=read_k2llc(kid,campaign,time,xc,yc)
        endif else begin
            k2cube = read_k2targ(kid,campaign,time,quality,flux_bkg,apmask) 
            quality[where(quality eq 32768L,/null)] = 0
            bad = where(quality ne 0,/null,nbad)
            k2cube[*,*,bad] = !VALUES.D_NAN
            sum = total(k2cube,3,/nan)
            dims = size(k2cube,/DIM)
            x1 = dims[0]/2
            y1 = dims[1]/2
	    ;peak = peakup(sum,x1,y1,/smooth,nsteps=7) 
	    peak = peakup(sum,x1,y1,nsteps=7) 
	    if peak[0] EQ -1 THEN $
                 peak = peakup(sum,x1,y1,nsteps=7)
            IF peak[0] EQ -1 THEN peak=[x1,y1]
            xc = fltarr(nt) - 1
            yc = fltarr(nt) - 1
            if (dims[0] lt 30 and dims[1] lt 30) then begin
		; embed k2cube in larger cube if it is small
	    	board = fltarr(31,31,nt)
		board[15-x1,15-y1,0] = k2cube
                xcen0 = 15-x1+peak[0]
                ycen0 = 15-y1+peak[1]
	    endif else begin
            	board = k2cube
                xcen0 = peak[0]
                ycen0 = peak[1]
	    endelse

            for i = 0,nt-1 do begin
           ;     if (dims[0] lt 30 and dims[1] lt 30) $
           ;         then begin
           ;         board = fltarr(31,31) 
           ;         board[15-x1,15-y1] = k2cube[*,*,i]
           ;         xx = 15-x1+peak[0]
           ;         yy = 15-y1+peak[1]
           ;     endif else begin
           ;         board = k2cube[*,*,i]
           ;         xx = peak[0]
           ;         yy = peak[1]
           ;     endelse
                peak = peakup(board[*,*,i],xcen0,ycen0,/smooth,nsteps=7)
                gcntrd,board[*,*,i],peak[0],peak[1],xcen,ycen,fwhm
                xc[i] = xcen
                yc[i] = ycen
            endfor
	    whnot = where(xc eq -1 or yc eq -1,/null)
	    xc[whnot] = !VALUES.F_NAN
	    yc[whnot] = !VALUES.F_NAN
        endelse
        nti = n_elements(xc)
        whh = where(finite(xc,/nan),nnans)

        ; Don't use xc's if too many NaNs or not enough data points
        if (nnans gt 850 or nti ne nt) then begin
		print,'get_centroids: skipping ',kid,' Nnans = ',nnans
		continue
	endif

        xcs = [[xcs],[xc-median(xc)]]
        ycs = [[ycs],[yc-median(yc)]]
	max = 1
        xcs[where(abs(xcs) gt max or abs(ycs) gt max)] = !VALUES.F_NAN
        ycs[where(abs(xcs) gt max or abs(ycs) gt max)] = !VALUES.F_NAN
	nkids++
    endforeach ; target
    if (nkids lt 2) then continue
    if (size(xcs,/n_dim) eq 1) then continue
    xcs = mean(xcs,dimension=2,/double,/nan)
    ycs = mean(ycs,dimension=2,/double,/nan)

    xcs = xcs - xcs[0]
    ycs = ycs - ycs[0]

    print,'Got Centroids for ccd',ccd,' Nkids = ',nkids,' of ',nkids0
    ;wh=where(finite(xcs),nfin)
    ;print,'no. finite ',nfin

    centroids[ccd,0,*] = xcs
    centroids[ccd,1,*] = ycs
endfor ;ccds
  lx =3
  ly = 5
  for k=0,1 do begin
      if k eq 0 then sx = ' ,X'
      if k eq 1 then sx = ' ,Y'
      for ccd=ccds[0],ccds[1] do begin
          if (campaign eq 10 and ccd eq 9) then continue
          if (ccd-ccds[0]) mod (lx*ly) eq 0 then begin
              place = 1
              p0=plot(centroids[ccd,k,*],symbol='dot',linestyle='',$
         layout=[lx,ly,place++],title=string(ccd)+sx,margin=[.1,.1,.15,.15])
          endif else begin
              p = plot(centroids[ccd,k,*],symbol='dot',linestyle='', $
         layout=[lx,ly,place++],/current,title=string(ccd)+sx,margin=[.1,.1,.15,.15])
        endelse
    endfor
endfor
return,centroids
end
