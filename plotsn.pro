pro read_targ,gotablearr,quarters,skygroup,apsize,phothash=phothash,ps=ps
if keyword_set(phothash) then print,phothash
quarter=6  & cd,'../Q06' 
apphot = photaquarter(gotablearr[0],quarter,skygroup,apsize,phothash=phothash,ps=ps)
quarter=7  & cd,'../Q07' 
apphot = photaquarter(gotablearr[0],quarter,skygroup,apsize,phothash=phothash,ps=ps)
quarter=8  & cd,'../Q08' 
apphot = photaquarter(gotablearr[0],quarter,skygroup,apsize,phothash=phothash,ps=ps)
quarter=9  & cd,'../Q09' 
apphot = photaquarter(gotablearr[0],quarter,skygroup,apsize,phothash=phothash,ps=ps)
quarter=10  & cd,'../Q10' 
apphot = photaquarter(gotablearr[1],quarter,skygroup,apsize,phothash=phothash,ps=ps)
quarter=11  & cd,'../Q11' 
apphot = photaquarter(gotablearr[1],quarter,skygroup,apsize,phothash=phothash,ps=ps)
quarter=12  & cd,'../Q12' 
apphot = photaquarter(gotablearr[1],quarter,skygroup,apsize,phothash=phothash,ps=ps)
quarter=13  & cd,'../Q13' 
apphot = photaquarter(gotablearr[1],quarter,skygroup,apsize,phothash=phothash,ps=ps)
quarter=14  & cd,'../Q14' 
apphot = photaquarter(gotablearr[2],quarter,skygroup,apsize,phothash=phothash,ps=ps)
quarter=15  & cd,'../Q15' 
apphot = photaquarter(gotablearr[2],quarter,skygroup,apsize,phothash=phothash,ps=ps)
quarter=16  & cd,'../Q16' 
apphot = photaquarter(gotablearr[2],quarter,skygroup,apsize,phothash=phothash,ps=ps)
quarter=17  & cd,'../Q17' 
apphot = photaquarter(gotablearr[2],quarter,skygroup,apsize,phothash=phothash,ps=ps)

if keyword_set(phothash) then begin
   openw,/get_lun,unit,'phothash_q6q17_g'+strtrim(string(skygroup),2)+'a'+strtrim(string(apsize),2)
   phothash_write,phothash,unit=unit
   free_lun,unit
endif
return
end


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
print,'k9,k11,k12: ',k9,k11,k12
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
title='KSN2011b'
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

