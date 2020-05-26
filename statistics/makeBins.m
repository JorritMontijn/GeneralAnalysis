function [vecCounts,vecMeans,vecSDs,cellVals,cellIDs] = makeBins(vecX,vecY,vecBins)
	%makeBins Bins an indexed matrix by its 2nd dimension
	%   syntax: [vecCounts,vecMeans,vecSDs,cellVals,cellIDs] = makeBins(vecX,vecY,vecBins)
	%	description: bins on the x axis (the values in vecX) and returns
	%	the number (nVec), mean (meanVec) and standard deviation (stdVec)
	%	of the values per bin based on their corresponding values in vecY.
	%	If you simply want to count the number of values inside a certain
	%	bin, you can use the Matlab function hist()
	%	input:
	%	- vecX: vector containing data on the binning-axis
	%	- vecY: vector containing data corresponding to identical positions
	%	  on vecX; the value vecY(n) corresponds to the value vecX(n)
	%	- vecBins: vector containing the edges of the bins where data
	%	  from vecY will be pooled based on their corresponding values in
	%	  vecX.
	%	output:
	%	- vecCounts: number of vecX values per bin
	%	- vecMeans: mean of vecY values per bin
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
	if isvector(vecY),vecY=vecY(:);end
	vecX = vecX(:);
	vecBins = vecBins(:);
	intBinVals = length(vecBins);
	vecCounts = nan(intBinVals-1,1);
	vecMeans = nan(intBinVals-1,size(vecY,2));
	vecSDs = nan(intBinVals-1,size(vecY,2));
	cellVals = cell(1,intBinVals-1);
	cellIDs = cell(1,intBinVals-1);
	
	%% run slow binning, v2
	if nargout > 2
		ptrTic = tic;
		for intBin=1:intBinVals-1
			intBinMax = vecBins(intBin+1);
			intBinMin = vecBins(intBin);
			vecValIndexUnderMax = vecX < intBinMax;
			vecValIndexOverMin = vecX > intBinMin;
			vecValIndexThisBin = vecValIndexUnderMax & vecValIndexOverMin;
			
			vecTheseVals = vecY(vecValIndexThisBin,:);
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
		[vecCounts,~,vecIdx]=histcounts(vecX,vecBins);
		vecCounts = vecCounts(:)';
		indKeep = vecIdx > 0;
		vecSums = accumarray(flat(vecIdx(indKeep)),flat(vecY(indKeep)));
		vecSums((end+1):numel(vecCounts)) = 0;
		vecMeans = vecSums./vecCounts;
	end
end
