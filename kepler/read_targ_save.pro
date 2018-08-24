pro read_targ,gotablearr,quarters,skygroups,apsize,phothash=phothash,ps=ps,pdf=pdf,sharpc=sharpc,asymc=asymc,kid=kid,noplot=noplot
if keyword_set(phothash) then print,phothash
close = 0
if (size(gotablearr,/type) EQ 0) THEN BEGIN
	mastxmlfiles = ['/home/eshaya/Documents/Kepler/MAST_GO20058.xml', $
                 '/home/eshaya/Documents/Kepler/MAST_GO30032.xml', $
                 '/home/eshaya/Documents/Kepler/MAST_GO40057.xml' ]
	;; Read GO table for 1 proposal year
	table0 = read_votable8(mastxmlfiles[0])
	table1 = read_votable8(mastxmlfiles[1])
	table2 = read_votable8(mastxmlfiles[2]) 
	gotablearr = list(table0,table1,table2)
endif

print,'read_targ: Starting quarters ',quarters[0],' to ',quarters[1]
for q = quarters[0],quarters[1] do begin
	if (q ge 6 and q le 9) then year = 0 
	if (q ge 10 and q le 13) then year = 1 
	if (q ge 14 and q le 17) then year = 2 

	sg1=strtrim(string(skygroups[0]),2)
	sg2=strtrim(string(skygroups[1]),2)
	sq1=strtrim(string(quarters[0]),2)
	sq2=strtrim(string(quarters[1]),2)
	sap=strtrim(string(apsize),2)

	dir = string('../Q',q,format='(a4,I02)')
	cd, dir
        for g = skygroups[0],skygroups[1] do begin
		;print,'read_targ: Skygroup: ', g
		;print,'read_targ: Quarter = ',q
		if (g eq skygroups[1]) then close = 1
        	apphot = photaquarter(gotablearr[year],q,g,apsize,phothash=phothash,pdf=pdf,ps=ps,$
				asymc=asymc,sharpc=sharpc,kid=kid,noplot=noplot)
	endfor
	if (pdf eq 1) then begin
		squarter = strtrim(string(i),1)
		sap = strtrim(string(apsize),1)
		graphic=plot(/overplot,[1,1],[1,1],linestyle='none',axis_style=0)
		if file_search('graph') eq !null then file_mkdir,'graph' 
		graphic.save,'graphs/q'+squarter+'a'+sap+'.pdf',/append,/close
	endif

endfor

if keyword_set(phothash) then begin
   openw,/get_lun,unit,'../phothash_q'+sq1+'q'+sq2+'g'+sg1+'g'+sg2+'a'+sap+'.xml'
   phothash_write,phothash,unit=unit
   free_lun,unit
endif
goto,ending


wset=0 
kid=8480662
t9 = phothash( 9,27,kid,apsize,'time')
 t10=phothash(10,27,kid,apsize,'time')
 t11=phothash(11,27,kid,apsize,'time')
 t12=phothash(12,27,kid,apsize,'time')
 ksn01Q9=[phothash(9,27,kid,apsize,'phot')]                               
 ksn01Q9B=[phothash(9,27,kid,apsize,'bkgnd')]
 ksn01Q10=[phothash(10,27,kid,apsize,'phot')]
 ksn01Q10B=[phothash(10,27,kid,apsize,'bkgnd')]
 ksn01Q11=[phothash(11,27,kid,apsize,'phot')]
 ksn01Q11B=[phothash(11,27,kid,apsize,'bkgnd')]
 ksn01Q12=[phothash(12,27,kid,apsize,'phot')]
 ksn01Q12B=[phothash(12,27,kid,apsize,'bkgnd')]
k9= mean(ksn01Q10[0:10],/nan)/mean(ksn01Q9[-11:-1],/nan)
k11=mean(ksn01Q10[-11:-1],/nan)/mean(ksn01Q11[0:10],/nan)
k12=k11*mean(ksn01Q11[-11:-1],/nan)/mean(ksn01Q12[0:10],/nan)
 ksn01=[ksn01Q9*k9,ksn01Q10,ksn01Q11*k11,ksn01Q12*k12]
 ksn01b=[ksn01Q9b*k9,ksn01Q10b,ksn01Q11b*k11,ksn01Q12b*k12]
 timeksn01 =[t9,t10,t11,t12]
; plot,timeksn01 ,ksn01,yrange=[6400,7300],psym=3
; oplot,timeksn01 ,ksn01b+6500,psym=3,color=!clr.red
; oplot,timeksn01 ,ksn01-ksn01b,psym=3

sen= (1d0+1.*(dindgen(15620)-15620/2)/15620d2)      
print,minmax(sen)
graph = plot(timeksn01 ,ksn01*sen,yrange=[6400,7300],symbol='dot',linestyle='none')
graph =  plot(timeksn01 ,smooth(ksn01*sen,24,/nan,/edge_mirror,missing=!values.d_nan),color=!color.red,/overplot)              
graph.save,'ksn01.eps'
; plot,[t9,t10,t11,t12],[ksn01Q9*k9,ksn01Q10,ksn01Q11*k11,ksn01Q12*k12]* $
; (1d0+2.*(dindgen(15620)-15620/2)/15620d2),yrange=[6200,7200],psym=3 

wset=1
kid=8149081
 t9 = phothash( 9,27,kid,apsize,'time')
 t10=phothash(10,27,kid,apsize,'time')
 t11=phothash(11,27,kid,apsize,'time')
 t12=phothash(12,27,kid,apsize,'time')
