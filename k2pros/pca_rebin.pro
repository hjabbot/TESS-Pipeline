function pca_rebin,pca,newsz
sz = size(pca,/dim)
npca = sz[0]
pca2 = fltarr(sz[0],newsz)
for i = 0, npca-1 do pca2[i,*] = congrid(reform(pca[i,*]),newsz)
return,pca2
end
