pro run_fits,campaign,ccds
scamp = strtrim(string(campaign),2)
scampaign = 'Campaign'+scamp
datasavefile = scampaign+'/k2data.sav'
CASE campaign of
	1: k2datafile='GO1074_Olling.txt'
	3: k2datafile='GO3048_Olling.txt'
	5: k2datafile='GO5096_Olling.txt'
	6: k2datafile='GO6077_Shaya.txt'
	8: k2datafile='GO8070_Shaya.txt'
	10: k2datafile='GO10070_Shaya.txt'
	12: k2datafile='GO12116_Rest.txt'
	14: k2datafile='GO14079_Rest.txt'
	ELSE:
ENDCASE

k2data = read_delimited(file=k2datafile,nskip=3,delimiter=',',noprompts=1)

apsize=5
nopca=1
write=2
oneshot=1
noplot=1
;ccds=[1,84]
;
;

rawstore=0
npca=1
runk2,campaign,k2data,npca,ccds=ccds,apsize=apsize,centroids=centroids,$
      write=write,oneshot=oneshot,rawstore=rawstore,tfinal=tfinal,$
      buffer=buffer,noplot=noplot,delt0=delt0,just_pca=just_pca,nopca=nopca,noprompts=1

rawstore=1
npca=2
runk2,campaign,k2data,npca,ccds=ccds,apsize=apsize,centroids=centroids,$
      write=write,oneshot=oneshot,rawstore=rawstore,tfinal=tfinal,$
      buffer=buffer,noplot=noplot,delt0=delt0,just_pca=just_pca,nopca=nopca,noprompts=1

npca=3
runk2,campaign,k2data,npca,ccds=ccds,apsize=apsize,centroids=centroids,$
      write=write,oneshot=oneshot,rawstore=rawstore,tfinal=tfinal,$
      buffer=buffer,noplot=noplot,delt0=delt0,just_pca=just_pca,nopca=nopca,noprompts=1

npca=4
runk2,campaign,k2data,npca,ccds=ccds,apsize=apsize,centroids=centroids,$
      write=write,oneshot=oneshot,rawstore=rawstore,tfinal=tfinal,$
      buffer=buffer,noplot=noplot,delt0=delt0,just_pca=just_pca,nopca=nopca,noprompts=1

npca=5
noplot=0
runk2,campaign,k2data,npca,ccds=ccds,apsize=apsize,centroids=centroids,$
      write=write,oneshot=oneshot,rawstore=rawstore,tfinal=tfinal,$
      buffer=buffer,noplot=noplot,delt0=delt0,just_pca=just_pca,nopca=nopca,noprompts=1
end
