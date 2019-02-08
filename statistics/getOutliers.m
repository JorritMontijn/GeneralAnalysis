function [indexList,indexLow,indexHigh] = getOutliers(data,stdCutOff)
	%getOutliers Get indices of values outside specified bounds
	%syntax: [indexList,indexLow,indexHigh] = getOutliers(data[,stdCutOff])
	%	input:
	%	- data: vector containing values
	%	- stdCutOff: number of standard deviations from mean that is
	%		considered an outlier. Default is 5 stds
	%
	%	output:
	%	- indexList: logical index of all outliers
	%	- indexLow: logical index of outliers below mean
	%	- indexHigh: logical index of outliers above mean
	%
	%	notes:
	%	If data supplied is a >1D matrix, the matrix is vectorized before
	%	computing the indices, so the index list is always a logical 1D
	%	vector
	%
	%	Version history:
	%	1.0 - February 15 2013
	%	Created by Jorrit Montijn
	
	%default cutoff
	if ~exist('stdCutOff','var') || isempty(stdCutOff)
		stdCutOff = 5;
	end
	

	%turn into vector
	vecData=data(:);
	
	%remove infs + nans
	vecData(isinf(vecData)) = 0;
	vecData(isnan(vecData)) = 0;
	
	boolOutliers = true;
	while boolOutliers
		%get mean&std from vectorized input
		dblMean = nanmean(vecData(:));
		dblStd = nanstd(vecData(:));
		
		%calc cutoffs
		minCutOff = dblMean - dblStd * stdCutOff;
		maxCutOff = dblMean + dblStd * stdCutOff;
		
		%calc indices
		indexLow = vecData < minCutOff;
		indexHigh = vecData > maxCutOff;
		indexList = indexLow | indexHigh;
		
		%check if outliers found
		if sum(indexList) > 0
			vecData = vecData(~indexList);
		else
			boolOutliers = false;
		end
	end
	%calc indices
	indexLow = data < maxCutOff;
	indexHigh = data > minCutOff;
	indexList = ~(indexLow & indexHigh);
end

