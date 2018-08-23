function chan2mod,x,flag
	if (flag eq 1) then begin
		chan=x
		if (chan le 12) then c1=2
		if (chan ge 13 and chan le 72) then c1=3
		if (chan ge 73) then c1=4
		if (chan gt 84) then begin
			print,'chan2mod: No such channel: ',chan 
			return,-1
		endif

		module = (chan-1)/4+ c1 +((chan-1) mod 4 + 1)/10.
		return, module
	endif
	if (flag eq 2) then begin
		module = x
		if (module lt 5) then c1=2
		if (module gt 5 and module lt 21) then c1=3
		if (module gt 21) then c1=4
		if (module eq 5 || module eq 21 || module gt 24.4) then begin
			print,'chan2mod: No such module: ',module 
			return,-1
		endif
		chan=fix(module-c1)*4+ fix((module - fix(module))*10.0001)
		return,chan
	endif
	if (flag ne 1 || flag ne 2) then begin
 		print,'chan2mod: flag =1 for channel to module'
		print, ' flag = 2 for module to channel'
	endif
end
