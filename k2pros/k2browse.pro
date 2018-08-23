PRO k2browse,campaign,k2data,i0=i0,akid=akid,ccds=ccds,apsize=apsize,mask=mask,$
	bin=bin,dollc=dollc,write=write,yrange0=yrange0,window_title=window_title

; Browse through the PDC LCs  or do raw photometry
; akid - Set to K2_ID to see just one LC
; ccds - 2 element array with start and end channel to work on
;	Set both to a channel number to see all on a single channel
; write - Set to 1 to write out summary statistics
; window_title - set to new window by title, otherwise reuse "lcwin".
; dollc - Just look at project lightcurves, otherwise do photometry on target pixel files

IF N_PARAMS() EQ 0 THEN BEGIN
        PRINT,'Usage: k2browse,campaign,k2data,i0=i0,akid=akid,ccds=ccds,$'
	PRINT,'apsize=apsize,mask=mask,bin=bin,dollc=dollc,write=write,$'
	PRINT,'yrange0=yrange0,window_title=window_title'
	RETURN
ENDIF
cd,!workdir

plot = 1
dum=''

if ~keyword_set(dollc) then dollc=0
if ~keyword_set(bin) then bin=1
if (campaign eq 3) then xmlfile='GO3048_C3.xml'
if (campaign eq 5) then xmlfile='GO5096_C5.xml'
scampaign = 'Campaign'+strtrim(string(campaign),2)
plotdir = scampaign+'/plots/'
if ~keyword_set(i0) then i0 = 0
if ~keyword_set(write) then write = 0
ap = apsize
if keyword_set(mask) then ap = 4

kids = k2data.k2_id
i1 =  n_elements(kids)-1 
for ccd =  ccds[0], ccds[-1] do begin
;;;;;	set = where(k2data.channel eq ccd)
set = where(k2data.k2_id gt 0)
	if set[0] eq -1 then begin
		print,'k2browse: No targets on ccd ',ccd
		continue
	endif
	if i0 eq 0 then i0 = set[0]
	i1 = set[-1]
	kepmag = k2data.kepmag
	;if keyword_set(akid) then begin
	;	i0 = where(kids eq akid)
	;	i0 = i0[0]
	;	i1 = i0
	;endif 
	;IF ~keyword_set(window_title) then window_title = 'lcwin'
	;win1 = getwindows(window_title)
	;if ~isa(win1) then win1 = window(window_title=window_title) else begin
	;	win1.setcurrent
	;	win1.show
	;	win1.erase
	;endelse
	;wait_time=2.5
	if write then begin
		openw,/get_lun,wunit,'C3_sm9i6.txt'
		printf,wunit,'    i      id      kepmag channel  sdev    smdev'
	endif
	; layout params
	lx = 3
	ly = 10
	place = 1
	ccd_old = 0
	for i=i0, i1 do begin
		kid = kids[i]
		skid = string(kids[i],format='(i9)')
;		channel = k2data[i].channel
;;;;
channel=1
;;;;;
		schannel = string(channel,format='(i2)')
;;;;	        pdc_flux = read_K2llc(kid,campaign,time,xcenter,ycenter,$
;;;		    sap_flux,sap_bkg) 
		if dollc then lc = pdc_flux $
		else $
		    lc = phot_k2targ(campaign,kid,apsize=apsize,mask=mask,$
		    k2data=k2data,time=time,/noplot,/nollc)
		nt = n_elements(lc)
		if nt EQ 0 then CONTINUE
		if (nt mod 2 eq 1) then begin
			lc = lc[1:*]
			time = time[1:*]
		endif
		lc2 = rebin(lc,nt/2)
		time2 = rebin(time,nt/2)
		timem = time[20:-20]
		lcsm = smooth(lc[20:-20],96,/nan,/edge_truncate)
		lcmean = mean(lcsm,/nan)
		lcsm = lcsm/lcmean
		result1 = moment(lcsm,sdev=sdev,/nan)
		smdev = sdev*lcmean
		result2 = moment(lc2/lcmean,sdev=sdevlc2,/nan)
		smdevlc2 = sdev*lcmean
		print,'i =',i,' KID = ',kid,' kepmag =',kepmag[i],' Channel = ',channel
		print,'fractional dev = ',sdev,' dev counts = ',smdev
		if write then $
		     printf,wunit,format='(i5,i12,f8.3,i3,1x,E10.2,1x,E10.2)',$
		    	 i,kid,kepmag[i],channel,sdev,smdev
	
		;;;yrange = [1.-3.*sdevlc2,1.+3.*sdevlc2]
		;;yrange = [1.-3.*sdevlc2,1.+3.*sdevlc2]*lcmean
		yrange = [.80,1.25]
	        if keyword_set(yrange0) then yrange=yrange0
		mn = mean(lc,/nan)
		if dollc then $
			mnsap = mean(sap_flux,/nan)
		if (ccd ne ccd_old or ((place mod (lx*ly)) eq 1))  then begin
			place = 1
		    	win = window(window_title='Channel'+$
				string(format='(I2)',ccd), $
				dimensions=[395,512])
		endif
;		p = plot(time,lc,linestyle='',symbol='dot')
;		stop
	

		p1 = plot(/current,time,lc/mn,linestyle='',$
		       	symbol='dot', ytitle='Counts',color='blue',$
			xtitle='BKJD date [days]',layout=[lx,ly,place++],xshowtext=0,$
			yshowtext=0,margin=0,font_size=14,yrange=yrange) 

		if dollc then $
			p2 = plot(/current,/overplot,congrid(time,nt/bin),congrid(sap_flux/mnsap,nt/bin),symbol='dot',$
				linestyle='',color='red')

		text = text(.04,.76,skid,/relative,target=p1,font_size=8)
		text = text(.60,.76,string(long(mn)),/relative,target=p1,font_size=8)
		ccd_old = ccd
		;textkid= text(.7,.2,'K2 '+skid,font_size=14)
		;textchan= text(.7,.25,'Channel '+ schannel,font_size=14)
	
	;	if keyword_set(akid) then begin
	;	if sdev gt 0.007 and smdev gt 3. then begin
	;		read,'Save Plot? ',dum
	;		if dum eq 'y' then $
	;			p1.save,plotdir+'lc_K2_'+skid+'.eps'
	;	endif
	;	endif else wait,wait_time
	endfor ; for io of kids in ccd
endfor ; end loop on ccds
if write then begin
	close,wunit
	free_lun,wunit
endif
return
end
