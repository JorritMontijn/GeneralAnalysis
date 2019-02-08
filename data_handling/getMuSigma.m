function [vecMu,matSigma] = getMuSigma(vecParams,intDims)
	%UNTITLED6 Summary of this function goes here
	%   Detailed explanation goes here
	
	vecMu = vecParams(1:intDims);
	
	if numel(vecParams) == 2*intDims %only diagonal values supplied
		matSigma = diag(vecParams((intDims+1):end));
	else %assign values to lower left triangle and diagonal
		matSigma = zeros(intDims,intDims);
		intR = 0;
		intC = 1;
		for intP=(intDims+1):length(vecParams)
			intR = intR + 1;
			matSigma(intR,intC) = vecParams(intP);
			if intR == intDims
				intR = intC;
				intC = intC + 1;
			end
		end
		matSigma = tril(matSigma)+tril(matSigma,-1)';%copy lower left to upper right
	end
end

