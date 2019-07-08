function [vecInterpT,matTracePerTrial] = getTraceInTrial(vecTimestamps,vecTrace,vecTrialStarts,dblSamplingFreq,dblUseMaxDur)

	%getSpikesInTrial Retrieves spiking times per trial
	%syntax: [vecTrialPerSpike,vecTimePerSpike] = getTraceInTrial(vecSpikes,vecTrialStarts)
	%	input:
	%	- vecSpikes; spike times (s)
	%	- vecTrialStarts: trial start times (s)
	%
	%Version history:
	%1.0 - June 26 2019
	%	Created by Jorrit Montijn
	
	%% prepare
	%build common timeframe
	vecInterpT = (dblSamplingFreq/2):dblSamplingFreq:dblUseMaxDur;
	
	%pre-allocate
	intTrialNum = numel(vecTrialStarts);
	intTimeNum = numel(vecTimestamps);
	matTracePerTrial = nan(intTrialNum,numel(vecInterpT));
	
	%% assign data
	for intTrial=1:intTrialNum
		%% get original times
		dblStartT = vecTrialStarts(intTrial);
		dblStopT = dblStartT+dblUseMaxDur;
		intStartT = max([1 find(vecTimestamps > dblStartT,1) - 1]);
		intStopT = min([intTimeNum find(vecTimestamps > dblStopT,1) + 1]);
		vecSelectFrames = intStartT:intStopT;
		
		%% get data
		vecUseTimes = vecTimestamps(vecSelectFrames);
		vecUseTrace = vecTrace(vecSelectFrames);
		
		%% interpolate
		vecUseInterpT = vecInterpT+dblStartT;
		
		%get real fractions for training set
		matTracePerTrial(intTrial,:) = interp1(vecUseTimes,vecUseTrace,vecUseInterpT);
	end
	
end

