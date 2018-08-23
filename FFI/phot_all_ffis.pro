PRO PHOT_ALL_FFIS,maglimit,quarter,season,startime,dateobs,startffi=startffi,endffi=endffi,$
	startchannel=startchannel,endchannel=endchannel,ap=ap,getinfo=getinfo,$
	avgxshift=avgxshift,avgyshift=avgyshift
; Do photometry on all Kepler FFIs
if ~keyword_set(startffi) then startffi=0
if ~keyword_set(ap) then ap=2
if ~keyword_set(startchannel) then startchannel=1
if ~keyword_set(getinfo) then getinfo=0
nchannels=84
if ~keyword_set(endchannel) then endchannel=nchannels
; list of ffi files
spawn,'ls -1 FFIs',ffilist
nffis = n_elements(ffilist)
if ~keyword_set(endffi) then endffi=nffis-1
if (getinfo eq 1) then endchannel = -1
if ~isa(season) then season=intarr(nffis)
if ~isa(quarter) then quarter=intarr(nffis)
if ~isa(startime) then startime=dblarr(nffis)
if ~isa(dateobs) then dateobs=strarr(nffis)
; list of apfiles
spawn,'ls -1 apdir',apfiles
nffis = endffi-startffi+1
naps = n_elements(apfiles)
; Measures of the stamp
margin = 2
; For side to center
center = margin+ap
; Across the whole stamp
width = 2*center + 1
lastp = width-1
keep1 = margin
keep2 = center+ap
sky1 = margin-1
sky2 = keep2+1
; Number of pixels in aperture (will need to subtract NaNs)
nkeep = (2d0*double(ap)+1d0)^2

photunit=12
; Loop over all FFIs
for ffi = startffi, endffi do begin
	fitsfile=ffilist[ffi]
	if (getinfo eq 1) then begin
		fits_read,"FFIs/"+fitsfile,data,header 
	endif else begin
		data = read_fitswhole("FFIs/"+fitsfile)
		header = data.header
	endelse
	
	; Gather info on quarter and season for return
	quarter[ffi]=sxpar(header,'QUARTER')
	if (quarter[ffi] eq 0) then quarter[ffi] = 1
	s_quarter = strtrim(string(quarter[ffi]),2)
	season[ffi]= (quarter[ffi]+2) mod 4
	s_season = strtrim(string(season[ffi]),2)
	if (ffi le 28) then timekey='STARTIME' else timekey='MJDSTART'
	startime[ffi]=sxpar(header,timekey)
	dateobs[ffi]=sxpar(header,'DATE-OBS')

	; Get all apfiles for this ffi.
	rootname = strmid(fitsfile,4,13)
	apsffi = apfiles[where(stregex(apfiles,rootname,/boolean))]

	; Loop over each channel (CCD)
	for channel = startchannel, endchannel do begin
		print,'Channel: ',channel,' FFI: ',ffi
		; Select aperture file for this channel and ffi
		s_channel = strtrim(string(channel),2)
		apfile = apsffi[where( stregex(apsffi,'ch'+s_channel+'.ap',/boolean))]
		apstr = read_apfile(ffi,channel,ffilist)
		; Limit magnitude of object to do and count = nobject
		whtargs = where(apstr.kepmag lt maglimit, nobject)
		;print,'Nobject', nobject
		xc1=apstr[whtargs].x
		yc1=apstr[whtargs].y
		kepid=apstr[whtargs].kepid
		kepmag=apstr[whtargs].kepmag
		ra=apstr[whtargs].ra
		dec=apstr[whtargs].dec
		ixc1 = round(xc1)
	   	iyc1 = round(yc1)
		img = data.(channel).data
		whn5 = where(apstr.kepmag lt maglimit+5,nwhn5)
		xc5=apstr[whn5].x
		yc5=apstr[whn5].y
		mag5=apstr[whn5].kepmag

		photfile = 'phot/'+rootname+'_q'+s_quarter+'_s'+s_season+'_c'+s_channel+'.phot'
		openw,photunit,photfile
		print,'Opening ',photfile
		printf,photunit,nobject
		printf,photunit,format='(a9,2a10,a6,2a9,2a3,2a12)','kepid','ra','dec','mag','xc','yc','xpk','ypk','phot','sky'
		;print,format='(a9,2a10,a6,2a9,2a3,a6)','kepid','ra','dec''mag','xc','yc','xpk','ypk','phot'
		totxshift = 0
		totyshift = 0
		; Loop over each object
		for object = 0, nobject-1 do begin
			xc = xc1[object] & yc = yc1[object]
	 		ixc = fix(xc) & iyc = fix(yc)
			magobject = kepmag[object]

			;Move to peak
			peakdone = 0
		    	for peakups = 0, 4 do begin
				box = img[ixc-1:ixc+1,iyc-1:iyc+1]
				maxbox = max(box)
				whmax = where(box eq maxbox,count)
				if (box[1,1] eq maxbox) then whmax[0] = 4
				case whmax[0] of
				  0: begin
					ixc--
					iyc--
				     end
				  1:    iyc--
				  2: begin
					ixc++
					iyc--
				     end
				 3:     ixc--
				 4: peakdone = 1
				 5:     ixc++
				 6: begin
					ixc--
					iyc++
				    end
				 7:     iyc++
				 8: begin
					ixc++
					iyc++
				    end
				endcase
				if (peakdone eq 1) then break
		    	endfor
			if (peakups gt 4) then goto,failure
			xshift = ixc - fix(xc)
			yshift = iyc - fix(yc)
		
			; Cutout stamp around object
  			stamp = img[ixc-center:ixc+center,iyc-center:iyc+center]

			; If peak is NaN go to next object
			if (not finite(stamp[center,center])) then goto,printit

			; Set pixels with nearby object to NaN
			; Loop over each object near target
			; Look for nearby object within 2*ap
			; Diff between all others (rounded) and present 
			; First, find object within 3 mag of target
			wh3 = where(mag5 lt magobject+3)
			xdiff3 = fix(xc5[wh3]) - ixc 
			ydiff3 = fix(yc5[wh3]) - iyc 
			whxnear3 = where(abs(xdiff3) le center and abs(xdiff3) gt 2,nnear3)
			if (nnear3 ne 0) then $
				whynear3 = where(abs(ydiff3[whxnear3]) le center $
						and abs(ydiff3) gt 2,nnear3)
			if (nnear3 ne 0) then begin
			   whnear3 = whxnear3[whynear3]
			   xd3 = xdiff3[whnear3]
			   yd3 = ydiff3[whnear3]
			   for n = 0, nnear3-1 do begin
				xd = xd3[n] & yd = yd3[n]
				; Put NaNs in 3x3 block around neighbor
				; But, not if in center or next to center
				stamp[0 > (center+xd-1):(center+xd+1) < lastp,$
				      0 > (center+yd-1):(center+yd+1) < lastp] = !VALUES.F_NAN
			   endfor
		        endif
			   
			; If mag between 3 and 5 mag fainter just NaN 1 pixel
			wh5 = where(mag5 gt magobject+3 and mag5 lt magobject+5,nnear5)
			if (nnear5 eq 0) then goto, endnear5
			xdiff5 = fix(xc5[wh5]) - ixc 
			ydiff5 = fix(yc5[wh5]) - iyc 
			whxnear5 = where(abs(xdiff5) le center $
				and abs(xdiff5) gt 2, nnear5)
			if (nnear5 eq 0) then goto, endnear5
			whynear5 = where(abs(ydiff5[whxnear5]) le center $
						and abs(ydiff5) gt 2,nnear5)
			if (nnear5 eq 0) then goto,endnear5
			whnear5 = whxnear5[whynear5]
			xd5 = xdiff5[whnear5]
			yd5 = ydiff5[whnear5]
			stamp[center+xd5, center+yd5] = !VALUES.F_NAN
