function matOut = logmvnrnd(mu,covar,n)
	%logmvnrnd Log-normal random numbers with mean=mu and std=sqrt(covar)
	%   matOut = logmvnrnd(mu,covar,n)
	%
	%Works for covar with diagonal elements, but exact results for correlated covar mats not
	%guaranteed
	
	%log normal
	matCov = log(covar./(mu.^2)+1);
	vecMu = log(mu) - 0.5*diag(matCov);
	matOut = exp(mvnrnd(vecMu,matCov,n));
	
	%expectation for exp(mvnrand):
	vecVar = diag(matCov);
	vecExpectedMu = exp(vecMu + 0.5*vecVar);
	matExpectedVar = exp(vecMu + vecMu' + 0.5*(vecVar + vecVar'))*(exp(matCov)-1);
	matExpectedSd = sqrt(matExpectedVar);
	vecExpectedSd = diag(matExpectedSd);
	
end

