function matLowHigh = getCI(matSample,intDim,dblAlpha)
	%getCI Returns confidence intervals on input sample
	%   Syntax: matLowHigh = getCI(matSample,intDim,dblAlpha)
	%
	%Returns matrix with form [n x 2], where matLowHigh(n,1) gives lower
	%bound and matLowHigh(n,2) gives upper bound for sample n in matSample,
	%calculated over dimension intDim. If no dblAlpha is supplied, default
	%is set to alpha=0.05
	%
	%	By Jorrit Montijn, 16-01-15 (University of Amsterdam)
	
	% determine which dimension to use
	if nargin<2,intDim = find(size(matSample)~=1,1);end
	if isempty(intDim),intDim = 1; end
	
	% set alpha
	if nargin<3 || isempty(dblAlpha)
		dblAlpha = 0.05;
	end
	
	%get factors
	intN = size(matSample,intDim);
	vecSampleMean = mean(matSample,intDim);
	dblNormInvP = norminv(1-dblAlpha/2,0,1);
	vecSampleSD = std(matSample,[],intDim);
	dblFactor = sqrt(intN);
	
	%calculate CIs
	vecLow = vecSampleMean-dblNormInvP*(vecSampleSD/dblFactor);
	vecHigh = vecSampleMean+dblNormInvP*(vecSampleSD/dblFactor);
	
	%put in output
	matLowHigh = [vecLow(:) vecHigh(:)];
	
	
	
	
end

