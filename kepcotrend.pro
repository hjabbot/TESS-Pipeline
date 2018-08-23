;+
; NAME:
;   kepcotrend
;     
; PURPOSE:
;   Cotrends Kepler lightcurves using the provided cotrend basis
;     vectors in a way analogous to the kepcotrend python routine provided at 
;     http://keplergo.arc.nasa.gov/PyKE.shtml. 
;
;   The basis vector files required for cotrending are available here:
;     http://archive.stsci.edu/kepler/cbv.html.
;
;   Note that this routine doesn't provide for all the functionality that the
;     Kepler team's kepcotrend.py routine does. In particular, this routine
;     won't work for short-cadence data.
;
;   The technique used here is discussed at length in 
;     _Numerical Recipes in C_, 2nd ed., ch. 15. The CBV array below seems to be
;     equivalent to the V array in NR.
;
; CALLING SEQUENCE:
;   cotrended_flux = kepcotrend(lcfile, bvfile, listbv, model=model)
;
; INPUTS:
;   lcfile -- long-cadence FITS file containing the data to be cotrended
;   bvfile -- CBV file
;   listbv -- array indicating which CBVs to use, starting at 0
;
; OUTPUT
;   Cotrended flux, with bad data values (NaNs) still included
;
; OPTIONAL OUTPUT:
;   model -- array containing the cotrending model used
;
; RESTRICTIONS:
;   This routine isn't very clever; it only cotrends the data.
;
; EXAMPLE:
;   lcfile = "kplr010666592-2009131105131_llc.fits"
;   cbvfile = "kplr2009131105131-q00-d14_lcbv.fits"
;   listbv = indgen(8)
;   cotrended_flux = kepcotrend(lcfile, cbvfile, listbv)
;   plot, indgen(n_elements(cotrended_flux)), cotrended_flux, psym=3, $
;     yr=[min(cotrended_flux), max(cotrended_flux)], ystyle=2 
;
; MODIFICATION HISTORY:
;   2012 Mar - Written by Brian Jackson (decaelus@gmail.com)
;   2012 Dec 14 - Check for empty cbvs added by Nikole Thom (nklewis@mit.edu)
;-
function kepcotrend, lcfile, bvfile, listbv, model=model

  ;Figure out which module and output to use
  res = readfits(lcfile, header, exten_no=0, /silent)
  module = sxpar(header, "MODULE")
  output = sxpar(header, "OUTPUT")
  ext_name = "MODOUT_"+strtrim(string(module), 2)+"_"+strtrim(string(output), 2)

  ;2012 Dec 14 -- Correction implemented by Nikole Lewis
  if (n_elements(all_cbvs) eq 1.0) then begin
    cotrend_lc=!Values.F_NAN
    print,"kepcotrend: CBVs empty!"
    return, cotrend_lc
  endif

  ;read in basis listbv from file
  all_cbvs = mrdfits(bvfile, ext_name, header, /silent)
  vecs = [[all_cbvs.vector_1], [all_cbvs.vector_2], [all_cbvs.vector_3], [all_cbvs.vector_4], [all_cbvs.vector_5], [all_cbvs.vector_6], [all_cbvs.vector_7], [all_cbvs.vector_8], [all_cbvs.vector_9], [all_cbvs.vector_10], [all_cbvs.vector_11], [all_cbvs.vector_12], [all_cbvs.vector_13], [all_cbvs.vector_14], [all_cbvs.vector_15], [all_cbvs.vector_16]]
  ;listbv to use
  CBV = double(vecs[*,listbv])

  ;Read in light curve
  res = mrdfits(lcfile, 1, header, /silent)
  lc = double(res.sap_flux)
  nan_model = lc

  ;This is the light curve that will have bad data removed
  cotrend_lc = lc

  ;Cut out bad data and infinities
  bad_data_ind = where(finite(cotrend_lc, /nan), complement=nind)

  ;Mask out bad data
  cotrend_lc = cotrend_lc[nind]
  CBV = CBV[nind,*]

  ;shift and normalize light curve
  ;Kepler's Data Characteristics Handbook (2011 Aug 17), p. 50 
  ;http://archive.stsci.edu/kepler/manuals/Data_Characteristics_Handbook_20110817.pdf 
  med_lc = median(cotrend_lc)
  cotrend_lc = (cotrend_lc-med_lc)/med_lc

  model = 0.

  ;This line mimics the code in kepcotrend.py.
  coeffs = matrix_multiply(invert(matrix_multiply(CBV, CBV, /atranspose)), $
                             matrix_multiply(CBV, cotrend_lc, /atranspose))
  coeffs = 0. - coeffs

  for i = 0, n_elements(listbv)-1 do begin
    model += coeffs[i]*(CBV[*,i]) 
  end;for i
  cotrend_lc += model

  ;scale back to the original and put the bad data back in
  nan_model[nind] = model
  model = nan_model

  cotrend_lc *= med_lc
  cotrend_lc += med_lc
  lc[nind] = cotrend_lc

  return, lc

end;pro
