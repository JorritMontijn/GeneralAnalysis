function  matSigmaOut = qnorm(matProbabilities,dblMean,matSigmas,boolUseApproximation)
	%QNORM 	  Uses the normal inverse distribution function to compute the
	%number of standard deviations that probability values are away from
	%the mean, assuming a Gaussian distribution; i.e., it transforms known
	%probabilities to standard deviation units (see also:
	%	http://en.wikipedia.org/wiki/Probit ) 
	%
	%Syntax: matSigmaOut = qnorm(matProbabilities,dblMean,matSigmas,boolUseApproximation)
	%
	%	By Jorrit Montijn, 08-01-15 (University of Amsterdam), based on
	%	original code by Anders Holtsberg, 13-05-94. Improvements include:
	%	- Approximation of inverse error function using scaled logarithmic
	%		function for probability values lower than "eps" (~8sd) 
	%	- Corrected potential input check failure for matrices with more
	%		than 2 dimensions
	%	- Comments added and code made more readable
	%
	%N.B.: for output values of >~8 sd's the returned values are
	%approximations and are not directly computed using erfinv(). The
	%logarithmic approximator function is relatively precise, but caution
	%is advised. If you do not wish to use this approximation, supply a
	%fourth input argument set to 'false'; the function will then return
	%'Inf' where the direct computation fails
	
	%assign default values if none are supplied
	if nargin<4, boolUseApproximation=true;end
	if nargin<3, matSigmas=1; end
	if nargin<2, dblMean=0; end
	
	%check inputs
	if any(abs(2*matProbabilities(:)-1)>1)
		error('A probability should be 0<=p<=1, please!')
	end
	if any(matSigmas(:)<=0)
		error('Parameter s is wrong')
	end
	
	%compute output
	matSigmaOut = erfinv(2*matProbabilities-1).*sqrt(2).*matSigmas + dblMean;
	
	if any(isinf(matSigmaOut(:))) && boolUseApproximation
		%approximate sigma values if probability values are lower than eps;
		%the approximation parameters were chosen to be optimized for low
		%values of p; for relatively high probabilities it overestimates
		%the number of sd units; therefore the approximation is only used
		%for low probability values when the erfinv() function fails
		vecParams = [11.019256132743735 1.347539627399523 14.363644579170472 -6.480103303961139];
		matApprox = abs(logfitfun(vecParams,-log10(matProbabilities)));
		matSigmaOut(isinf(matSigmaOut)) = matApprox(isinf(matSigmaOut));
	end
end
function vecY = logfitfun(vecParams,vecX)
	%logfitfun Logarithmic function with scaling factors
	%   Syntax: vecY = logfitfun(vecParams,vecX)
	%params; x-offset, x-scaling, y-offset, y-scaling
	
	vecY = vecParams(3)+vecParams(4)*log(vecX*vecParams(2)+vecParams(1));
end
