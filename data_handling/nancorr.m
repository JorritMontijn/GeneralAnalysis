function varargout = nancorr(vecA,vecB)
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	
	vecInc = ~isnan(vecA) & ~isnan(vecB);
	[varargout{1:nargout}] = corr(vecA(vecInc),vecB(vecInc));
end

