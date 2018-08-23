pro ccd_centers,campaign
spawn,'python2.7 ~/Documents/idl/pro/Keplerpros/ccd_centers.py'
openr,10,'ccdCenters.txt'
openw,11,'ccdCenters_Camp'+strtrim(string(campaign),2)+'.txt'
for i = 2,22 do  for k = 0,3 do begin
	c1 = 0 & c2=0 & c3=0
	ra=0.0 & dec=0.0
	for j=0,3 do begin
       		readf,10,c10,c20,c30,ra0,dec0
       		c1 += c10 & c2 += c20 & c3 += c30
		ra += ra0 & dec += dec0
	endfor
	c1 = c1/4 & c2 = c2/4 & c3 = c3/4
	ra = ra/4 & dec = dec/4.
	printf,11,format='(3(i4,2x),2(f10.6,2x))',c1,c2,c3,ra,dec
endfor
close,/all
return
end
