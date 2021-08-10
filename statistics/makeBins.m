function [vecCounts,vecMeans,vecSDs,cellVals,cellIDs] = makeBins(vecIdx,vecVals,vecBins)
	%makeBins Bins an indexed vector and returns the mean/sd/etc per bin
	%   syntax: [vecCounts,vecMeans,vecSDs,cellVals,cellIDs] = makeBins(vecIdx,vecVals,vecBins)
	%	description: bins using vecIdx and returns
	%	the number (vecCounts), mean (vecMeans) and standard deviation (vecSDs)
	%	of the values per bin based on their corresponding values in vecVals.
	%	If you simply want to count the number of values inside a certain
	%	bin, you can use the Matlab function histcounts()
	%	input:
	%	- vecIdx: vector containing data on the indexing (binning) axis
	%	- vecVals: vector containing data corresponding to identical positions
	%	  on vecIdx; the value vecVals(i) corresponds to the value vecIdx(i)
	%	- vecBins: vector containing the edges of the bins where data
	%	  from vecVals will be pooled based on their corresponding values in
	%	  vecIdx.
	%	output:
	%	- vecCounts: number of vecIdx values per bin
	%	- vecMeans: mean of vecVals values per bin
	%	- vecSDs: standard deviation of vecY values per bin
	%	- cellVals: cell-array with vector of values per bin
	%	- cellIDs: cell-array with selection vector per bin
	%
	%	Version history:
	%	1.0 - April 15 2011
	%	Created by Jorrit Montijn
	%	1.1 - May 24 2019
	%	Added pre-allocation and updated variable names [by JM]
	
	%pre-allocate
	if isvector(vecVals),vecVals=vecVals(:);end
	vecIdx = vecIdx(:);
	vecBins = vecBins(:);
	intBinVals = length(vecBins);
	vecCounts = nan(intBinVals-1,1);
	vecMeans = nan(intBinVals-1,size(vecVals,2));
	vecSDs = nan(intBinVals-1,size(vecVals,2));
	cellVals = cell(1,intBinVals-1);
	cellIDs = cell(1,intBinVals-1);
	
	%% run slow binning, v2
	if nargout > 2
		ptrTic = tic;
		for intBin=1:intBinVals-1
			intBinMax = vecBins(intBin+1);
			intBinMin = vecBins(intBin);
			vecValIndexUnderMax = vecIdx < intBinMax;
			vecValIndexOverMin = vecIdx > intBinMin;
			vecValIndexThisBin = vecValIndexUnderMax & vecValIndexOverMin;
			
			vecTheseVals = vecVals(vecValIndexThisBin,:);
			vecCounts(intBin,:) = size(vecTheseVals,1);
			vecMeans(intBin,:) = nanmean(vecTheseVals);
			vecSDs(intBin,:) = nanstd(vecTheseVals);
			cellVals{intBin} = vecTheseVals;
			cellIDs{intBin} = find(vecValIndexThisBin);
			
			%msg
			if toc(ptrTic) > 5
				fprintf('Binning... Now at bin %d/%d [%s]\n',intBin,intBinVals,getTime);
				ptrTic = tic;
			end
		end
	else
		%% run fast binning, v3
		[vecCounts,~,vecIdx]=histcounts(vecIdx,vecBins);
		vecCounts = vecCounts(:)';
		indKeep = vecIdx > 0;
		vecSums(:) = accumarray(flat(vecIdx(indKeep)),flat(vecVals(indKeep)));
		vecSums((end+1):numel(vecCounts)) = 0;
		vecMeans = vecSums./vecCounts;
	end
end
