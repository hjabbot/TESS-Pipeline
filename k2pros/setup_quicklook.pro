pro setup_quicklook,campaign,sns,centroids

; Working with quicklook
quicklook=1
scamp = strtrim(string(campaign),2)
scampaign = 'Campaign'+scamp
tpfdir = scampaign+'/tpf/'
k2datafile = 'GO'+strtrim(string(campaign),2)+'.csv'
if ~file_test(k2datafile) then begin
    openw,/get_lun,wunit,k2datafile
    cd,tpfdir
    files = file_search('*.fits.gz')
    printf,wunit,'k2_id,channel'
    printf,wunit,'long,float'
    foreach file, files do begin
    	d = read_fitswhole(file,/compress,/nonumbers)
    	ccd = strtrim(sxpar(d.header,'CHANNEL'),2)
    	kid = strtrim(sxpar(d.header,'KEPLERID'),2)
    	printf,wunit,kid+','+ccd
    endforeach
    cd,'../..'
    close,wunit
    free_lun,wunit
endif
k2data = read_delimited(file=k2datafile,nskip=0,delimiter=',',/noprompts)
datasavefile = scampaign+'/k2data.sav'
;;;save,k2data,file=datasavefile 

;;;centroids=get_centroids([1,84],k2data,campaign,/noposcorr)
;;;cenfile = scampaign +'/centroids.sav'
;;;SAVE,centroids,filename=cenfile

; get sns for just this campaign
snskk = sns[where(sns.campaign eq 'C'+scamp)]
; Sort on z
kkz = snskk.z
s = sort(kkz)
snss=snskk[s]
zs=kkz[s]

; Remove  cases with less than 5 galaxies on a channel
nsn = n_elements(kkz)
ccd2 = []
snss2 =  []
foreach sn, snss do begin
	ccd = k2data[where(sn.kid eq k2data.k2_id)].channel
	wh = where(k2data.channel eq ccd,ncnt)
	if ncnt gt 5 then begin
		ccd2 = [ccd2,ccd]
		snss2 = [snss2,sn]
	endif
endforeach

srt = uniq(ccd2,sort(ccd2))
ccdsrt = ccd2[srt]   
snsrt = snss2[srt]
nearby = ''
apsize=5
oneshot=0

write = 0
rawstore=0 
;npca = 0 & foreach ccd,ccdsrt do $
;	runk2,campaign,nearby,k2data,npca,ccds=[ccd,ccd],write=write,apsize=apsize,centroids=centroids,quicklook=quicklook,rawstore=rawstore,oneshot=oneshot,/noprompts

;rawstore = 1 & for npca = 2,4 do $
;    foreach ccd,ccdsrt do  $
;	runk2,campaign,nearby,k2data,npca,ccds=[ccd,ccd],write=write,$
;	apsize=apsize,centroids=centroids,quicklook=quicklook,$
;	rawstore=rawstore,oneshot=oneshot,/noprompts

npca=5 & write=1 & rawstore = 1
for i = 0,1 do $
foreach ccd,ccdsrt do  $
	runk2,campaign,nearby,k2data,npca,ccds=[ccd,ccd],write=write,apsize=apsize,centroids=centroids,quicklook=quicklook,rawstore=rawstore,oneshot=oneshot,/noprompts

return
end
