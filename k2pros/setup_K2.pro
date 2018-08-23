common k2common,k2data,campaign
if !version.os EQ 'Win32' Then $
	defsysv,'!workdir','C:\Users\eshaya\Documents\K2work' $
else $
    defsysv,'!workdir','/home/eshaya/Documents/K2'
cd,!workdir
campaign=0
read,'campaign? ', campaign 
apsize = 0
read,' Apsize: ',apsize 
npca = 0
read,' Npca: ',npca
read,' nopca: ',nopca
read,' write: ', write
read,' oneshot: ', oneshot
nearby = ''
; If Nearby campaign then enter letter N, otherwise hit return
read,' Nearby: ', nearby
npca = fix(npca)
nopca = fix(nopca)
write = fix(write)
bin = 1
t0 = 0
t2 = 0
t3 = 0
tfinal = 0
delt0 = 0
pstep = 1
araw = 0
pcavec = 0


if ~campaign then read,'Campaign: ',campaign
resetx
ksn2014a = 206361816
KSN2014b = 205922648
KSN2014c = 206010203
ksn2015a = 211394078
ksn2015b = 211740259
ksn2015c = 211334718 
ksn2015e = 212535880
KSN2015g = 212816029
KSN2015h = 211845655
KSN2015j = 229227734
; KSN2015K .1Ia
KSN2015k = 212593538
KSN2016a = 220484242
KSN2016b = 220578589
KSN2016c = 220366521
KSN2016e = 228955354
KSN2016f = 228753156
KSN2017a = 246344673

sns=read_delimited(file='KEGS_SN.csv',nskip=0,delimiter=',',/noprompt)


if (campaign eq 1) then k2datafile='GO1074_Olling.txt'
if (campaign eq 3) then k2datafile='GO3048_Olling.txt'
if (campaign eq 5) then k2datafile='GO5096_Olling.txt'
if (campaign eq 6) then k2datafile='GO6077_Shaya.txt'
if (campaign eq 8) then k2datafile='GO8070_Shaya.txt'
if (campaign eq 10) then k2datafile='GO10070_Shaya.txt'
if (campaign eq 12) then k2datafile='GO12116_Rest.txt'
if (campaign eq 14) then k2datafile='GO14079_Rest.txt'
if (campaign eq 14 and nearby EQ 'N') then k2datafile='GO14078_Garnavich.txt'
;if (campaign eq 16) then k2datafile='G16tmp.txt'
if (campaign eq 16) then k2datafile='GO16079_Rest.txt'
if (campaign eq 17) then k2datafile='GO17.csv'
print,'campaign: ',campaign
print,'apsize: ',apsize
print,'bin: ',bin
print,'npca: ',npca
;print,'kid: ',kid
print,'write: ',write
print,'oneshot: ',oneshot
scamp = strtrim(string(campaign),2)
scampaign = 'Campaign'+scamp+nearby
datasavefile = scampaign+'/k2data.sav'
; First see if k2data is in saveset
ftest = file_test(datasavefile)
if ftest then restore, datasavefile 
; If no saveset, then read it from .txt file and then save it
if ~ftest then k2data = read_delimited(file=k2datafile,nskip=0,delimiter=',',/noprompts)
if ~ftest then save,k2data,file=datasavefile 
;whkid=where(k2data.k2_id eq kid)

; Restore rawphots
sbin = strtrim(string(bin),2)
if bin eq 1 then sbin = '0'
ap = apsize
if apsize eq 0 then mask = mymask()
if apsize eq 0 then ap = 4
sap = string(ap,format='(I1)')
photfile = scampaign+'/rawphots_c'+scamp+'_bin'+sbin+'_ap'+sap+'.sav'
filetest = file_search(photfile,count=count)
;;;;; WARNING, this is commented out temporarily
;if count ne 0 then print,'Restoring ',photfile
;if count ne 0 then restore,photfile
;if count ne 0 then rawphots = rawphots_m

;ra = k2data.ra
;dec= k2data.dec
;print,ra[whkid],dec[whkid]
; Commonly used commands

ccds = [1,84]
quicklook=1
; runk2,campaign,nearby,k2data,npca,ccds=ccds,write=write,apsize=apsize,centroids=centroids,oneshot=oneshot,bin=bin,rawstore=rawstore,quicklook=quicklook

;phot=run_phot(campaign,nearby,npca,apsize=apsize,k2data=k2data,kids=kids,pstep=1,centroids=centroids,bin=bin,t2=t2,t3=t3,tfinal=tfinal,t0=t0,quicklook=quicklook,yrange=yrange,pcavec=pcavec,write=write,minflux=minflux)

;raw = phot_k2targ(campaign,kid,sum,apsize=apsize,mask=mask,$
;		   	k2data=k2data,time=time,noplot=1,peak=peak0) 

; k2cube = read_k2targ(kid,campaign,time,quality,flux_bkg)

; plot_fluxtiles,kid,k2cube,time,campaign=campaign

; tv1,k2cube,lo,stretch,/animate,time=time,skipframes=10

; k2browse,campaign,k2data=k2data,ccds=ccds,apsize=apsize,mask=mask,yrange0=[.9,1.1],dollc=0
 

; Read pixel coordinates
;pixelss=read_delimited(file='Campaign16/pixels/k2-c16-pixel-coordinates.csv',nskip=4,delimiter=',')
;save,file='c16pixels.sav',pixelss
; Restore pixels for each EPIC number


; Get ra and dec of SN
;ra=15.*ten(ksns[kk].ra) 
;dec=ten(ksns[kk].dec) 
;pixels0=pixelss[where(pixelss.kepid eq kid,npixelss,/null)]
;Plot pixel locations
;p=scatterplot(pixels0.ra,pixels0.dec,symbol='+')
; Overplot SN location
;p=scatterplot(ra,dec,/overplot,symbol='x')
;