endnear5:
			  
			nans = where(stamp eq !VALUES.F_NAN, nnans)
			; for i = 0,lastp do print,format='(9e12.2)',stamp(*,i)
			; print,nnear3,nnear5

			; Measure sky on 4 sides
			xsky1 = min(stamp[0:sky1, keep1:keep2],/nan) 
	        	xsky2 =	min(stamp[sky2:lastp, keep1:keep2],/nan)
			ysky1 = min(stamp[keep1:keep2, 0:sky1],/nan) 
	        	ysky2 =	min(stamp[keep1:keep2, sky2:lastp],/nan)
			sky = (xsky1+ysky1+xsky2+ysky2)/4d0

			;Sum of counts in aperture - sky*npixels
			phot = total(stamp[keep1:keep2,keep1:keep2],/double,/nan) $
			       	- sky*(nkeep-nnans)
			; If counts is negative, make it NaN
			if (phot lt 0d0) then goto,failure
			; Centroids in xc and yc
			; Compare counts in pix Pixels on either side of center
			;  Needs to be calibrated with PSF
			threesky = 3d0*sky
			xfc =  total(stamp[center+1, center-1:center+1])-threesky
			xfb =  total(stamp[center, center-1:center+1])-threesky
			xfa =  total(stamp[center-1, center-1:center+1])-threesky
			xcntrd = abs(xfa-xfc)/(abs(xfa-xfc)+xfb-xfa*xfc/xfb)

			yfc = total(stamp[center-1:center+1, center+1])-threesky
			yfb = total(stamp[center-1:center+1, center])-threesky
			yfa = total(stamp[center-1:center+1, center-1])-threesky
			ycntrd = abs(yfa-yfc)/(abs(yfa-yfc)+yfb-yfa*yfc/yfb)

			if (xfc gt xfa) then xc = 0.5d0+xcntrd else xc = 0.5d0-xcntrd
			if (yfc gt yfa) then yc = 0.5d0+ycntrd else yc = 0.5d0-ycntrd

			; Change back from stamp frame to channel frame
			; Adjust for frame where corners of pixels are at integer values.
			xc += double(ixc) 
			yc += double(iyc)
			goto, printit
		failure:		
			phot = !values.f_nan
			xc = !values.f_nan
			yc = !values.f_nan
		printit:		
			printf,format='(i9,2f10.5,f6.2,1x,2f9.3,2i3,2e12.5)',photunit,kepid[object],$
				ra[object],dec[object],magobject,xc,yc,xshift,yshift,phot,sky
			totxshift += abs(xshift)
			totyshift += abs(yshift)
		endfor  ;end loop on objects
		avgxshift = float(totxshift)/float(nobject)
		avgyshift = float(totyshift)/float(nobject)
		print,'avgxshift,avgyshift: ',avgxshift,avgyshift
		close,photunit
	endfor; end loop on channels
endfor ; end loop on ffis
end
