
function kidsinquarter,quarter,skygroup,phothash
kidl = list()
kidl = kidl + phothash[quarter,skygroup].keys()
kida = kidl.ToArray()
kids = kida[uniq(kida, sort(kida))]
return,kids
end
