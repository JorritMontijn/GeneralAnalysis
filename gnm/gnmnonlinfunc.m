function matError = gnmnonlinfunc(vecLinCoeffs)
	%gnmnonlinfunc Wrapper for lsqnonlin()
	%   matError = gnmnonlinfunc(vecLinCoeffs);
	%
	%matError is the individual error per observation n and predictor p as
	%an [n x p] error matrix between Y and Y_hat(p)
	
	%% get globals
	global gMatX;
	global gVecY;
	matX = gMatX;
	vecY = gVecY;
	global gCellLinkFunctions;
	global gVecLinCoeffFunctions;
	
	%% run
	matY = zeros(size(matX,1),size(matX,2));
	for intPred=1:size(matX,2)
		%get arguments
		vecArgs = find(gVecLinCoeffFunctions==intPred);
		%check if constant
		if strcmpi(gCellLinkFunctions{intPred},'constant')
			matY(:,intPred) = vecLinCoeffs(vecArgs);
		else
			%build code string
			strArgs = strcat('vecLinCoeffs([',num2str(vecArgs),'])');
			strEval = strcat(gCellLinkFunctions{intPred},'(matX(:,',num2str(intPred),'),',strArgs,')');
			matY(:,intPred) = eval(strEval);
		end
	end
	
	%% calculate error
	%least squares
	matError = bsxfun(@minus,vecY,matY);
	
end

