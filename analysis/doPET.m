function [matPET,vecWindowC] = doPET(vecTime,vecVals,vecEvents,vecWindow)
	%doPET Calculates peri-event time-series for variable-rate data, averaging withins bins and interpolating over empty bins
	%syntax: [matPET,vecWindowC] = doPET(vecTime,vecVals,vecEvents,vecWindow)
	%	input:
	%	- vecTime; timestamps of data in vecVals
	%	- vecVals; vector with time-series data
	%	- vecEvents; vector containing event times
	%	- vecWindow: window with bin edges to average/interpolate over
	%
	%Version history:
	%1.0 - June 7 2023
	%	Created by Jorrit Montijn
	
	%check input
	assert(all(size(vecTime) == size(vecVals)),'Time-stamps and value vector have different dimensions');
	
	%merged peaks, IFR
	intEvents = numel(vecEvents);
	vecWindowC = vecWindow(2:end)-diff(vecWindow)./2;
	matPET = nan(intEvents,numel(vecWindowC));
	parfor intEvent=1:intEvents
		vecThisWindow = vecWindow+vecEvents(intEvent);
		[vecCounts,vecMeans] = makeBins(vecTime,vecVals,vecThisWindow);
		%interpolate missing values
		indNan = isnan(vecMeans);
		if any(indNan)
			vecTempT = vecWindowC;
			if isnan(vecMeans(1))
				%find value prior to start
				intPreT = find(vecTime>=vecThisWindow(1),1)-1;
				if isempty(intPreT) || intPreT<1,intPreT=1;end
				indNan = cat(1,false,indNan(:));
				vecTempT = cat(1,vecTime(intPreT)-vecEvents(intEvent),vecTempT(:));
				vecMeans = cat(1,vecVals(intPreT),vecMeans(:));
			end
			if isnan(vecMeans(end))
				%find value after to end
				intPostT = find(vecTime>vecThisWindow(end),1);
				if isempty(intPostT),intPostT=numel(vecTime);end
				indNan(end+1) = false;
				vecTempT(end+1) = vecTime(intPostT)-vecEvents(intEvent);
				vecMeans(end+1) = vecVals(intPostT);
			end
			matPET(intEvent,:) = interp1(vecTempT(~indNan),vecMeans(~indNan),vecWindowC);
		else
			matPET(intEvent,:) = vecMeans;
		end
	end
end
