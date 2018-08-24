function peakup,img,x1,y1,nsteps=nsteps,smooth=smooth,verbose=verbose
;Move to peak of an image near x1,y1
;Returns [ixc,iyc]
if ~keyword_set(smooth) then smooth=0
if ~keyword_set(nsteps) then nsteps=7
if ~keyword_set(verbose) then verbose=0
dims = size(img,/dimensions)
if verbose then print,'peakup: size pixel map: ', dims
img0 = img

if smooth then begin
	; Convolve image with 3 x 3 window funct.
	kern = dblarr(3,3) + 1d0
	img0 = convol(img,kern)
endif
ixc = fix(x1) & iyc = fix(y1)
for peakups = 0, nsteps-1 do begin
	IF (ixc EQ 0 OR iyc EQ 0 $
	 OR ixc EQ dims[0]-1  OR iyc EQ dims[1]-1) THEN BEGIN
	   PRINT, 'peakup: Ran off the image.  No peak found'
	   return,[-1,-1]
 	endif
		
	box = img0[ixc-1:ixc+1,iyc-1:iyc+1]
	maxbox = max(box,/nan)
	whmax = where(box eq maxbox,count)
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
	  3:    ixc--
	  4: return,[ixc,iyc]
	  5:    ixc++
	  6: begin
		ixc--
		iyc++
	    end
	  7:    iyc++
	  8: begin
		ixc++
		iyc++
	     end
	  else: begin
		 ixc = -1
		 iyc = -1
		 return,[-1,-1]
	  end
	endcase
	if verbose then print,'peakup: max:',maxbox,' at ',ixc,iyc
endfor
print,'Did not finish peak after ',nsteps,' steps'
return,[-1,-1]
end
