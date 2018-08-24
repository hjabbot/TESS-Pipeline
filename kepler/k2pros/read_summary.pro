function read_summary,campaign,apsize,ccd
; This reads the summary statistics files for a ccd,
; returns a structure with mean,stdevs, and coefficients used for each galaxy
; It also prints out the mean and std dev of the 5 coefficients for this ccd.

file = 'Campaign'+strtrim(string(campaign),1)+ $
	'/stats/summarystats_'+strtrim(string(ccd),1)+$
	'_ap'+string(format='(I1)',apsize)+'.txt'
nrows = 0L
openr,/get_lun,runit,file
readf,runit,nrows
stats = {epic: 0L, mean: 1., stdv_raw:0d0, stdv_phot:0d0,stdv_sap:0d0,stdv_pdc:0d0,coeff: replicate(0d0,5)}
stats = replicate(stats,nrows)
dum=''
readf,runit,dum
readf,runit,stats
close,runit
free_lun,runit
mn = mean(stats.coeff,dim=2)
st = stddev(stats.coeff,dim=2)
print,'Coeff,  Mean,  Sigma'
forprint,indgen(5),mn,st

return,stats
end

