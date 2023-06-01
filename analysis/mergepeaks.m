function [matPeakDomain,indKeepPeaks] = mergepeaks(vecT,vecV,vecP)
	%mergepeaks Merge peaks based on prominence
	%   [matPeakDomain,indKeepPeaks] = mergepeaks(vecT,vecV,vecP)
	%
	%Inputs:
	% - vecT: timestamp vector
	% - vecV: value vector
	% - vecP: peak locations
	%
	%Outputs:
	% - matPeakDomain: [P x 3] matrix, 
	%		matPeakDomain(:,1): peak location
	%		matPeakDomain(:,2): left domain-edge
	%		matPeakDomain(:,3): right domain-edge
	%
	%Algorithm:
	%For each peak, from highest to lowest:
	%1) Calculate prominence of this peak if the closest leftward is merged into this higher peak. 
	%2a) If the prominence is increased, merge peaks, and remove merged peak from available peaks.
	%2b) If prominence is not increased, continue to rightward peaks
	%3) Calculate prominence of this peak if the closest rightward is merged into this higher peak. 
	%3a) If the prominence is increased, merge peaks, and remove merged peak from available peaks.
	%3b) If prominence is not increased, go to step 1 for the next-highest peak, or if no peaks
	%		remain, go to step 4.
	%4) For each peak, set the domain edges for each side to lowest trough within that one-sided domain.
	%
	%Dependencies:
	%findtrough.m (embedded below)
	
	%flatten
	vecT = vecT(:);
	vecV = vecV(:);
	vecP = vecP(:);
	
	%merge until prominence no longer drops from merges
	vecP_T = vecT(vecP);
	vecP_L = vecP;
	vecP_V = vecV(vecP_L);
	indKeepPeaks = false(size(vecP_T));
	indProcessed = false(size(vecP_T));
	matPeakDomain = nan(numel(vecP_T),3); %peak sample idx, start sample idx, stop sample idx
	matPeakDomain(:,1) = vecP_L; %peak sample idx
	matPeakDomain(:,2) = vecP_L; %start sample idx
	matPeakDomain(:,3) = vecP_L; %stop sample idx
	while ~all(indProcessed)
		%% merge peaks
		%find highest unprocessed peak
		dblHeight = max(vecP_V(~indProcessed));
		intPeak = find(vecP_V==dblHeight);
		intPeakLoc = vecP_L(intPeak);
		dblPeakT = vecP_T(intPeak);
		
		%merge left, then merge right
		%% left
		boolLeftComplete = false;
		indConsidered = false(size(vecP_T));
		while ~boolLeftComplete && ~all(indConsidered)
			%find nearest peak outside domain
			vecLeftDist = intPeakLoc - matPeakDomain(:,1);
			vecLeftDist(indConsidered | vecLeftDist<=0)=inf;
			if all(isinf(vecLeftDist))
				intLeftPeak = 1;
			else
				[intLeftPeakDist,intLeftPeak]=min(vecLeftDist);
			end
			dblLeftPeakHeight = vecP_V(intLeftPeak);
			
			%calculate prominence of original peak
			%left domain
			intLeftLoc = matPeakDomain(intPeak,2);
			[intLeftTroughLoc,dblLeftTrough] = findtrough(vecV,intLeftLoc,-1);
			matPeakDomain(intPeak,2) = intLeftTroughLoc;
			
			%prominence
			dblOrigProm = dblHeight-dblLeftTrough;
			
			%calculate prominence of merged peak
			intLeftLoc = matPeakDomain(intLeftPeak,2);
			[intLeftTroughLoc,dblLeftTrough] = findtrough(vecV,intLeftLoc,-1);
			dblNewProm = dblHeight-dblLeftTrough;
			
			%decide to merge or not
			if dblLeftPeakHeight >= dblHeight || dblOrigProm >= dblNewProm %prominence increase must be >50% ?  dblNewProm < dblOrigProm*dblDeltaPromThresh%
				%complete
				boolLeftComplete = true;
				
				%reset domain edge to lowest trough in left domain
				vecRange=matPeakDomain(intPeak,2):matPeakDomain(intPeak,1);
				[dummy,intEdge]=min(vecV(vecRange));
				matPeakDomain(intPeak,2) = intEdge+matPeakDomain(intPeak,2)-1;
			else
				%merge and continue
				indConsidered(intLeftPeak) = true;
				indProcessed(intLeftPeak) = true;
				matPeakDomain(intPeak,2) = vecP_L(intLeftPeak);
			end
		end
		
		%% right
		boolRightComplete = false;
		indConsidered = false(size(vecP_T));
		while ~boolRightComplete && ~all(indConsidered)
			%find nearest peak outside domain
			vecRightDist = matPeakDomain(:,1) - intPeakLoc;
			vecRightDist(indConsidered | vecRightDist<=0)=inf;
			if all(isinf(vecRightDist))
				intRightPeak = numel(vecP_V);
			else
				[intRightPeakDist,intRightPeak]=min(vecRightDist);
			end
			dblRightPeakHeight = vecP_V(intRightPeak);
			
			%right domain
			intRightLoc = matPeakDomain(intPeak,3);
			[intRightTroughOldLoc,dblRightTrough] = findtrough(vecV,intRightLoc,+1);
			matPeakDomain(intPeak,3) = intRightTroughOldLoc;
			
			%prominence
			dblOrigProm = dblHeight-dblRightTrough;
			
			%calculate prominence of merged peak
			intRightLoc = matPeakDomain(intRightPeak,3);
			[intRightTroughLoc,dblRightTrough] = findtrough(vecV,intRightLoc,+1);
			dblNewProm = dblHeight-dblRightTrough;
			
			%decide to merge or not
			if dblRightPeakHeight >= dblHeight || dblOrigProm >= dblNewProm %prominence increase must be >50% ?
				%complete
				boolRightComplete = true;
				
				%reset domain edge to lowest trough in right domain
				vecRange=matPeakDomain(intPeak,1):matPeakDomain(intPeak,3);
				[dummy,intEdge]=min(vecV(vecRange));
				matPeakDomain(intPeak,3) = intEdge+matPeakDomain(intPeak,1)-1;
			else
				%merge and continue
				indConsidered(intRightPeak) = true;
				indProcessed(intRightPeak) = true;
				matPeakDomain(intPeak,3) = vecP_L(intRightPeak);
			end
		end
		
		%add complete
		indProcessed(intPeak) = true;
		indKeepPeaks(intPeak) = true;
	end
	
	%create new list of merged peaks
	matPeakDomain = matPeakDomain(indKeepPeaks,:);
end
function [intTrough,dblTrough] = findtrough(vecV,intLoc,intDirection)
	%findtrough Finds nearest trough in leftward (-1) or rightward (+1) direction
	%   [intTrough,dblTrough] = findtrough(vecV,intLoc,intDirection)
	
	if intDirection == -1 %left
		intTrough = nan;
		while isnan(intTrough) && intLoc > 2
			dblDist = vecV(intLoc-1) - vecV(intLoc);
			if dblDist > 0 || intLoc < 3
				intTrough = intLoc;
				break;
			else
				intLoc = intLoc - 1;
			end
		end
		if isnan(intTrough)
			intTrough = 1;
		end
	else
		intTrough = nan;
		intMax = numel(vecV)-1;
		while isnan(intTrough) && intLoc < intMax
			dblDist = vecV(intLoc+1) - vecV(intLoc);
			if dblDist > 0 || intLoc > (intMax-1)
				intTrough = intLoc;
				break;
			else
				intLoc = intLoc + 1;
			end
		end
		if isnan(intTrough)
			intTrough = numel(vecV);
		end
	end
	dblTrough = vecV(intTrough);
end
