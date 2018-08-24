pro campaigntargs, campaign, ra, dec, rad, decd

PRINT,' Using rkronrad instead of RPETR50'

; To produce the savefile this is what was done in campaign 10
; Get output from David Thilker on PS1 query
; file = 'K2_Cam10_sample8p5_new_dthilker.fit'
; c10 = read_fits_whole(file) 
; t = c10.CASJOBS_K2_CAM10_SAMPLE8P5_NEW_1.data
; savefile='K2_P1_Camp10.sav'
; save,t,file=savefile

; For campaign 12 and on, we got csv file instead of fits
;cd,'/mnt/sda1/home/eshaya/Documents/Kepler/K2/Cycle3/Cycle3-Camp10'
;file= 'K2C12_arminr.csv'
;;; spawn,'vim '+file
;;; :%s/"//g
; copy 1st line of data
; add single quote around objID

if campaign eq 14 then file='K2C14pv3_v6_arminr.csv'
if campaign eq 15 then file='K2C15pv3_v6_arminr.csv'
if campaign eq 16 then file='K2C16pv3_v6_arminr.csv'
findbig = 1
dum = ''
read,'Read csv or saveset file (c or s)',dum
if dum eq 'c' then  t=read_delimited(file=file,nskip=3,delimiter=",")
;% Compiled module: READ_DELIMITED.
;;; nans=where(t.rmeankronmag eq -999.,ng)   
;;; t[nans].rmeankronmag=!values.f_nan
;;; nans=where(t.gmeankronmag eq -999.,ng)
;;; t[nans].gmeankronmag=!values.f_nan    
;;; nans=where(t.zmeankronmag eq -999.,ng)
;;; t[nans].zmeankronmag=!values.f_nan  
;;; whrlim= where(t.rmeankronmag lt 17.9)
;;; t=t[whrlim]
if campaign eq 10 then savefile='K2C10_arminr.sav'
if campaign eq 12 then savefile='K2C12_arminr.sav'
if campaign eq 14 then savefile='K2C14_arminrv1.sav'
if campaign eq 15 then savefile='K2C15_arminrv1.sav'
if campaign eq 16 then savefile='K2C16_arminrv1.sav'


; Then to run this 
; campaigntargs, campaign,ra,dec,rad,decd
; Outputs
; ra is string of ra in sexidecimal
; dec is string of dec in sexidecimal
; rad is string of ra in degrees
; decd is string of dec in degrees
ra=''
dec=''
if campaign eq 8 then begin
	ra = '01:05:21.12'
	dec = '+05:15:44.45'
	scamp = '8'
endif
if campaign eq 10 then begin
	ra= '12:27:07.07'
	dec='-04:01:37.8'
	scamp = '10'
endif
if campaign eq 12 then begin
	ra= '23:26:43'	
	dec= '-05:06:08'
	scamp = '12'
endif
if campaign eq 14 then begin
	ra= '10:42:44'	
	dec= '06:51:06'
	scamp = '14'
endif
if campaign eq 15 then begin
	ra= '15:34:28'	
	dec= '-20:04:44'
	scamp = '15'
endif
if campaign eq 16 then begin
	ra= '08:54:50'	
	dec= '18:31:31'
	scamp = '16'
endif

if ra eq '' then stop
rad=ten(ra)*15.
decd=ten(dec)
rununcrowd = 0
rlimit = 19.0
zlimit = 0.15
rkronradlimit = 25.

if dum eq 'c' then begin
	; Get rid of duplicates
	print,'Original N = ',n_elements(t)
	t = t[uniq(t.objid,sort(t.objid))]
	print,'After uniq, N = ',n_elements(t)
	
	; Put in Nans wherever the value is -999
	tagnames = get_tags(t)
	print,'TAG    NANs'
	foreach tag, tagnames do begin
		out = Execute('ttag = t' + tag) 
		if (size(ttag,/tname) NE 'FLOAT') THEN CONTINUE
		whnans = where(ttag EQ -999., nnans)
		if nnans gt 0  then begin
			out = Execute('t[whnans]' + tag + ' =  !VALUES.F_NAN')
			print,tag, nnans
		endif
	endforeach
	save,t,file=savefile
endif

if dum eq 's' then restore,savefile

