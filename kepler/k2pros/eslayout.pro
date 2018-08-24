function eslayout,omargin,nx,ny
; omargin is [left,right,top,bottom] margins and go 0. to 0.5
; nx is number of plots horizontally
; ny is number of plots vertically
; output is 4 x nplots array [X0,Y0,X1,Y1,plot_num]
xroom = 1.-omargin[0]-omargin[1]
yroom = 1.-omargin[2]-omargin[3]
xstep = xroom/nx
ystep = yroom/ny
xstart = omargin[0]
ystart = 1.-omargin[2]
outpos = fltarr(4,nx*ny)
plot_num = 0
for j = 0,ny-1 do begin
	for i = 0,nx-1 do begin
		outpos[0,plot_num] = xstart + xstep*i
		outpos[1,plot_num] = ystart - ystep*(j+1)
		outpos[2,plot_num] = xstart + xstep*(i+1)
		outpos[3,plot_num] = ystart - ystep*j
		plot_num++
	endfor
endfor
return,outpos
end
