function [matMean,matStd,cellVals] = getMatrixBlockMeans(matIn,vecIdentities)
	%UNTITLED4 Summary of this function goes here
	%   Detailed explanation goes here
	
	%create selection vectors
	vecIDTypes = unique(double(vecIdentities));
	intNumIDs = length(vecIDTypes);
	vecFirstVal = ones(1,length(vecIDTypes));
	vecLastVal = ones(1,length(vecIDTypes));
	for intCounterID = 1:intNumIDs
		intID = vecIDTypes(intCounterID);
		vecFirstVal(intCounterID) = find(vecIdentities == intID,1,'first');
		vecLastVal(intCounterID) = find(vecIdentities == intID,1,'last');
	end
	vecFirstVal = sort(vecFirstVal, 'ascend');
	vecLastVal = sort(vecLastVal, 'ascend');
	
	%pre-allocate output
	matMean = nan(intNumIDs,intNumIDs);
	matStd = nan(intNumIDs,intNumIDs);
	cellVals = cell(intNumIDs,intNumIDs);
	matSelect = tril(true(size(matIn)),-1);
	
	%collect values and put in output matrix
	for intCounterID2 = 1:intNumIDs
		intStartID2 = vecFirstVal(intCounterID2);
		intStopID2 = vecLastVal(intCounterID2);
		
		for intCounterID1 = intCounterID2:intNumIDs
			intStartID1 = vecFirstVal(intCounterID1);
			intStopID1 = vecLastVal(intCounterID1);
			
			%create subselection matrix
			matSubSelect = false(size(matSelect));
			matSubSelect(intStartID1:intStopID1,intStartID2:intStopID2) = true;
			matIndices = matSelect & matSubSelect;
			
			%get values and put in matrix
			matValues = matIn(matIndices);
			matMean(intCounterID1,intCounterID2) = mean(matValues(:));
			matStd(intCounterID1,intCounterID2) = std(matValues(:));
			cellVals{intCounterID1,intCounterID2} = matValues(:);
		end
	end
end

