function [nVec,meanVec,stdVec,cellVals,cellIDs] = makeBins(xVec,yVec,binVector)
	%makeBins Bins an indexed matrix by its 2nd dimension
	%   syntax: [nVec,meanVec,stdVec,cellVals,cellIDs] = makeBins(xVec,yVec,binVector)
	%	description: bins on the x axis (the values in xVec) and returns
	%	the number (nVec), mean (meanVec) and standard deviation (stdVec)
	%	of the values per bin based on their corresponding values in yVec.
	%	If you simply want to count the number of values inside a certain
	%	bin, you can use the Matlab function hist()
	%	input:
	%	- xVec: vector containing data on the binning-axis
	%	- yVec: vector containing data corresponding to identical positions
	%	  on xVec; the value yVec(n) corresponds to the value xVec(n)
	%	- binVector: vector containing the edges of the bins where data
	%	  from yVec will be pooled based on their corresponding values in
	%	  xVec.
	%	output:
	%	- nVec: number of xVec values per bin
	%	- meanVec: mean of yVec values per bin
	%	- stdVec: standard deviation of yVec values per bin
	%	- cellVals: cell-array with vector of values per bin
	%	- cellIDs: cell-array with selection vector per bin
	%
	%	Version history:
	%	1.0 - April 15 2011
	%	Created by Jorrit Montijn

	binVals = length(binVector);
	for binIndex=1:binVals-1
		binMax = binVector(binIndex+1);
		binMin = binVector(binIndex);
		vecValIndexUnderMax = xVec < binMax;
		vecValIndexOverMin = xVec > binMin;
		vecValIndexThisBin = vecValIndexUnderMax & vecValIndexOverMin;
		
		vecTheseVals = yVec(vecValIndexThisBin);
		nVec(binIndex) = length(vecTheseVals);
		meanVec(binIndex) = nanmean(vecTheseVals);
		stdVec(binIndex) = nanstd(vecTheseVals);
		cellVals{binIndex} = vecTheseVals;
		cellIDs{binIndex} = find(vecValIndexThisBin);
	end
end