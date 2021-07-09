function [dblStartT,intFlagOut,vecTotErr] = SyncEvents(vecRefT,vecSignalT,boolUsePath,boolVerbose)
	%SyncEvents Syncs events
	%[dblStartT,intFlagOut,vecTotErr] = SyncEvents(vecRefT,vecSignalT,boolVerbose)
	%
	%inputs:
	%vecRefT: [1 x n] timestamp vector
	%vecSignalT: [1 x p] timestamp vector where p>n
	%
	%outputs:
	%vecReferencedSignal is a vector of event times from vecSignalT that
	%best match the inter-event times in vecRefT
	%
	%output flags:
	%-1: algorithms disagree
	%0: low certainty
	%1: agreement & high certainty
	
	%% prepro
	if ~exist('boolUsePath','var') || isempty(boolUsePath)
		boolUsePath = false;
	end
	if ~exist('boolVerbose','var') || isempty(boolVerbose)
		boolVerbose = true;
	end
	
	%% linear alignment algorithm
	%go through all possibilities
	intPossT = numel(vecSignalT);
	vecMaxError = zeros(1,intPossT);
	vecLastError = zeros(1,intPossT);
	vecMeanError = zeros(1,intPossT);
	for intStartIdx=1:intPossT
		dblT0 = vecRefT(1)-vecSignalT(intStartIdx);
		%find errors
		intNumS = numel(vecRefT);
		vecErrT = zeros(1,intNumS);
		for intStim=1:intNumS
			vecErrT(intStim) = min(abs(vecSignalT+dblT0-vecRefT(intStim)));
		end
		vecMeanError(intStartIdx) = mean(abs(vecErrT));
		vecMaxError(intStartIdx) = max(vecErrT).^2;
		vecLastError(intStartIdx) = vecErrT(end).^2;
	end
	vecTotErr = vecMaxError + vecLastError + vecMeanError;
	vecSoftmin = softmax(-vecTotErr);
	[vecP,vecI]=findmax(vecSoftmin,10);
	dblAlignmentCertainty = vecP(1)/sum(vecP);
	intStartStim = vecI(1);
	
	%most likely
	if ~boolUsePath
		dblStartT=vecSignalT(intStartStim);
		intFlagOut = vecP(1)>0.5;
		return;
	end
	
	%% path-based algorithm
	%calculate minimum hop distances
	dblMedian = median(diff(vecRefT(:)));
	matDiffT = vecSignalT-vecSignalT';
	
	intStims = numel(vecRefT);
	intPaths = numel(vecSignalT)-intStims-1;
	vecPathError = nan(1,intPaths);
	vecStartError = nan(1,intPaths);
	vecEndError = nan(1,intPaths);
	
	for intPath=1:intPaths
		%%
		intI = intPath;
		
		boolEnd=false;
		intC=0;
		vecStartIdx = nan(1,numel(vecSignalT));
		vecHopDist = nan(1,numel(vecSignalT));
		while ~boolEnd
			intC = intC + 1;
			vecdT = matDiffT(intI,:);
			vecStartIdx(intC) = intI;
			[dblV,intI_local]=min(abs(vecdT((intI+1):end)-dblMedian));
			intI = intI_local + intI;
			vecHopDist(intC) = vecdT(intI);
			if intI >= (numel(vecSignalT)-1)
				boolEnd=true;
			end
		end
		
		%calculate match at start
		intUseStartStims = 20;
		vecSteps = 1:intUseStartStims;
		vecHopError = vecHopDist(vecSteps) + vecRefT(vecSteps) - vecRefT(vecSteps+1);
		if any(isnan(vecHopError)),break;end
		vecStartError(intPath) = sum(vecHopError.^2);
	end
	
	%assign best start stim
	intPathsB = sum(~isnan(vecStartError));
	vecStartError((intPathsB+1):end) = [];
	vecSoftmin = softmax(-vecStartError);
	[vecPathPB,vecPathIB]=findmax(vecSoftmin,10);
	dblPathAlignmentCertaintyB = vecPathPB(1)/sum(vecPathPB);
	intStartPath = vecPathIB(1);
	dblStartT = vecSignalT(intStartPath);
	
	%% check if algorithms agree
	if intStartPath ~= intStartStim || dblPathAlignmentCertaintyB < 0.5 || boolVerbose
		%stim's certainty of best path
		intStimsPath = find(vecI==intStartPath);
		if isempty(intStimsPath)
			dblStimsPathCertainty = 0;
		else
			dblStimsPathCertainty = vecP(intStimsPath)/sum(vecP);
		end
		
		%path's certainty of best stim
		intPathsStim = find(vecPathIB==intStartStim);
		if isempty(intPathsStim)
			dblPathsStimCertainty = 0;
		else
			dblPathsStimCertainty = vecPathPB(intPathsStim)/sum(vecPathPB);
		end
		
		fprintf('Path algorithm chose stim %d (%.1f%% certainty; stim algorithm gave it %.1f%%); stim chose %d (%.1f%% certainty; path algo gave it %.1f%%)\n',...
			intStartPath,dblPathAlignmentCertaintyB*100,dblStimsPathCertainty*100,...
			intStartStim,dblAlignmentCertainty*100,dblPathsStimCertainty*100)
	end
	
	%% output flag
	if intStartPath ~= intStartStim
		intFlagOut = -1;
	elseif dblPathAlignmentCertaintyB < 0.5
		intFlagOut = 0;
	else
		intFlagOut = 1;
	end
end
