function vecYhat = gnmval(cellCoeffs,matXwithBias,cellFunctions)
	%gnmval Calculates predicted values vecYhat given fitted model coefficients
	%   vecYhat = gnmval(cellCoeffs,matXwithBias,cellFunctions);
	
	%% run
	vecYhat = zeros(size(matXwithBias,1),1);
	for intPred=1:size(matXwithBias,2)
		%check if constant
		if strcmpi(cellFunctions{intPred},'constant')
			vecYhat = vecYhat + cellCoeffs{intPred};
		else
			%build code string
			strArgs = strcat('cellCoeffs{',num2str(intPred),'}');
			strEval = strcat(cellFunctions{intPred},'(matX(:,',num2str(intPred),'),',strArgs,')');
			vecYhat = vecYhat + eval(strEval);
		end
	end
end

