function [dblAIC,dblAICc,LL] = aicfromr2(dblR2,k,n)
	%aicfromr2 Calculate AIC from R^2
	%   [dblAIC,dblAICc,LL] = aicfromr2(dblR2,k,n)
	%Inputs:
	%dblR2: R^2
	%k=degrees of freedom/number of model parameters
	%n=number of samples
	%
	%Outputs:
	%dblAIC: Akaike's information criterion
	%dblAICc: corrected Akaike's information criterion
	%LL: log-likelihood
	%
	%Note: returns Inf for n>330
	
	%See:
	%https://statproofbook.github.io/P/rsq-mll.html
	
	%calculate log-likelihood, aic, and corrected aic
	%?MLL = log((1-R^2)^(-n/2))
	%LL = log((1-dblR2)^(-n/2)); %log-likelihood
	LL = log(1-dblR2)*(-n/2); %log-likelihood, more numerically stable
	dblAIC = 2*k - 2*LL; %aic
	aic_correction = (2*k^2 + 2*k)/(n-k-1); %correction for aic
	dblAICc = 2*k - 2*LL+aic_correction; %corrected aic
	return;
	
	%check
	R2=1-(exp(LL))^(-2/n)
	LL2 = log((1-R2)^(-n/2))
end

