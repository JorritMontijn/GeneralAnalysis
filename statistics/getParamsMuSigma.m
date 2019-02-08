function [vecParams,vecLowerBounds,vecUpperBounds]  = getParamsMuSigma(vecMu,matSigma)
	%UNTITLED7 Summary of this function goes here
	%   Detailed explanation goes here
	
	%remove upper triangle from covariance matrix
	matLowerTriangle = tril(true(size(matSigma,1)),0);
	vecC = matSigma(matLowerTriangle);
	
	%put together
	vecParams = [vecMu(:); vecC(:)];
	
	%set bounds
	if nargout > 1
		matEyeS = eye(size(matSigma,1));
		matLowerBound = -inf*ones(size(matSigma));
		matLowerBound(logical(matEyeS)) = eps;
		vecLB = matLowerBound(matLowerTriangle);
		vecLowerBounds = [-inf*ones(size(vecMu(:))); vecLB];
		vecUpperBounds = inf*ones(size(vecParams));
	end
end

