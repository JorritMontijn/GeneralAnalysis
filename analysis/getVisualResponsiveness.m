function [dblZ,vecInterpT,vecZ,matDiffTest,dblHzD,dblP] = getVisualResponsiveness(vecSpikeTimes,vecTrialStarts,boolPlot,dblUseMaxDur,intShuffNum,intFoldK)
	%getVisualResponsiveness Calculates reliability of visual response as Cohen's d across trials
	%syntax: [dblZ,dblHzD,vecInterpT,vecZ,matDiffTest,dblP] = getVisualResponsiveness(vecSpikeTimes,vecTrialStarts,boolPlot,dblUseMaxDur)
	%	input:
	%	- vecSpikeTimes [S x 1]: spike times (s)
	%	- vecTrialStarts [T x 1]: stimulus on times (s), or [T x 2] including stimulus off times
	%	- boolPlot: boolean, set to true to plot output (default: false)
	%	- dblUseMaxDur: float (s), ignore all spikes beyond this duration after stimulus onset
	%								[default: median of trial start to trial start]
	%	- intShuffNum: integer, number of shuffle iterations (default: 250)
	%	- intFoldK: integer, number of folds for data splitting (default: 10)
	%
	%	output:
	%	- dblZ; Z-score-like visual responsiveness effect
	%	- vecInterpT: timestamps of interpolated z-scores
	%	- vecZ; z-score for all time points corresponding to vecInterpT
	%	- matDiffTest: total sum-of-squares for prediction assuming no temporally-modulated response
	%	- dblHzD; Cohen's d for mean rate during stimulus presence and absence (requires stimulus offset times)
	%	- dblP: p-value corresponding to z-score
	%
	%Version history:
	%1.0 - June 27 2019
	%	Created by Jorrit Montijn
	
	%% prep data
	%get boolPlot
	if ~exist('boolPlot','var') || isempty(boolPlot)
		boolPlot = false;
	end
	
	%get spike times in trials
	[vecTrialPerSpike,vecTimePerSpike] = getSpikesInTrial(vecSpikeTimes,vecTrialStarts(:,1));
	if ~exist('dblUseMaxDur','var') || isempty(dblUseMaxDur)
		dblUseMaxDur = median(diff(vecTrialStarts(:,1)));
	end
	
	%get boolPlot
	if ~exist('intShuffNum','var') || isempty(intShuffNum)
		intShuffNum = 250;
	end
	
	%get spike times in trials
	if ~exist('intFoldK','var') || isempty(intFoldK)
		intFoldK = 10;
	end
	
	%calculate stim/base difference?
	boolActDiff = false;
	dblHzD = nan;
	if size(vecTrialStarts,2) == 2
		boolActDiff = true;
		vecStimDur = vecTrialStarts(:,2) - vecTrialStarts(:,1);
	end
	
	%calculate cross-validated R^2 of visual responses across trial repetitions
	indUseSpikes = vecTrialPerSpike>0 & vecTimePerSpike < dblUseMaxDur;
	vecUseSpikeTimes = vecTimePerSpike(indUseSpikes);
	vecUseSpikeTrials = vecTrialPerSpike(indUseSpikes);
	
	%% k-fold data split
	intObs = numel(vecUseSpikeTimes);
	intMaxRep = max(vecUseSpikeTrials);
	vecRepsPerFold = floor(intMaxRep / intFoldK)*ones(intFoldK,1);
	intRemainder = mod(intMaxRep,intFoldK);
	vecRepsPerFold(1:intRemainder) = vecRepsPerFold(1:intRemainder) + 1;
	vecFoldRepStart = cumsum(vecRepsPerFold) - vecRepsPerFold(1) + 1;
	vecFoldRepEnd = cumsum(vecRepsPerFold);
	
	%% prepare interpolation points
	vecInterpT = unique(sort(vecUseSpikeTimes,'ascend'));
	intInterp = numel(vecInterpT);
	
	%% run k-folds & shuffles
	%pre-allocate
	if boolActDiff
		vecStimAct = nan(1,intFoldK*intShuffNum);
		vecBaseAct = nan(1,intFoldK*intShuffNum);
	end
	matDiffTest = nan(intInterp,intFoldK*intShuffNum);
	
	%run shuffles
	intIter=0;
	for intShuffIter=1:intShuffNum
		vecShuffledReps = randperm(intMaxRep);
		
		%run folds
		for intThisFold=1:intFoldK
			%increment iter
			intIter=intIter+1;
			
			%get repetitions
			vecTestReps = vecShuffledReps(vecFoldRepStart(intThisFold):vecFoldRepEnd(intThisFold));
			
			%get observations
			vecTestObs = ismember(vecUseSpikeTrials,vecTestReps);
			
			%get spikes
			vecTestSpikes = unique(vecUseSpikeTimes(vecTestObs));
			
			%get real fractions for training set
			vecTestSpikeTimes = sort([0;vecTestSpikes(:);dblUseMaxDur],'ascend')';
			vecTestSpikeFracs = linspace(0,1,numel(vecTestSpikeTimes));
			vecTestFracInterp = interp1(vecTestSpikeTimes,vecTestSpikeFracs,vecInterpT);
			
			%get linear fractions
			vecPredictedFractionFromLinear = vecInterpT./dblUseMaxDur;
			
			%assign data
			matDiffTest(:,intIter) = vecTestFracInterp - vecPredictedFractionFromLinear;
			
			%calculate spikes during trial and during ITI
			if boolActDiff
				intTestNum = numel(vecTestReps);
				vecBaseHz = nan(1,intTestNum);
				vecStimHz = nan(1,intTestNum);
				for intStim=1:intTestNum
					%get test trial and spikes
					intTestTrial = vecTestReps(intStim);
					vecTempSpikes = vecUseSpikeTimes(vecUseSpikeTrials==intTestTrial);
					%calculate stim times for this trial
					dblStimOff = vecStimDur(intTestTrial);
					dblPostStimDur = dblUseMaxDur - dblStimOff;
					
					%assign data
					vecStimHz(intStim) = sum(vecTempSpikes < dblStimOff)/dblStimOff;
					vecBaseHz(intStim) = sum(vecTempSpikes > dblStimOff)/dblPostStimDur;
				end
				%save data
				vecStimAct(intIter) = mean(vecStimHz);
				vecBaseAct(intIter) = mean(vecBaseHz);
			end
		end
	end
	
	%% calculate measure of effect size, for equal n, d' = Cohen's d
	%get z-score
	vecZ = mean(matDiffTest,2) ./ std(matDiffTest,[],2);
	dblRemEdgeSecs = 0.02;
	indKeep = vecInterpT > dblRemEdgeSecs & vecInterpT < (dblUseMaxDur-dblRemEdgeSecs);
	vecUseZ = vecZ;
	vecUseZ(~indKeep) = 0;
	
	%get max values & remove first and last peaks
	[vecPosVals,vecPosPeakLocs]= findpeaks(vecUseZ);
	[vecNegVals,vecNegPeakLocs]= findpeaks(-vecUseZ);
	vecAllVals = cat(1,vecPosVals,vecNegVals);
	vecAllPeakLocs = cat(1,vecPosPeakLocs,vecNegPeakLocs);
	
	%find highest peak and retrieve value
	[dummy,intLoc]= max(abs(vecAllVals));
	intInterpLoc = vecAllPeakLocs(intLoc);
	dblMaxZTime = vecInterpT(intInterpLoc);
	dblZ = vecZ(intInterpLoc);
	dblP=1-(normcdf(abs(dblZ))-normcdf(-abs(dblZ)));
	
	if boolActDiff
		dblHzD = abs(mean(vecStimAct) - mean(vecBaseAct)) / sqrt( (var(vecStimAct) + var(vecBaseAct))/2);
	end
	
	%% plot
	if boolPlot
		%make maximized figure
		figure
		drawnow;
		jFig = get(handle(gcf), 'JavaFrame');
		jFig.setMaximized(true);
		figure(gcf);
		drawnow;
		
		%plot
		subplot(2,3,1)
		sOpt = struct;
		sOpt.handleFig =-1;
		[vecMean,vecSEM,vecWindowBinCenters] = doPEP(vecSpikeTimes,0:0.1:dblUseMaxDur,vecTrialStarts(:,1),sOpt);
		errorbar(vecWindowBinCenters,vecMean,vecSEM);
		ylim([0 max(get(gca,'ylim'))]);
		title(sprintf('Mean spiking over trials'));
		xlabel('Time from trial start (s)');
		ylabel('Mean spiking rate (Hz)');
		fixfig
		
		subplot(2,3,2)
		plot(vecInterpT,vecTestFracInterp)
		title(sprintf('Real data; fold %d',intFoldK));
		xlabel('Time from trial start (s)');
		ylabel('Fractional position of spike in trial');
		fixfig
		
		subplot(2,3,3)
		plot(vecInterpT,vecPredictedFractionFromLinear)
		title(sprintf('Random baseline, fold %d',intFoldK))
		xlabel('Time from trial start (s)');
		ylabel('Fractional position of spike in trial');
		fixfig
		
		subplot(2,3,4)
		hold on
		plot(vecInterpT,matDiffTest(:,intFoldK));
		xlabel('Time  from trial start (s)');
		ylabel('Offset of data from linear (frac pos)');
		title(sprintf('Fold %d, diff data/baseline',intFoldK));
		fixfig
		
		subplot(2,3,5)
		cla;
		matC = redbluepurple(intFoldK);
		intPlotIters = min([size(matDiffTest,2) 20]);
		hold all
		for intIter=1:intPlotIters
			intFold=mod(intIter,intFoldK);
			if intFold==0,intFold=intFoldK;end
			plot(vecInterpT,matDiffTest(:,intIter),'Color',matC(intFold,:));
		end
		hold off
		xlabel('Time  from trial start (s)');
		ylabel('Offset of data from linear (s)');
		title(sprintf('1-%d, diff data/baseline',intPlotIters));
		fixfig
		
		subplot(2,3,6)
		plot(vecInterpT,vecZ);
		hold on
		scatter(dblMaxZTime,dblZ,'kx');
		hold off
		xlabel('Time  from trial start (s)');
		ylabel('Z-score');
		title(sprintf('Max-Z=%.3f (p=%.3f), d(Hz)=%.3f',dblZ,dblP,dblHzD));
		fixfig
		
	end
end

