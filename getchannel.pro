function getchannel,area,ffi,fitsfile=fitsfile

; return channel, given area, channel in first season (3), and ffi number.
common chblock,quads,channelInArea
; Or give fitsfile instead of ffi

setup_ffi,quarter,season,startime,dateobs,ffilist,n_ffis
nch = 84
if keyword_set(fitsfile) then ffi = where(ffilist eq fitsfile)

; Form channelInArea only if it is not already in common
if ~isa(channelInArea) then begin
  ; Read channel quads
  quads = intarr(4,21)
  openr,13,'KeplerChannels.txt'
  readf,13,quads
  close,13

  ; Find row and column in quads for each channel initially
  whichrow = intarr(nch+1)
  whichcol = intarr(nch+1)
  for chan=1,nch do begin
    for row=0,20 do begin
	whichcol[chan] = where(quads[*,row] eq chan)
	if (whichcol[chan] ne -1) then begin
		whichrow[chan]=row
		break
	endif
    endfor
  endfor

  ; Find channels for each quarter
  channelInArea = intarr(4,nch+1)
  for qrt = 1, 4 do begin
	ssn = (qrt + 2) mod 4
	for a1 = 1, nch do begin
		channelInArea[ssn,a1] = quads(whichcol[a1],whichrow[a1])
	endfor
	quads = shift(quads,-1,0)
  endfor
endif ; end forming channelInArea if it is not already in common
chan=channelInArea[season[ffi],area]
return,chan[0]
end

