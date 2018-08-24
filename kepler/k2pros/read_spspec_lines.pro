spspec='SDSS/spSpec-53683-2282-200.fit'
f=read_fitswhole(spspec)
lines=read_delimited(file='sdss_lines.csv',nskip=0,delimiter=',',/noprompt)
table=f._1.data 
nlines=44
for i=0,nlines-1 do hash['Flux_'+lines[i].name+
     
