PRO mycurvefit, XY, A, F, PDER
; Z = A0 + A1 X + A2 Y + A3 X^2 + A4 Y^2 + A5 X Y
 X = XY[*,0]
 Y = XY[*,1]
 F = A[0] + A[1]*X + A[2]*Y + A[3]*X^2 + A[4]*Y^2 + A[5]*X*Y  $
		 + A[6]*X^3 + A[7]*Y^3 + A[8]*X^2*Y + A[9]*X*Y^2
 PDER = [[replicate(1.,n_elements(x))], [X], [Y], [X^2], [Y^2], [X*Y],$
	 [X^3], [Y^3],[X^2*Y],[X*Y^2]]
; PDER = [[replicate(1.,n_elements(x))], [X], [Y]]
RETURN
END
