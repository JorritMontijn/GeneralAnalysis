function [dblPeakValue,dblPeakTime,dblPeakWidth,vecPeakStartStop,intPeakLoc,vecPeakStartStopIdx] = getPeak(vecData,vecT,vecRestrictRange)
	%getPeak Returns highest peak time, width, and location. Syntax:
	%    [dblPeakValue,dblPeakTime,dblPeakWidth,vecPeakStartStop,intPeakLoc,vecPeakStartStopIdx] = getPeak(vecData,vecT,vecRestrictRange)
	%
	%Required input:
	%	- vecData [N x 1]: values
	%
	%Optional inputs:
	%	- vecT [N x 1]: timestamps corresponding to vecData (default: [1:N])
	%	- vecRestrictRange: restrict peak to lie within vecRestrictRange(1) and vecRestrictRange(end)
	%
	%Outputs:
	%	- dblPeakTime: time of peak
	%	- dblPeakWidth: width of peak
	%	- vecPeakStartStop: start/stop times of peak
	%	- intPeakLoc: index of peak
	%	- vecPeakStartStopIdx: start/stop indices of peak
	%
	%Version history:
	%1.0 - February 18 2020
	%	Created by Jorrit Montijn
	
	%check inputs
	if ~exist('vecT','var')
		vecT = 1:numel(vecData);
	end
	if ~exist('vecRestrictRange','var')
		vecRestrictRange = [-inf inf];
	end
	
	%get most prominent positive peak times
	[vecValsPos,vecLocsPos,vecWidthPos,vecPromsPos]=findpeaks(vecData);
	%remove peaks outside window
	indRemPeaks = vecT(vecLocsPos) < vecRestrictRange(1) | vecT(vecLocsPos) > vecRestrictRange(end);
	vecValsPos(indRemPeaks) = [];
	vecLocsPos(indRemPeaks) = [];
	vecPromsPos(indRemPeaks) = [];
	%select peak
	[dblMaxPosVal,intPosIdx] = max(vecValsPos);
	
	%get most prominent negative peak times
	[vecValsNeg,vecLocsNeg,vecsWidthNeg,vecPromsNeg]=findpeaks(-vecData);
	%remove peaks outside window
	indRemPeaks = vecT(vecLocsNeg) < vecRestrictRange(1) | vecT(vecLocsNeg) > vecRestrictRange(end);
	vecValsNeg(indRemPeaks) = [];
	vecLocsNeg(indRemPeaks) = [];
	vecPromsNeg(indRemPeaks) = [];
	%select peak
	[dblMaxNegVal,intNegIdx] = max(vecValsNeg);
	
	if (isempty(dblMaxPosVal) && isempty(dblMaxNegVal))
		indPeakMembers = [];
	elseif (~isempty(dblMaxPosVal) && isempty(dblMaxNegVal)) || (abs(dblMaxPosVal) >= abs(dblMaxNegVal))
		intIdx = intPosIdx;
		intPeakLoc = vecLocsPos(intIdx);
		dblPeakProm = vecPromsPos(intIdx);
		dblCutOff = vecData(intPeakLoc) - dblPeakProm/2;
		indPeakMembers = vecData > dblCutOff;
	elseif (isempty(dblMaxPosVal) && ~isempty(dblMaxNegVal)) ||  (abs(dblMaxPosVal) < abs(dblMaxNegVal))
		intIdx = intNegIdx;
		intPeakLoc = vecLocsNeg(intIdx);
		dblPeakProm = vecPromsNeg(intIdx);
		dblCutOff = vecData(intPeakLoc) + dblPeakProm/2;
		indPeakMembers = vecData < dblCutOff;
	end
	if ~isempty(indPeakMembers)
		%get potential starts/stops
		vecPeakStarts = find(diff(indPeakMembers)==1);
		vecPeakStops = find(diff(indPeakMembers)==-1);
		if indPeakMembers(1) == 1,vecPeakStarts = [1 vecPeakStarts(:)'];end
		if indPeakMembers(end) == 1,vecPeakStops = [vecPeakStops(:)' numel(indPeakMembers)];end
		%find closest points
		intPeakStart = intPeakLoc-min(intPeakLoc - vecPeakStarts(vecPeakStarts<intPeakLoc));
		intPeakStop = intPeakLoc+min(vecPeakStops(vecPeakStops>=intPeakLoc) - intPeakLoc);
		dblPeakStartT = vecT(intPeakStart);
		dblPeakStopT = vecT(intPeakStop);
		%assign peak data
		dblPeakValue = vecData(intPeakLoc);
		dblPeakTime = vecT(intPeakLoc);
		dblPeakWidth = dblPeakStopT-dblPeakStartT;
		vecPeakStartStop = [dblPeakStartT dblPeakStopT];
		vecPeakStartStopIdx = [intPeakStart intPeakStop];
	else
		%assign placeholder peak data
		dblPeakValue = nan;
		dblPeakTime = nan;
		dblPeakWidth = nan;
		vecPeakStartStop = [nan nan];
		intPeakLoc = nan;
		vecPeakStartStopIdx = [nan nan];
	end
end
