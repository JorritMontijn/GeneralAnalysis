function sOut = getClusterQuality(vecSpikeTimes,vecStimOnTime,boolMakePlots)
	%getClusterQuality Calculates ISI violation index and non-stationarity index
	%syntax: sOut = getClusterQuality(vecSpikeTimes,vecStimOnTime,boolMakePlots)
	%	input:
	%	- vecSpikes; spike times
	%	- vecStimOnTime; times of trial starts
	%	- boolMakePlots; set to 0 to suppress plotting
	%
	%Version history:
	%1.0 - June 18 2019
	%	Created by Jorrit Montijn
	
	%% prepare variables
	if ~exist('boolMakePlots','var') || isempty(boolMakePlots)
		boolMakePlots = true;
	end
	intConsiderSpikeDist = 50;
	dblStep = 0.2/1000;
	dblEdge = 5/1000;
	vecWindowEdge_ms = -dblEdge:dblStep:dblEdge;
	vecPlot = vecWindowEdge_ms(2:end) - dblStep/2;
	intBins = numel(vecWindowEdge_ms)-1;
	vecCountsISI = zeros(1,intBins);
	
	%% calculate ISI & trial times
	vecSortedSpikeTimes = sort(vecSpikeTimes,'ascend');
	indConsiderTemplate = false(size(vecSpikeTimes));
	intSpikeNum = numel(vecSpikeTimes);
	vecTrialPerSpike = nan(size(vecSpikeTimes));
	vecTrialStartPerSpike = nan(size(vecSpikeTimes));
	vecTimeInTrial = nan(size(vecSpikeTimes));
	for intSpike=1:numel(vecSpikeTimes)
		%% calculate ISI
		vecConsider = max([1 intSpike-intConsiderSpikeDist]):min([intSpikeNum intSpike+intConsiderSpikeDist]);
		indConsider = indConsiderTemplate;
		indConsider(vecConsider) = true;
		indConsider(intSpike) = false;
		vecConsiderSpikes = vecSortedSpikeTimes(indConsider);
		vecCountsISI = vecCountsISI + histcounts(vecConsiderSpikes,vecWindowEdge_ms+vecSortedSpikeTimes(intSpike));
		
		%% build trial assignment
		vecTrialPerSpike(intSpike) = sum(vecStimOnTime < vecSortedSpikeTimes(intSpike));
		if vecTrialPerSpike(intSpike) > 0
			dblRemTime = vecStimOnTime(vecTrialPerSpike(intSpike));
		else
			dblRemTime = 0;
		end
		vecTrialStartPerSpike(intSpike) = dblRemTime;
		vecTimeInTrial(intSpike) = vecSortedSpikeTimes(intSpike) - dblRemTime;
	end
	
	%% shuffle trials per spike
	intShuffles = 10;
	intTrials = numel(vecTrialPerSpike);
	matShuffledISI = zeros(intShuffles,intBins);
	
	for intIter=1:intShuffles
		vecShuffledTrialStarts = vecTrialStartPerSpike(randperm(intTrials));
		vecShuffleTimes = sort(vecTimeInTrial + vecShuffledTrialStarts,'ascend');
		
		%% calculate ISI
		indConsiderTemplate = false(size(vecShuffleTimes));
		intSpikeNum = numel(vecShuffleTimes);
		for intSpike=1:numel(vecShuffleTimes)
			vecConsider = max([1 intSpike-intConsiderSpikeDist]):min([intSpikeNum intSpike+intConsiderSpikeDist]);
			indConsider = indConsiderTemplate;
			indConsider(vecConsider) = true;
			indConsider(intSpike) = false;
			vecConsiderSpikes = vecShuffleTimes(indConsider);
			matShuffledISI(intIter,:) = matShuffledISI(intIter,:) + histcounts(vecConsiderSpikes,vecWindowEdge_ms+vecShuffleTimes(intSpike));
			
		end
	end
	% calculate violation index
	ind1ms = vecPlot > -1/1000 & vecPlot < 1/1000; 
	ind2ms = vecPlot > -2/1000 & vecPlot < 2/1000 & ~ind1ms; 
	vecShuffViol1ms = sum(matShuffledISI(:,ind1ms),2);
	vecShuffViol2ms = sum(matShuffledISI(:,ind2ms),2);
	dblViol1ms = sum(vecCountsISI(ind1ms));
	dblViol2ms = sum(vecCountsISI(ind2ms));
	
	dblZ1ms = (mean(vecShuffViol1ms) - dblViol1ms) / std(vecShuffViol1ms);
	dblZ2ms = (mean(vecShuffViol2ms) - dblViol2ms) / std(vecShuffViol2ms);
	
	dblViolIdx1ms = normcdf(-dblZ1ms,0,1)*2;
	dblViolIdx2ms = normcdf(-dblZ2ms,0,1)*2;
	
	%% calculate non-stationarity
	dblAUC = sum(vecSortedSpikeTimes);
	dblLinAUC = (max(vecSortedSpikeTimes) * numel(vecSortedSpikeTimes) ) / 2;
	dblNonstationarityIndex = (dblAUC - dblLinAUC) / dblLinAUC;
	
	%% plot?
	if boolMakePlots
		%make maximized figure
		figure
		drawnow;
		jFig = get(handle(gcf), 'JavaFrame');
		jFig.setMaximized(true);
		figure(gcf);
		drawnow;
		
		%plot ISI
		subplot(2,2,1);
		stairs(vecPlot*1000,vecCountsISI);
		ylim([0 max(get(gca,'ylim'))]);
		xlabel('Inter-spike interval (ms)');
		ylabel('Number of spikes (count)');
		title(sprintf('ISI violation index, 1ms=%.3f (Z=%.3f), 2ms=%.3f (Z=%.3f)',dblViolIdx1ms,dblZ1ms,dblViolIdx2ms,dblZ2ms));
		fixfig;
		
		%plot raster
		subplot(2,2,2);
		plotRaster(vecSpikeTimes,vecStimOnTime)
		title(sprintf('Non-stationarity index: %.3f',dblNonstationarityIndex));
		
		%plot shuffled ISI
		vecMeans = mean(matShuffledISI,1);
		vecSD = std(matShuffledISI,[],1);
		subplot(2,2,3);
		errorbar(vecPlot*1000,vecMeans,vecSD)
		ylim([0 max(get(gca,'ylim'))]);
		xlabel('Inter-spike interval (ms)');
		ylabel('Number of spikes (count)');
		fixfig;
		
		%plot non-stationarity
		subplot(2,2,4);
		vecLimX = [0 numel(vecSortedSpikeTimes)];
		vecLimY = [0 vecSortedSpikeTimes(end)];
		hold on
		plot(vecLimX,vecLimY,'--','Color',[0.5 0.5 0.5]);
		plot(vecSortedSpikeTimes,'Color',lines(1));
		hold off
		xlabel('Spike #');
		ylabel('Time (s)');
		xlim(vecLimX);
		ylim(vecLimY);
		fixfig;
		grid off;
	end
	
	%% save
	sOut = struct;
	sOut.dblNonstationarityIndex = dblNonstationarityIndex;
	sOut.dblViolIdx1ms = dblViolIdx1ms;
	sOut.dblViolIdx2ms = dblViolIdx2ms;
	sOut.dblZ1ms = dblZ1ms;
	sOut.dblZ2ms = dblZ2ms;
	
	sOut.vecSortedSpikeTimes = vecSortedSpikeTimes;
	sOut.vecTrialPerSpike = vecTrialPerSpike;
	sOut.vecTrialStartPerSpike = vecTrialStartPerSpike;
	sOut.vecTimeInTrial = vecTimeInTrial;
	
	sOut.vecWindowISI = vecPlot;
	sOut.vecCountsISI = vecCountsISI;
	sOut.matShuffledISI = matShuffledISI;
	
	
end