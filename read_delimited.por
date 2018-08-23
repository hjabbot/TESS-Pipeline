function read_delimited,file,delimiter,skip,nrows,colvector,tagnames,vals
; Read delimited data file
; Here is an example

; file name
; file = 'datafile.dat'

; delimiter used in the data file
; delimiter = ' '

; number of header rows to skip
; skip = 4

; number of rows of data
; nrows = 133

; Which columns to use
; colvector = [0, 1, 2, 11, 15]

; tagnames to use in output structure
; tagnames = ['id','q0_id','chisq','mag','seq']

; Examples of datatypes to use for each column
; vals = '0L, "abc", 1., 1d0, 1'

; output=read_delimited(file,delimiter,skip,nrows,colvector,tagnames,vals)

openr,/get_lun,rdunit,file
dum=''
; Skip and then last one is header
for i=0,skip-1 do readf,rdunit,dum
r1 = execute('output = create_struct(tagnames,'+vals+')')
output = replicate(output,nrows)
for i = 0,nrows-1 do begin
	readf,rdunit,dum
	input = strsplit(dum,' ',/extract)
	for j=0,n_elements(colvector)-1 do output[i].(j) = input[colvector[j]]
endfor
return,output
end
