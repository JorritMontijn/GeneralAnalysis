function vecYhat = gnmval(cellCoeffs,matXwithBias,cellFunctions)
	%gnmval Calculates predicted values vecYhat given fitted model coefficients
	%   vecYhat = gnmval(cellCoeffs,matXwithBias,cellFunctions);
	
	%% run
	%transform cell to linear coeffs
	[vecLinCoeffs,vecLinCoeffFunctions] = gnmcell2lin(cellCoeffs);
	%get prediction
	vecYhat = gnmlinfunc(vecLinCoeffs,matXwithBias,cellFunctions,vecLinCoeffFunctions);
end

