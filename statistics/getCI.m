function matLowHigh = getCI(matSample,intDim,dblAlpha,boolPercentiles)
	%getCI Returns confidence intervals on input sample
	%   Syntax: matLowHigh = getCI(matSample,intDim,dblAlpha,boolPercentiles)
	%
	%Returns matrix with form [n x 2], where matLowHigh(n,1) gives lower
	%bound and matLowHigh(n,2) gives upper bound for sample n in matSample,
	%calculated over dimension intDim. If no dblAlpha is supplied, default
	%is set to alpha=0.05
	%
	%	By Jorrit Montijn, 16-01-15 (University of Amsterdam)
	%	2020-05-25, Added percentile switch [by JM]
	
	% determine which dimension to use
	if nargin<2,intDim = find(size(matSample)~=1,1);end
	if isempty(intDim),intDim = 1; end
	
	% set alpha
	if nargin<3 || isempty(dblAlpha)
		dblAlpha = 0.05;
	end
	dblAlphaLow = dblAlpha(1);
	if numel(dblAlpha)>1
		dblAlphaHigh = dblAlpha(2);
	else
		dblAlphaHigh = 1-dblAlphaLow;
	end
	
	%set geometric
	if ~exist('boolPercentiles','var') || isempty(boolPercentiles)
		boolPercentiles = false;
	end
	
	if boolPercentiles
		%get factors
		if intDim == 2
			matSample = matSample';
		end
		intN = size(matSample,1);
		vecSampleMedian = median(matSample,1);
		matSortedVals = sort(matSample,1);
		
		dblFractionalEntryLow = intN*dblAlphaLow;
		dblFractionalEntryHigh = intN*dblAlphaHigh;
		
		intEntries = size(matSortedVals,2);
		vecValuesLow = nan(1,intEntries);
		vecValuesHigh = nan(1,intEntries);
		for intEntry=1:intEntries
			vecValuesLow(intEntry) = getFractionalEntry(matSortedVals(:,intEntry),dblFractionalEntryLow);
			vecValuesHigh(intEntry) = getFractionalEntry(matSortedVals(:,intEntry),dblFractionalEntryHigh);
		end
		
		%put in output
		matLowHigh = [vecValuesLow(:) vecValuesHigh(:)];
	else
		%get factors
		intN = size(matSample,intDim);
		vecSampleMean = mean(matSample,intDim);
		dblNormInvPLow = norminv(1-dblAlphaLow/2,0,1);
		dblNormInvPHigh = norminv(1-dblAlphaHigh/2,0,1);
		vecSampleSD = std(matSample,[],intDim);
		dblFactor = sqrt(intN);
		
		%calculate CIs
		vecLow = vecSampleMean-dblNormInvPLow*(vecSampleSD/dblFactor);
		vecHigh = vecSampleMean-dblNormInvPHigh*(vecSampleSD/dblFactor);
		
		%put in output
		matLowHigh = [vecLow(:) vecHigh(:)];
	end
	
	
	
end