p62Q9=phothash(09,27,kid,apsize,'phot')  
p62Q10=phothash(10,27,kid,apsize,'phot')  
p62Q11=phothash(11,27,kid,apsize,'phot')  
p62Q12=phothash(12,27,kid,apsize,'phot')
k10=1.
k11=1.117
k12=1.085
 plot,[t10,t11,t12],[p62Q10,p62Q11*k11,p62Q12*k12],yrange=[4900,5600],psym=3

wset=1
kid=8609952
t9 = phothash( 9,27,kid,apsize,'time')
 t10=phothash(10,27,kid,apsize,'time')
 t11=phothash(11,27,kid,apsize,'time')
 t12=phothash(12,27,kid,apsize,'time')
p52Q9=phothash(09,27,kid,apsize,'phot')  
p52Q10=phothash(10,27,kid,apsize,'phot')  
p52Q11=phothash(11,27,kid,apsize,'phot')  
p52Q12=phothash(12,27,kid,apsize,'phot')
k9=.946 & k10=1.0 & k11=.997 &k12=.984
 plot,[t9,t10,t11,t12],[p52Q9*k9,p52Q10,p52Q11*k11,p52Q12*k12],yrange=[4500,4700],psym=3

wset=2
kid=8674719
t9 = phothash( 9,27,kid,apsize,'time')
 t10=phothasphothash(10,27,kid,apsize,'time')
 t11=phothash(11,27,kid,apsize,'time')
 t12=phothash(12,27,kid,apsize,'time')
p19Q9=phothash(09,27,kid,apsize,'phot')  
p19Q10=phothash(10,27,kid,apsize,'phot')  
p19Q11=phothash(11,27,kid,apsize,'phot')  
p19Q12=phothash(12,27,kid,apsize,'phot')
k9=.92 & k10=1.0 & k11=.975 &k12=1.03
 plot,[t9,t10,t11,t12],[p19Q9*k9,p19Q10,p19Q11*k11,p19Q12*k12],yrange=[2000,2500],psym=3

 wset=1 
kid=11068393
skygroup=12

kid=3111451
quarters=[10,16]
skygroup=81
apsize=5
slope=2.
lc=plotlc(kid,phothash,quarters,skygroup,apsize,slope,title=title)

 t10=phothash(10,skygroup,kid,apsize,'time')
 t11=phothash(11,skygroup,kid,apsize,'time')
 t12=phothash(12,skygroup,kid,apsize,'time')
t13 = phothash(13,skygroup,kid,apsize,'time')
t14 = phothash(14,skygroup,kid,apsize,'time')
t15 = phothash(15,skygroup,kid,apsize,'time')
 ksn05Q10=[phothash(10,skygroup,kid,apsize,'phot')]
 ksn05Q10B=[phothash(10,skygroup,kid,apsize,'bkgnd')]
 ksn05Q11=[phothash(11,skygroup,kid,apsize,'phot')]
 ksn05Q11B=[phothash(11,skygroup,kid,apsize,'bkgnd')]
 ksn05Q12=[phothash(12,skygroup,kid,apsize,'phot')]
 ksn05Q12B=[phothash(12,skygroup,kid,apsize,'bkgnd')]
 ksn05Q13=[phothash(13,skygroup,kid,apsize,'phot')]                               
 ksn05Q13B=[phothash(13,skygroup,kid,apsize,'bkgnd')]
 ksn05Q14=[phothash(14,skygroup,kid,apsize,'phot')]                               
 ksn05Q14B=[phothash(14,skygroup,kid,apsize,'bkgnd')]
 ksn05Q15=[phothash(15,skygroup,kid,apsize,'phot')]                               
 ksn05Q15B=[phothash(15,skygroup,kid,apsize,'bkgnd')]
k11=mean(ksn05Q10[-11:-1],/nan)/mean(ksn05Q11[0:10],/nan)
k12=k11*mean(ksn05Q11[-11:-1],/nan)/mean(ksn05Q12[0:10],/nan)
k13= k12*mean(ksn05Q12[-11:-1],/nan)/mean(ksn05Q13[0:10],/nan)
k14= k13*mean(ksn05Q13[-1],/nan)/mean(ksn05Q14[0:30],/nan)
k15= k14*mean(ksn05Q14[-1],/nan)/mean(ksn05Q15[0:30],/nan)
k14 = k14 -.002
print,'k11,k12,k13: ',k11,k12,k13,k14
 ksn05=[ksn05Q10,ksn05Q11*k11,ksn05Q12*k12,ksn05q13*k13,ksn05q14*k14,ksn05q15*k15]
 ksn05b=[ksn05Q10b,ksn05Q11b*k11,ksn05Q12b*k12,ksn05q13b*k13,ksn05q14b*k14,ksn05q15b*k15]
 times =[t10,t11,t12,t13,t14,t15]
 nt = n_elements(times)
sen= (1d0+2.7*(dindgen(nt)-nt/2)/nt/100.)      
print,minmax(sen)
graph = plot(times ,ksn05*sen,yrange=[min(ksn05*sen)*.95,max(ksn05*sen)*1.05],symbol='dot',linestyle='none',title='KSN2011b',xtitle='Days',ytitle='Kepler Counts')
graph =  plot(times ,smooth(ksn05*sen,12,/nan,/edge_mirror,missing=!values.d_nan),color=!color.red,/overplot)              
;graph =  plot(timeksn05 ,smooth(ksn05b*sen+min(ksn05),24,/nan,/edge_mirror,missing=!values.d_nan),color=!color.blue,/overplot)    
graph.save,'ksn2011b.eps'
ending:
return
end
