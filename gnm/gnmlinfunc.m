function vecYhat = gnmlinfunc(vecLinCoeffs,matX)
	%gnmlinfunc Wrapper for lsqcurvefit()
	%   vecYhat = gnmlinfunc(vecLinCoeffs,matX);
	%
	%vecYhat is summed contribution of all predictors into [n x 1] vector,
	%where n is the number of observations
	
	%% get globals
	global gCellLinkFunctions;
	global gVecLinCoeffFunctions;
	
	%% run
	vecYhat = zeros(size(matX,1),1);
	for intPred=1:size(matX,2)
		%get arguments
		vecArgs = find(gVecLinCoeffFunctions==intPred);
		%check if constant
		if strcmpi(gCellLinkFunctions{intPred},'constant')
			vecYhat = vecYhat + vecLinCoeffs(vecArgs);
		else
			%build code string
			strArgs = strcat('vecLinCoeffs([',num2str(vecArgs),'])');
			strEval = strcat(gCellLinkFunctions{intPred},'(matX(:,',num2str(intPred),'),',strArgs,')');
			vecYhat = vecYhat + eval(strEval);
		end
	end
end

