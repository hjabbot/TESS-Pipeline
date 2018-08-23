retall
	if !version.os ne "Win32" then $
		dir = "/home/eshaya/Documents/Dropbox/Kepler Mission/" $
		else $
		dir = "C:\Users\eshaya\Dropbox/Kepler Mission/"

	if ~keyword_set(who) then who = 'olling'
	print," I am ",who
	if who eq 'richard' then $
	mastxmlfiles =  [dir+'GO10005_Carini.xml',$
		 	dir+'GO20051_Mushot.xml',$
			dir+'GO30028_Mushot.xml',$
			dir+'GO40041_Mushot.xml']
	if who eq 'brad' then $
	mastxmlfiles =  [dir+'GO10005_Carini.xml',$
		 	dir+'GO20050_Bower.xml',$
			dir+'GO30020_Garnavich.xml',$
			dir+'GO40046_Garnavich.xml']
	if who eq 'olling' then $
	mastxmlfiles =  [dir+'GO10005_Carini.xml',$
		         dir+'GO20058_Olling.xml',$
			 dir+'GO30032_Olling.xml',$
			 dir+'GO40057_Olling.xml']
	if who eq 'fanelli' then $
	mastxmlfiles =  [dir+'GO10005_Carini.xml',$
		 	 dir+'GO20050_Bower.xml',$
			 dir+'GO30011_Fanelli.xml',$
			 dir+'GO40037_Fanelli.xml']
		print,mastxmlfiles
	if ~isa(gotable0,'STRUCT') then $
		print,'Reading gotables'
	if ~isa(gotable0,'STRUCT') then $
		gotable0 = read_votable8(mastxmlfiles[0])
	if ~isa(gotable1,'STRUCT') then $
		gotable1 = read_votable8(mastxmlfiles[1])
	if ~isa(gotable2,'STRUCT') then $
		gotable2 = read_votable8(mastxmlfiles[2]) 
	if ~isa(gotable3,'STRUCT') then $
		gotable3 = read_votable8(mastxmlfiles[3]) 
	gotablearr = list(gotable0,gotable1,gotable2,gotable3)

ukids = []
for i=1,3 do ukids = [ukids,gotablearr[i].kepler_id]
ukids = ukids[uniq(ukids,sort(ukids))]
nkids = n_elements(ukids)

if who eq 'brad' then kid = 8094413
skygroup=skygroupof(gotablearr,kid)
apsize=5
skygroups=[skygroup,skygroup]
qs=quartersof(gotablearr,kid)
quarters = minmax(qs)
if qs EQ !NULL then print,'No data on kid ',kid
if qs EQ !NULL then stop
;quarters=[15,17]
cd,'~/Documents/Kepler/targ/Q10'
phothash=hash(6,hash(1))
for i = 2, 17 do phothash += hash(i)

noplot=2
;read_targ,gotablearr,quarters,skygroups,apsize,phothash=phothash,noplot=noplot,kid=kid
slope=0.0
stitch=1
asymc=0d0
llc=0
sharpc=0d0
nanq=0
norm=1
shiftsub=0
write=0
ps=1
;quarters=0
findsharp=0
;lc=plotlc(kid,phothash,quarters,skygroup,apsize,slope,stitch=stitch,title=title,ps=ps,norm=norm, bcon=bcon,asymc=asymc,sharpc=sharpc,graph=graph)
;kids=[10645722,5686822,11716536,7986325,6751969,7691427,12553112,11768473,2142191,$
;	 12556836,11808151,5683305,8024526,5511084,6714622,4148802,10402746,9509125,8884097]
;quarters=[6,7]
vlim=[1,4]
fast=1
shiftsub=0
tv=0
bcon=0
llc=1
skip=0
allforone,kid,apsize,gotablearr,phothash,quarters=quarters,write=write,llc=llc,$
  vlim=vlim,slope=slope,nanq=nanq,fast=fast,norm=norm,stitch=stitch,photst=photst,skip=skip