Print, 'Number Suspect = ',long(total(bitget(t.qualityflag,6)))
Print, 'Number Bad = ',long(total(bitget(t.qualityflag,7)))
  ; Limit r-mag
   t = t[where(t.rmeanpsfmag lt rlimit,ntarg)]
   print,format='(a,f4.1,a,i6)','After r limit of ',rlimit,' N = ',ntarg
   ; Limit size
   ;whsmall = where(t.rkronrad lt rkronradlimit,ntarg,complement=whbig)
   print,format='(a,f4.1,a,i6)','After rkronrad limit of ',rkronradlimit,' N = ',ntarg
    	 ;t = t[whsmall]
  	 ; Limit cz
;;	;; SKIPPING zlim
  	  ;ifargal = 0
  	 ; zin = where(t.p2_photoz_1 le zlimit,complement=ifargal,  ntarg)
  	 ; t = t[zin]
;  	  print,format='(a,f4.1,a,i6)','After cz limit of ',zlimit,' N = ',ntarg
  	  ; Test for star/galaxy
	  psfdiff = t.rmeanpsfmag - t.rmeankronmag
    igal = where($
            	psfdiff gt 0.625 $
       	and $
            	t.rmeankronmag gt 14.0 $
       	and $
            	psfdiff lt 3.0, $
       	complement=istar, ntarg)
        ;(t.rmeanpsfmag - t.rmeankronmag gt 0.3 $
        ;	   and t.rmeankronmag gt 15.2), $
    ; t1 is galaxy array, s1 is star array
    t1 = t[igal]
    print,'After star and too extended separation, N = ',ntarg
Print, 'Number Suspect = ',long(total(bitget(t1.qualityflag,6)))
Print, 'Number Bad = ',long(total(bitget(t1.qualityflag,7)))
    s1 = t[where(psfdiff gt -0.7 and psfdiff le 0.625)]
    ;tfar = t[ifargal]
    big = t[where(psfdiff ge 3.0 )]
    big = big[where(big.rkronrad gt 0,nbig)]

    ntargest = ntarg*.6
    print,'Ntarg est. after correcting for gaps = ',ntargest

  ; Color plots
  ; Plot targs so far in black
pltcateg = plot(t1.rmeanpsfmag -t1.rmeankronmag,t1.rmeanpsfmag,symbol='x',linestyle='', ytitle='Rpsf [Mag]',xtitle='Rpsf - R [Mag]',sym_size=.5)

  ; Plot far galaxies in blue
  ;pltcateg = plot(/overplot,tfar.rmeanpsfmag -tfar.rmeankronmag,tfar.rmeankronmag,symbol='x',linestyle='',color=!color.blue,sym_size=.5) 

  ; Plot stars in red
  pltcateg = plot(/overplot,s1.rmeanpsfmag -s1.rmeankronmag,s1.rmeanpsfmag,symbol='+',linestyle='',color='red') 
  ; Plot big in blue
  pltcateg = plot(/overplot,big.rmeanpsfmag -big.rmeankronmag,big.rmeanpsfmag,symbol='+',linestyle='',color='blue') 
  pltcateg = plot(/overplot,[.3,.3],[12,18])

; Plot targets on the sky
side = 8./sqrt(2)
ralim=rad+side/[cos(decd/!radeg),-cos(decd/!radeg)]
declim = decd + [side,-side]
if findbig eq 0 then pltradec= plot(t1.ra,t1.dec,linestyle="",symbol="*")
if findbig eq 1 then pltradec= plot(big.ra,big.dec,linestyle="",symbol="*")
xborder = [ralim,ralim,ralim[0]*[1,1],ralim[1]*[1,1]]
yborder = [declim[0]*[1,1],declim[1]*[1,1],declim,declim]
pltradec=plot(/overplot,xborder,yborder,linestyle="-",color=!color.red)

; Run uncrowd.  tout is list with no nearby star
if rununcrowd then begin
     whnohit=uncrowd(t1,whhit=whhit)
     tout2 = t1[whnohit]
     thit = t1[whhit]

     ; sort on magnitudes of clean set
	tout2 = tout2[sort(tout2.rmeankronmag)]
	thit = thit[sort(thit.rmeankronmag)]
     ;tout3 = [tout2,thit]
     tout3 = tout2
     ntarg = n_elements(tout3)
endif else tout3 = t1
openw,/get_lun,wunit,'tout3.cat'
for i=0,n_elements(tout3)-1 do printf,wunit,format='(2(f10.6,1a),f10.3,1a,a)',$
	tout3[i].ra,',',tout3[i].dec,',',tout3[i].rmeankronmag,',',tout3[i].objid
