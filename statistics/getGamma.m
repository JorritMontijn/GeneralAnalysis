function [vecY] = getGamma(vecP,vecX)
	%getGamma Gamma function
	%   [vecY] = getGamma(vecP,vecX)
	%
	%function: 
	%	vecY = vecUseP(5)+vecUseP(3)*gampdf(vecX*vecUseP(4),vecUseP(1),vecUseP(2));
	%vecP(1): alpha
	%vecP(2): beta
	%vecP(3): y-scale
	%vecP(4): x-scale
	%vecP(5): y-offset
	
	%% assign input
	vecUseP = [1 1 1 1 0];
	vecUseP(1:numel(vecP)) = vecP;
	%% get values
	vecY = vecUseP(5)+vecUseP(3)*gampdf(vecX*vecUseP(4),vecUseP(1),vecUseP(2));
end

