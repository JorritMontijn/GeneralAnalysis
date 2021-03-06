function vecYhat = gnmlinfunc(vecLinCoeffs,matX,cellFunctions,vecLinCoeffFunctions)
	%gnmlinfunc Wrapper for lsqcurvefit()
	%   vecYhat = gnmlinfunc(vecLinCoeffs,matX,cellFunctions,vecLinCoeffFunctions);
	%
	%vecYhat is summed contribution of all predictors into [n x 1] vector,
	%where n is the number of observations
	
	%% get globals
	if nargin < 3 || isempty(cellFunctions)
		global gCellFunctions;
		cellFunctions = gCellFunctions;
	end
	if nargin < 4 || isempty(vecLinCoeffFunctions)
		global gVecLinCoeffFunctions;
		vecLinCoeffFunctions = gVecLinCoeffFunctions;
	end
	
	%% run
	vecYhat = zeros(size(matX,1),1);
	for intPred=1:size(matX,2)
		%get arguments
		vecArgs = find(vecLinCoeffFunctions==intPred);
		%check if constant
		if strcmpi(cellFunctions{intPred},'constant')
			vecYhat = vecYhat + vecLinCoeffs(vecArgs);
		elseif strfind(cellFunctions{intPred},'_mult')
			intCutOff = strfind(cellFunctions{intPred},'_mult');
			strFunc = cellFunctions{intPred}(1:(intCutOff-1));
			%build code string
			strArgs = strcat('vecLinCoeffs([',num2str(vecArgs),'])');
			strEval = strcat(strFunc,'(matX(:,',num2str(intPred),'),',strArgs,')');
			vecYhat = vecYhat .* (1 + eval(strEval));
		else
			%build code string
			strArgs = strcat('vecLinCoeffs([',num2str(vecArgs),'])');
			strEval = strcat(cellFunctions{intPred},'(matX(:,',num2str(intPred),'),',strArgs,')');
			vecYhat = vecYhat + eval(strEval);
		end
	end
end