close,wunit
free_lun,wunit
openw,/get_lun,wunit,'stars.cat'
for i=0,n_elements(s1)-1 do printf,wunit,format='(2(f10.6,1a),f10.3,1a,f10.3,1a,a)',$
	s1[i].ra,',',s1[i].dec,',',s1[i].rmeankronmag,',',s1[i].rmeanpsfmag - s1[i].rmeankronmag,',',s1[i].objid
close,wunit
if findbig ne 0 then begin
   openw,/get_lun,wunit,'big.cat'
   for i=0,n_elements(big)-1 do printf,wunit,format='(2(f10.6,1a),2(4f10.3,1a))',$
      big[i].ra,',',big[i].dec,',',big[i].rmeankronmag,',',$
      big[i].rkronrad,',',big[i].rkronrad
   close,wunit
endif

; Now run K2FOV
print,'About to runK2onSilicon.py'
read,'Skip? ',dum
if dum ne 'y' then begin
	if findbig eq 0 then spawn,'~/Documents/Dropbox/Kepler\ Mission/runK2onSilicon.py tout3.cat '+strtrim(string(campaign),2)
	if findbig eq 1 then spawn,'~/Documents/Dropbox/Kepler\ Mission/runK2onSilicon.py big.cat '+strtrim(string(campaign),2)
	spawn,'firefox targets_fov.png'
	if findbig eq 0 then spawn,'mv targets_fov.png targets_fov0.png'
	if findbig eq 1 then spawn,'mv targets_fov.png targets_fovBig.png'
endif

; Read in K2FOV output
silicon = {ra:1d0, dec:1d0, mag:1e0, flag: 0b}
if findbig eq 0 then silicon = replicate(silicon,ntarg)
if findbig eq 1 then silicon = replicate(silicon,nbig)
file='targets_siliconFlag.csv'
openr,/get_lun,runit,file
readf,runit,silicon
close,runit
free_lun,runit
onSilicon = tout3[where(silicon.flag eq 2,nsil)] 
if findbig eq 1 then  $
	onSilicon = big[where(silicon.flag eq 2,nsil)] 
print,'After runK2onSilcon: Number on silicon',nsil 
Print, 'Number Suspect = ',total(bitget(onSilicon.qualityflag,6))
Print, 'Number Bad = ',total(bitget(onSilicon.qualityflag,7))
;MWRFITS, onSilicon, 'K2_Camp'+scamp+'_targs.fits', /Create, /ASCII, Separator=','
;
openw,/get_lun,wunit,'onSilicon.cat'
for i=0,nsil-1 do printf,wunit,format='(2(f10.6,1a),f10.3,1x)',$
	onSilicon[i].ra,',',onSilicon[i].dec,',',onSilicon[i].rmeankronmag
close,wunit
free_lun,wunit


; Now go to epic search
print,'Need to create epic.txt file'
save, onSilicon,file='onSilicon.sav'
;http://archive.stsci.edu/k2/epic/search.php?form=fuf
; Local File: onSilicon.cat
; Delimiter:  ","
; Output Format: comma-separated
; Maximum Records per Target: 1
; Output Coords: degrees.
; Output Columns: EPIC,RA,Dec,KepMag,Ang Sep 
; Sort By: set all 3 to   nulls
; Click on Add Entry number
; Click on Suppress null result message
; filename, save output as epic.txt
; gvim epic.txt  
; Change ang sep  to angsep
; At top second line change to:  long,long,double,double,float,float
;%s/no rows found/-1,0.,0.,0.,0./
read,'Is epic.txt ready? ', dum
if findbig eq 0 then epic=read_delimited(file='epic.txt',delimiter=',',nskip=2)
if findbig eq 1 then epic=read_delimited(file='epicBig.txt',delimiter=',',nskip=2)
; entry is index in onSilicon
epic.entry = epic.entry - 1
; Check that epic has same number as onSilicon.
if max(epic.angsep) gt 10./60. then begin
	print,' epic object too far'
	stop
endif

; find which galaxies are not in epic
indx=intarr(nsil)      
indx[epic.entry]=1    
; whnoepic is index in onSilicon where there is no epic source
whnoepic=where(indx eq 0,noff)
print,'After EPIC database search: Number not in epic is ',noff
noepic = onSilicon[whnoepic]
if findbig then noefile = 'noepicBig.txt' else noefile = 'noepic.txt'
openw,/get_lun,wunit,noefile
for i=0,noff-1 do printf,wunit,format='(f10.6," ",f10.6)',$
	noepic[i].ra,noepic[i].dec
