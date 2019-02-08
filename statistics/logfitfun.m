function vecY = logfitfun(vecParams,vecX)
	%logfitfun Logarithmic function with scaling factors for fitting
	%   Syntax: vecY = logfitfun(vecParams,vecX)
	%params; x-offset, x-scaling, y-offset, y-scaling
	
	vecY = vecParams(3)+vecParams(4)*log(vecX*vecParams(2)+vecParams(1));
end

