function vecP = contpoisspdf(vecRate,dblLambda)
	%contpoisspdf Continuous-support approximation of Poisson pdf
	%   vecP = contpoisspdf(vecRate,dblLambda)
	%
	%Works in log-domain to avoid numerical issues, using the following formula:
	%vecP = exp(vecRate.*log(dblLambda) - dblLambda - gammaln(vecRate+1));
	%
	%Version history:
	%1.0 - January 21 2020
	%	Created by Jorrit Montijn
	
	vecP = exp(vecRate.*log(dblLambda) - dblLambda - gammaln(vecRate+1));
end

