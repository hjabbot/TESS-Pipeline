doffi_0_2 = [10,23,34]
doffi_3_1 = [5,18,29]
doffi_1_2 = [11,24,35]
doffi = doffi_0_2 & overplot = 0 & !color=0
.run plotxc
doffi= doffi_1_2 & overplot = 1 & !color=!clr.red
.run plotxc
doffi = doffi_3_1 & overplot = 1 & !color=!clr.blue
.run plotxc
