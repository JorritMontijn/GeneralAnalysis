function plotRaster(vecSpikes,vecTrialStarts)
	%plotRaster Makes raster plot
	%syntax: plotRaster(vecSpikes,vecTrialStarts)
	%	input:
	%	- vecSpikes; spike times (s)
	%	- vecTrialStarts: trial start times (s)
	%
	%Version history:
	%1.0 - June 18 2019
	%	Created by Jorrit Montijn
	
	
	%sort spikes
	vecSortedSpikes = sort(vecSpikes,'ascend');
	vecSpikeInTrial = nan(size(vecSpikes));
	vecTimeInTrial = nan(size(vecSpikes));
	for intSpike=1:numel(vecSpikes)
		%% build trial assignment
		vecSpikeInTrial(intSpike) = sum(vecTrialStarts < vecSortedSpikes(intSpike));
		if vecSpikeInTrial(intSpike) > 0
			dblRemTime = vecTrialStarts(vecSpikeInTrial(intSpike));
		else
			dblRemTime = 0;
		end
		vecTimeInTrial(intSpike) = vecSortedSpikes(intSpike) - dblRemTime;
	end
	
	%plot per trial
	hold all;
	for intTrial=1:numel(vecTrialStarts)
		vecTimes = vecTimeInTrial(vecSpikeInTrial==intTrial);
		line([vecTimes(:)';vecTimes(:)'],[intTrial*ones(1,numel(vecTimes))-0.5;intTrial*ones(1,numel(vecTimes))+0.5],'Color','k','LineWidth',1.5);
	end
	hold off
	
	%set fig props
	xlabel('Time from trial start (s)');
	ylabel('Trial #');
	fixfig;
end

