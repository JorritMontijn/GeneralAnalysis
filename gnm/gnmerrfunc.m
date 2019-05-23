function dblError = gnmerrfunc(vecLinCoeffs)
	%gnmerrfunc Wrapper for fminsearch()
	%   dblError = gnmerrfunc(vecLinCoeffs);
	%
	%Error is scalar, and calculated as sum of squares
	
	%% get globals
	global gMatX;
	global gVecY;
	matX = gMatX;
	vecY = gVecY;
	
	%% get predicted values
	vecPredY = gnmlinfunc(vecLinCoeffs,matX);
	
	%% calculate error
	%least squares
	dblError = sum((vecY - vecPredY).^2);
	
end

