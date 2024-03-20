function [vecMeanX,vecSemX,vecMeanY,vecSemY,vecQuantileAssignment,cellValsX,cellValsY]=getQuantiles(vecX,vecY,intQuantileNum)
	%getQuantiles Split X and Y data into equal quantiles of X
	%   [vecMeanX,vecSemX,vecMeanY,vecSemY,vecQuantileAssignment,cellValsX,cellValsY]=getQuantiles(vecX,vecY,intQuantileNum)
	%default number of quantiles is 10
	%If the number of samples is not divisible by the number of quantiles, it will drop the most
	%extreme values on the upper and lower end
	
	%default
	if ~exist('intQuantileNum','var') || isempty(intQuantileNum)
		intQuantileNum = 10;
	end
	assert(numel(vecX) == numel(vecY));
	if issorted(vecX)
		vecReorder=1:numel(vecX);
	else
		[vecSortedX,vecReorder] = sort(vecX);
	end
	%[dummy,vecInvert] = sort(vecReorder);
	intN = numel(vecX);
	%vecSortedY = vecY(vecReorder);
	intSperBin = floor(intN/intQuantileNum);
	intRemainder = rem(intN,intQuantileNum);
	intStartOffset = floor(intRemainder/2);
	
	vecMeanX = nan(1,intQuantileNum);
	vecSemX = nan(1,intQuantileNum);
	cellValsX = cell(1,intQuantileNum);
	vecMeanY = nan(1,intQuantileNum);
	vecSemY = nan(1,intQuantileNum);
	cellValsY = cell(1,intQuantileNum);
	vecQuantileAssignment = zeros(size(vecX));
	for intQ=1:intQuantileNum
		intEndS = intSperBin*intQ;
		vecSamples = intStartOffset+((intEndS-intSperBin+1):intEndS);
		vecRealSamples = vecReorder(vecSamples);
		vecMeanX(intQ) = mean(vecX(vecRealSamples));
		vecSemX(intQ) = std(vecX(vecRealSamples))./sqrt(intSperBin);
		cellValsX{intQ} = vecX(vecRealSamples);
		
		vecMeanY(intQ) = mean(vecY(vecRealSamples));
		vecSemY(intQ) = std(vecY(vecRealSamples))./sqrt(intSperBin);
		cellValsY{intQ} = vecY(vecRealSamples);
		
		vecQuantileAssignment(vecRealSamples) = intQ;
	end
end

