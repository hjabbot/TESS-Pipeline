pro agncandidates,n,kid,quarters,vlim,nanq,apsize,bestq
nmax = 18
if n gt nmax then begin
	print,' n greater than maximum value'
	return
endif
 print,'Previous kid = ',kid
 kids=[10645722,5686822,11716536,7986325,6751969,7691427,12553112,11768473,2142191,$
	 12556836,11808151,5683305,8024526,5511084,6714622,4148802,10402746,9509125,8884097]
 kid=kids[n]
 case n of 
	 0: vlim=[1,2]  ;10645722
	 1: vlim=[1,3]  ;5686822
	 2: vlim=[1,4]  ;11716536
	 3: vlim=[1,6]  ;7986325
	 4: vlim=[1,4]  ;6751969
	 5: vlim=[1,6]  ;7691427
	 6: vlim=[1,4]  ;12553112
	 7: vlim=[1,4]  ;11768473
	 8: vlim=[1,5]  ;2142191
	 9: vlim=[1,5]  ;12556836
	 10: vlim=[1,6] ;11808151
	 11: vlim=[1,4] ;5683305
	 12: vlim=[1,6] ;8024526
	 13: vlim=[1,6] ;5511084
	 14: vlim=[1,6] ;6714622
	 15: vlim=[1,4] ;4148802
	 16: vlim=[1,3] ;10402746
	 17: vlim=[1,4] ;9509125
	 18: vlim=[1,4] ;8884097
 	else: vlim=[1,4]
 endcase
 case n of 
	 0:  quarters=[10,16];10645722
	 1:  quarters=[14,16];5686822
	 2:  quarters=[6,9]  ;11716536
	 3:  quarters=[10,13];7986325
	 4:  quarters=[10,13];6751969
	 5:  quarters=[11,13];7691427
	 6:  quarters=[11,13];12553112
	 7:  quarters=[10,16];11768473
	 8:  quarters=[10,13];2142191
	 9:  quarters=[10,16];12556836
	 10: quarters=[10,11];11808151
	 11: quarters=[14,16];5683305
	 12: quarters=[8,16] ;8024526
	 13: quarters=[14,16];5511084
	 14: quarters=[10,16];6714622
	 15: quarters=[6,9]  ;4148802
	 16: quarters=[10,16];10402746
	 17: quarters=[10,13];9509125
	 18: quarters=[11,13];8884097
  endcase
  case n of 
 	2:  nanq=[7]
 	3:  nanq=[12]
 	5:  nanq=[12]
 	6:  nanq=[12]
 	12: nanq=[11,15]
 	16: nanq=[11,13,15]
	17: nanq=[12]
 	else: nanq=0
 endcase
 case n of 
	 0:  apsize=5  ;10645722
	 1:  apsize=3  ;5686822
	 2:  apsize=3  ;11716536
	 3:  apsize=5  ;7986325
	 4:  apsize=5  ;6751969
	 5:  apsize=5  ;7691427
	 6:  apsize=3  ;12553112
	 7:  apsize=3  ;11768473
	 8:  apsize=3  ;2142191
	 9:  apsize=3  ;12556836
	 10: apsize=3  ;11808151
	 11: apsize=3  ;5683305
	 12: apsize=5  ;8024526
	 13: apsize=3  ;5511084
	 14: apsize=5  ;6714622
	 15: apsize=3  ;4148802
	 16: apsize=3  ;10402746
	 17: apsize=3  ;9509125
	 18: apsize=3  ;8884097
  endcase
 case n of 
  0: bestq=14
  1: bestq=15
  2: bestq=8
  3: bestq=13
  4: bestq=10
  5: bestq=13
  6: bestq=11
  7: bestq=13
  8: bestq=13
  9: bestq=13
  10: bestq=10
  11: bestq=15
  12: bestq=13
  13: bestq=16
  14: bestq=14
  15: bestq=8
  16: bestq=12
  17: bestq=11
  18: bestq=13
  else: bestq=0
  endcase

print,'KID = ',kid
print,'n = ',n
print,'apsize =',apsize
print,'vlim = ',vlim
print,'nanq = ',nanq
print,'quarters = ',quarters
print,'bestq = ',bestq
 return
 end

