function vecY = gnmgauss(vecX,vecParams)
	%gnmgauss Wrapper with scale-parameter for normal distribution
	%   vecY = gnmgauss(vecX,vecParams)
	%
	%Function:
	%vecY = vecParams(1)*normpdf(vecX,vecParams(2),vecParams(3));
	vecY = vecParams(1)*normpdf(vecX,vecParams(2),vecParams(3));
end

