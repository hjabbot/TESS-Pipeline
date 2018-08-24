function kepler_mag,counts,ffi28
; Set ffi28 to 1 if on FFI 1 - 28

if ~keyword_set(ffi28) then ffi28 = 0
if (ffi28 ne 0) then counts = counts/1625.39

zeropt = 25.40
return,zeropt - 2.5*ALOG10(counts)
end
