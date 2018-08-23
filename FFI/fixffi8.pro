print,start
if (start eq 1) then begin
print,'Starting'
channel++
print,'Channel = ', channel
img1=fits8.(channel).data
apstr=read_apfile(8,channel,ffilist)
whtarg= where(apstr.kepmag lt 15.)
iixc=apstr[whtarg].x
yc=apstr[whtarg].y
tv1,img1,4e5,1e6 & mark,img1,xc,yc
start = 0
endif


stop
	case mv of
		'l':	apstr.x -= 4.
		'd':	apstr.y -= 4.
		'r':	apstr.x += 4.
		'u':	apstr.y += 4.
		else:
	endcase
	write_apfile,ffi,channel,apstr,ffilist

if (start eq 0) then begin
print,'Ending'
phot_all_ffis,17.,quarter,season,startime,dateobs,startffi=8, endffi=8,startchannel=channel,endchannel=channel,totxpeak=totxpeak,totypeak=totypeak
print,' Total xpeak = ',totxpeak, ', Total ypeak = ',totypeak
ffi_calib,s0,startchannel=channel,endchannel=channel,set=set,/save
ffi_calib,s0,startchannel=channel,endchannel=channel,set=set,/save,/noread
start = 1
endif
end

