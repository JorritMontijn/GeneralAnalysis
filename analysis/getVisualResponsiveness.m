function [dblD,vecSS_res,vecSS_tot] = getVisualResponsiveness(vecSpikes,vecTrialStarts,boolPlot)
	%getVisualResponsiveness Calculates reliability of visual response as Cohen's d across trials
	%syntax: [dblD,vecSS_res,vecSS_tot] = getVisualResponsiveness(vecSpikes,vecTrialStarts,boolPlot)
	%	input:
	%	- vecSpikes; spike times (s)
	%	- vecTrialStarts: trial start times (s)
	%	- boolPlot: boolean, set to true to plot output (default: false)
	%
	%	output:
	%	- dblD; Cohen's d (equivalent to d') for visual responsiveness	effect
	%	- vecSS_res: residual sum-of-squares for prediction from training set
	%	- vecSS_tot: total sum-of-squares for prediction assuming no temporally-modulated response
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
	[vecTrialPerSpike,vecTimePerSpike] = getSpikesInTrial(vecSpikes,vecTrialStarts);
	dblTrialDur = median(diff(vecTrialStarts));
	
	%calculate cross-validated R^2 of visual responses across trial repetitions
	indUseSpikes = vecTrialPerSpike>0 & vecTimePerSpike < dblTrialDur;
	vecUseSpikeTimes = vecTimePerSpike(indUseSpikes);
	vecUseSpikeTrials = vecTrialPerSpike(indUseSpikes);
	
	%% k-fold data split
	intFoldK = 10;
	intObs = numel(vecUseSpikeTimes);
	intMaxRep = max(vecUseSpikeTrials);
	vecRepsPerFold = floor(intMaxRep / intFoldK)*ones(intFoldK,1);
	intRemainder = mod(intMaxRep,intFoldK);
	vecRepsPerFold(1:intRemainder) = vecRepsPerFold(1:intRemainder) + 1;
	vecFoldRepStart = cumsum(vecRepsPerFold) - vecRepsPerFold(1) + 1;
	vecFoldRepEnd = cumsum(vecRepsPerFold);
	
	%% run k-folds
	%pre-allocate
	vecSS_res = nan(1,intFoldK);
	vecSS_tot = nan(1,intFoldK);
	%assign data
	indAllObs = vecUseSpikeTrials>0;
	for intThisFold=1:intFoldK
		%get repetitions
		vecTestReps = vecFoldRepStart(intThisFold):vecFoldRepEnd(intThisFold);
		
		%get observations
		vecTestObs = ismember(vecUseSpikeTrials,vecTestReps);
		indTrainObs = indAllObs;
		indTrainObs(vecTestObs) = false;
		
		%assign
		%get training spikes
		vecTrainSpikes = vecUseSpikeTimes(indTrainObs);
		vecTestSpikes = vecUseSpikeTimes(vecTestObs);
		
		%get fractional look-up table for training set
		vecTrainSpikeTimes = [0 sort(vecTrainSpikes(:),'ascend')' dblTrialDur];
		vecTrainSpikeFracs = linspace(0,1,numel(vecTrainSpikeTimes));
		
		%get real fractions for training set
		vecTestSpikeTimes = sort(vecTestSpikes(:),'ascend')';
		vecTestSpikeFracs = linspace(0,1,numel(vecTestSpikeTimes));
		
		%get predicted fractions from training set and linear function
		vecPredictedFractionFromTrain = interp1(vecTrainSpikeTimes,vecTrainSpikeFracs,vecTestSpikeTimes);
		vecPredictedFractionFromLinear = vecTestSpikeTimes./dblTrialDur;
		
		%calculate difference from train and linear
		vecDiffTrain = abs(vecTestSpikeFracs - vecPredictedFractionFromTrain).^2;
		vecDiffLinear = abs(vecTestSpikeFracs - vecPredictedFractionFromLinear).^2;
		
		%save sum-of-squares error
		vecSS_res(intThisFold) = sum(vecDiffTrain(:));
		vecSS_tot(intThisFold) = sum(vecDiffLinear(:));
	end
	
	%% calculate measure of effect size, for equal n, d' = Cohen's d
	dblD = (mean(vecSS_tot) - mean(vecSS_res)) / sqrt( (var(vecSS_tot) + var(vecSS_res))/2);
	
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
		scatter(vecTestSpikeTimes,vecTestSpikeFracs)
		title(sprintf('Test data; fold %d',intThisFold));
		xlabel('Time from trial start (s)');
		ylabel('Fractional position of spike in trial');
		fixfig
		
		subplot(2,3,2)
		scatter(vecTestSpikeTimes,vecPredictedFractionFromTrain)
		title(sprintf('%d-fold CV, Prediction from training data',intFoldK))
		xlabel('Time from trial start (s)');
		ylabel('Fractional position of spike in trial');
		fixfig
		
		subplot(2,3,3)
		scatter(vecTestSpikeTimes,vecPredictedFractionFromLinear)
		title(sprintf('%d-fold CV, Prediction from linear data',intFoldK))
		xlabel('Time from trial start (s)');
		ylabel('Fractional position of spike in trial');
		fixfig
		
		subplot(2,3,4)
		scatter(vecTestSpikeTimes,vecDiffTrain)
		xlabel('Time from trial start (s)');
		ylabel('Squared error (residual)');
		title(sprintf('Fold %d, train/test difference',intThisFold));
		dblMaxErrorVal = max(cat(1,vecDiffTrain(:),vecDiffLinear(:)));
		ylim([0 dblMaxErrorVal]);
		fixfig
		
		subplot(2,3,5)
		scatter(vecTestSpikeTimes,vecDiffLinear)
		xlabel('Time from trial start (s)');
		ylabel('Squared error (total)');
		title(sprintf('Fold %d, linear/test difference',intThisFold));
		ylim([0 dblMaxErrorVal]);
		fixfig
		
		subplot(2,3,6)
		dblMaxSSVal = max(cat(1,vecSS_res(:),vecSS_tot(:)));
		hold on
		plot([0 dblMaxSSVal],[0 dblMaxSSVal],'--','Color',[0.7 0.7 0.7]);
		scatter(vecSS_res,vecSS_tot,'bx');
		hold off
		xlabel('Residual sum of squares');
		ylabel('Total sum of squares');
		xlim([0 dblMaxSSVal]);
		ylim([0 dblMaxSSVal]);
		fixfig
		grid off;
		title(sprintf('Cohen''s d: %.3f',dblD));
	end
end

