function dblR = nancorr(vecA,vecB)
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	
	vecInc = ~isnan(vecA) & ~isnan(vecB);
	dblR = corr(vecA(vecInc),vecB(vecInc));
end

