function vecFilledData = fillfromtrough(vecData)
	%fillfromtrough Fills valleys bidirectionally outward from lowest trough
	%   vecFilledData = fillfromtrough(vecData)
	%
	%This function will return a u-curve shaped output with a unique
	%minimum and strictly non-decreasing values outward from the trough. In
	%essence, it fills all local minima except for the global minimum with
	%the highest value observed between the local and global minimum.
	
	%starting trough
	vecInvData = max(vecData(:))-vecData;
	[vecPksInv,vecLocsInv]=findpeaks(vecInvData);
	[dblTroughVal,intTroughIdx]=max(vecPksInv);
	intTrough = vecLocsInv(intTroughIdx);
	%all peaks
	[vecPks,vecLocs]=findpeaks(vecData);
	dblCurrVal = dblTroughVal;
	%left
	vecFilledData = vecData;
	for intLeftPeak=sum(vecLocs < intTrough):-1:1
		dblPeakVal = vecPks(intLeftPeak);
		if dblPeakVal > dblCurrVal
			dblCurrVal = dblPeakVal;
		end
		if intLeftPeak==1
			intPos1 = 1;
		else
			intPos1 = vecLocs(intLeftPeak-1);
		end
		indPoints = false(1,numel(vecData));
		indPoints(intPos1:vecLocs(intLeftPeak)) = true;
		indPoints(vecFilledData > dblCurrVal) = false;
		vecFilledData(indPoints) = dblCurrVal;
	end
	
	%right
	dblCurrVal = dblTroughVal;
	for intRightPeak=(numel(vecLocs) - sum(vecLocs > intTrough) + 1):1:numel(vecLocs)
		dblPeakVal = vecPks(intRightPeak);
		if dblPeakVal > dblCurrVal
			dblCurrVal = dblPeakVal;
		end
		if intRightPeak==numel(vecLocs)
			intPos2 = numel(vecData);
		else
			intPos2 = vecLocs(intRightPeak+1);
		end
		indPoints = false(size(vecData));
		indPoints(vecLocs(intRightPeak):intPos2) = true;
		indPoints(vecFilledData > dblCurrVal) = false;
		vecFilledData(indPoints) = dblCurrVal;
	end
end