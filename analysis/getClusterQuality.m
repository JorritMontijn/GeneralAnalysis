function sOut = getClusterQuality(vecSpikeTimes,boolMakePlots)
	%getClusterQuality Calculates ISI violation index and non-stationarity index
	%syntax: sOut = getClusterQuality(vecSpikeTimes,boolMakePlots)
	%	input:
	%	- vecSpikes; spike times
	%	- boolMakePlots; set to 0 to suppress plotting
	%
	%Version history:
	%1.0 - 18 June 2019
	%	Created by Jorrit Montijn
	%2.0 - 2 Dec 2019
	%	Replaced shuffling by exact expectation, assuming stationary
	%	Poisson rates. Removed trial-based data and raster plot. 
	%	Vast improvement in computation time [by JM] 
	
	%% prepare variables
	if ~exist('boolMakePlots','var') || isempty(boolMakePlots)
		boolMakePlots = true;
	end
	intConsiderSpikeDist = round(max([(numel(vecSpikeTimes)/range(vecSpikeTimes)) 50]));
	dblStep = 0.2/1000;
	dblEdge = 5/1000;
	vecWindowEdge_ms = -dblEdge:dblStep:dblEdge;
	vecPlot = vecWindowEdge_ms(2:end) - dblStep/2;
	intBins = numel(vecWindowEdge_ms)-1;
	vecRealCounts = zeros(1,intBins);
	
	%% calculate ISI & trial times
	vecSortedSpikeTimes = sort(vecSpikeTimes,'ascend') - min(vecSpikeTimes);
	indConsiderTemplate = false(size(vecSpikeTimes));
	intSpikeNum = numel(vecSpikeTimes);
	parfor intSpike=1:numel(vecSpikeTimes)
		%% calculate hi-def ACG
		vecConsider = max([1 intSpike-intConsiderSpikeDist]):min([intSpikeNum intSpike+intConsiderSpikeDist]);
		indConsider = indConsiderTemplate;
		indConsider(vecConsider) = true;
		indConsider(intSpike) = false;
		vecConsiderSpikes = vecSortedSpikeTimes(indConsider);
		vecRealCounts = vecRealCounts + histcounts(vecConsiderSpikes,vecWindowEdge_ms+vecSortedSpikeTimes(intSpike));
	end
	
	%% get random expectancy
	dblRandLambda = ((numel(vecSortedSpikeTimes).^2)*dblStep)/range(vecSortedSpikeTimes);
	dblCritVal = dblRandLambda*0.05;
	vecContamination = vecRealCounts/dblRandLambda;
	vecPoissonProb = poisscdf(vecRealCounts,dblCritVal);
	
	%get borders
	ind1ms = vecWindowEdge_ms > -0.001 & vecWindowEdge_ms < 0.001;
	ind2ms = vecWindowEdge_ms > -0.002 & vecWindowEdge_ms < 0.002 & ~ind1ms;
	
	% calculate violation index
	dblViolIdx1ms = mean(vecContamination(ind1ms));
	dblViolIdx2ms = mean(vecContamination(ind2ms));
	dblCdfPoisson1ms = mean(vecPoissonProb(ind1ms));
	dblCdfPoisson2ms = mean(vecPoissonProb(ind2ms));
	
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
		hold on
		stairs(vecPlot*1000,vecRealCounts);
		plot(vecPlot*1000,dblRandLambda*ones(size(vecPlot)),'r--')
		hold off
		ylim([0 max(get(gca,'ylim'))]);
		xlabel('Inter-spike interval (ms)');
		ylabel('Number of spikes (count)');
		title(sprintf('Contamination, 1ms=%.3f (cdf(P)=%.3f), 2ms=%.3f (cdf(P)=%.3f)',dblViolIdx1ms,dblCdfPoisson1ms,dblViolIdx2ms,dblCdfPoisson2ms));
		fixfig;
		
		%plot non-stationarity
		subplot(2,2,2);
		vecLimX = [0 numel(vecSortedSpikeTimes)];
		vecLimY = [0 vecSortedSpikeTimes(end)];
		hold on
		plot(vecLimX,vecLimY,'--','Color',[0.5 0.5 0.5]);
		plot(vecSortedSpikeTimes,'Color',lines(1));
		hold off
		xlabel('Spike #');
		ylabel('Time in recording (s)');
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
	sOut.dblCdfPoisson1ms = dblCdfPoisson1ms;
	sOut.dblCdfPoisson2ms = dblCdfPoisson2ms;
	
	sOut.vecWindowISI = vecPlot;
	sOut.vecCountsISI = vecRealCounts;
	
end