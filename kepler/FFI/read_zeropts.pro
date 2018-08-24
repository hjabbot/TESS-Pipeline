function read_zeroPts
n_ffis = 41
nch = 84
zeroPts = dblarr(n_ffis,nch+1)
openr,13,"zeroPts.txt"
row=dblarr(nch+1)
dummy= ''
for i = 0, n_ffis-1 do begin
	readf,13,ii,dummy
	reads,dummy,row
	zeroPts[i,*] = row
endfor
close,13
return,zeroPts
end

