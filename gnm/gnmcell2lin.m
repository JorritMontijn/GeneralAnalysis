function [vecLinCoeffs,vecLinCoeffFunctions] = gnmcell2lin(cellCoeffs)
	%gnmcell2lin Transform cell-based coefficients to linear vectors
	%   [vecLinCoeffs,vecLinCoeffFunctions] = gnmcell2lin(cellCoeffs)
	vecLinCoeffs = [];
	vecLinCoeffFunctions = [];
	for intPred = 1:numel(cellCoeffs)
		vecCoeffs = cellCoeffs{1,intPred};
		vecIdx = (numel(vecLinCoeffs)+1):(numel(vecLinCoeffs) + numel(vecCoeffs));
		vecLinCoeffs(vecIdx) = vecCoeffs; %#ok<AGROW>
		vecLinCoeffFunctions(vecIdx) = intPred; %#ok<AGROW>
	end
end