close,wunit

Print, 'Number Suspect in noepic = ',long(total(bitget(noepic.qualityflag,6)))
Print, 'Number Bad in noepic = ',long(total(bitget(noepic.qualityflag,7)))

Print, 'Need NED names for noepic ones'
read,'Continue when you have a ned.txt file',dum
; Now go to NED to get names for the noepic.txt
; http://ned.ipac.caltech.edu/forms/nnd.html
; no rows
; Check Tab
; Check NED Preferred Object Name
; Check Ra & DEC
; Check NED's preferred Object Type
; Check Redshift
;RA|DEC|Sep|Name|Object|Redshift
; output to ned.txt nedBig.txt
; Top two lines should look like this:
;RA|DEC|Sep|Name|Object|Redshift
;double|double|float|string|string|double

; ned.txt and noepic.txt have the same number of entries
if findbig then nedfile = 'nedBig.txt' else nedfile='ned.txt'
ned=read_delimited(file=nedfile,delimiter='|',nskip=2)

; Put PS1 name into NED name
noned = where(strtrim(ned.name,2) eq '',nnoned) 
Print, 'After NED database check, number with no ned or epic name',nnoned
Print, 'Number Suspect in noned = ',long(total(bitget(noepic[noned].qualityflag,6)))
Print, 'Number Bad in noned = ',long(total(bitget(noepic[noned].qualityflag,7)))
suspect = where(bitget(noepic[noned].qualityflag,6) eq 1)
print,'Suspect'
print,noepic[noned[suspect]].ra,noepic[noned[suspect]].dec
bad = where(bitget(noepic[noned].qualityflag,7) eq 1)
print,noepic[noned[bad]].ra,noepic[noned[bad]].dec

ned[noned].name = 'PS1 '+strtrim(string(noepic[noned].objid),2)
; Put NED/PS1 name and EPIC.epic into targname
; A little problem now because epic.epic name is a long and ned.name is a string
targname = strarr(nsil)
targmag = fltarr(nsil)
comment = strarr(nsil)

targname[epic.entry] =string(epic.epic)
targname[whnoepic] = ned.name
targname = strtrim(targname,2)
targmag[epic.entry] = epic.kepmag
targmag[whnoepic] = onSilicon[whnoepic].rmeankronmag
targmag = strtrim(string(targmag),2)
comment[whnoepic] = 'Not'

; Sort on mag
srti = sort(targmag)
s_targmag=targmag[srti]
s_onSilicon = onSilicon[srti]
s_targname=targname[srti]
s_comment = comment[srti]

if findbig then outfile='K2_C'+scamp+'Big-p1.csv' else outfile='K2_C'+scamp+'-p1.csv'
openw,/get_lun,wunit,outfile
for i=0,nsil-1 do begin
;	if (where(i eq whnoepic[noned[bad]]))[0] ne -1 then continue
;	if (where(i eq whnoepic[noned[suspect]]))[0] ne -1 then continue
;	if (where(i eq whnoepic[noned]))[0] ne -1 then begin
	if (strmid(s_targname[i],0,3) eq 'PS1') then begin
		badras= string(format='(f10.6)',s_onSilicon[i].ra)
		baddec=string(format='(f10.6)',s_onSilicon[i].dec)
		print,i,badras,baddec,s_targname[i]
		spawn,"firefox " +"'"+"http://ned.ipac.caltech.edu/cgi-bin/imgdata?objname=&in_csys=Equatorial&in_equinox=J2000.0&lon="+badras+"d&lat="+baddec+"d&width=1.0&height=1.0&search_type=DSS+Image"+"'"
		read,' Bad?',dum
		if dum eq 'y' then continue
	endif
	printf,wunit,s_targname[i],",", string(format='(f10.6)',s_onSilicon[i].ra),",",  string(format='(f10.6)',s_onSilicon[i].dec),",", s_targmag[i],",30,0.0,0.0,",string(format='(f6.2)',s_onSilicon[i].rkronrad),",", s_comment[i]
endfor
close,wunit
free_lun,wunit
print,'Need to join in vim where "Not" because printf adds CR.'

return
end
