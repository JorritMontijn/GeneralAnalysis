function [dblClustP,sClustPos,sClustNeg] = clustertest(matCond1,matCond2,intReps,vecT,dblClusterCutOff)
	%clustertest Cluster-based statistical test for paired data; Maris and Oostenveld (2007)
	%   [dblClustP,sClustPos,sClustNeg] = clustertest(matCond1,matCond2,intReps,vecT,dblClusterCutOff)
	
	%% check inputs
	if nargin < 3
		intReps = [];
	end
	if nargin<4
		vecT = [];
	end
	if nargin<5
		dblClusterCutOff = [];
	end
	
	%% run
	sClustPos = ez_clusterstat_time(matCond1,matCond2,intReps,vecT,dblClusterCutOff);
	sClustNeg = ez_clusterstat_time(matCond2,matCond1,intReps,vecT,dblClusterCutOff);
	vecPosP = cell2vec({sClustPos.p});
	vecNegP = cell2vec({sClustNeg.p});
	dblClustP=min(1,min([min(vecPosP) min(vecNegP)]*2)); %x2 for Bonferroni correction
end
function clusters = ez_clusterstat_time(matCond1,matCond2,intReps,vecT,dblClusterCutOff)
	%ez_clusterstat_time Cluster-based statistical test for paired data; Maris and Oostenveld (2007)
	%clusters = ez_clusterstat_time(matCond1,matCond2,intReps,vecT,dblClusterCutOff)
	%
	%Inputs:
	%matCond1 and matCond2: 2d matrices with dimensions [trials, time]
	%	Any missing data should be converted to NaNs before running this script
	%	These are the two conditions you want to compare e.g. figure and ground
	%intReps = number of bootstraps (default=1000)
	%vecT = time vector (only used for plotting). If set to true, it will generate a 1:n t vector
	%dblClusterCutOff = alpha value for setting cluster boundaries
	%
	%Outputs:
	%	clusters = structure containing:
	%		map: logical map of significant time points for each significant cluster
	%		p: quantile-based p-value
	%If there are no significant clusters, it will output the lowest p-value of all non-significant
	%clusters (if any). If no clusters are detected, it will default to p=1
	%
	%Carries out cluster-based staistical test for paired data as described by
	%Maris and Oostenveld (2007). Designed to work with baseline-corrected
	%time-based data which has only positive clusters (i.e. the test is
	%one-tailed, H1: cond1 > cond2)
	%
	%The scrambling occurs by switching condition labels for each electrode.
	%Electrode pairings are maintained (the data is assumed to be paired).
	%
	%Created by Matt Self, 2022
	%Edited by Jorrit Montijn, 2023-11-24
	
	%APPROACH
	%1: MAke a permutation surrogate of the data by randomly shuffling conditions for
	%each electrode to mak
	%2: Calculate the t- and p-statistic between cond1' and
	%   cond2' using a paired t-test for every sample.
	%3: Cluster the tmap after thresholding with the pmap
	%4: Sum-up the absolute t-vals from each cluster to get a distribution
	%   of summed cluster t-values.  We take the maximum cluster t-value
	%   as the bootstrap statistic as this controls for multiple comparisons.
	%5: Do this 1000 times to work out the critical cluster maximum t-value for the 5% familywise alpha
	%   level
	%6: Apply the same procedure to the real data, clusters falling above the
	%   critical value are significant.
	%7: Mark these clusters in a graph
	
	%% check inputs
	if ~exist('intReps','var') || isempty(intReps)
		intReps = 1000;
	elseif intReps < 2
		error([mfilename ':InputError'],'Number of bootstraps cannot be <2');
	end
	if ~exist('vecT','var') || isempty(vecT)
		boolPlotFig = false;
		vecT = [];
	elseif length(vecT) == size(matCond1,1)
		boolPlotFig = true;
	elseif isscalar(vecT) && vecT==1
		boolPlotFig = true;
		vecT = 1:size(matCond1,2);
	end
	if ~exist('dblClusterCutOff','var') || isempty(dblClusterCutOff)
		dblClusterCutOff = 0.05;
	end
	
	%% Make a joint distribution contiang the data from both conditions
	matAggregateTrials = cat(1,matCond1,matCond2);
	intTrials1 = size(matCond1,1);
	intTrials2 = size(matCond2,1);
	intTotTrials = intTrials1+intTrials2;
	intSampNum = size(matCond1,2);
	
	%% permutation stats
	tmax = zeros(intReps,1);
	for s = 1:intReps
		
		%Randomly permute the conditions
		%E.g. either swap or do not swap the conditions for each electrode
		vecUseRand1 = randi(intTotTrials,[1,intTrials1]);
		vecUseRand2 = randi(intTotTrials,[1,intTrials2]);
			
		matTrace1_Rand = matAggregateTrials(vecUseRand1,:);
		matTrace2_Rand = matAggregateTrials(vecUseRand2,:);
			
		%PErform the t-test
		[~,pmap,~,stats] = ttest2(matTrace1_Rand,matTrace2_Rand,'dim',1);
		tmap = stats.tstat;
		
		%Threshold with the pmap into positive clusters
		tmap_pos = zeros(size(tmap));
		tmap_pos(tmap>0&pmap<dblClusterCutOff) = tmap(tmap>0&pmap<dblClusterCutOff);
		
		%Perform clustering
		%get labeled map via bwconncomp
		blobinfo = bwconncomp(tmap_pos);
		nblobs = blobinfo.NumObjects;
		if nblobs>0
			clustsum   = zeros(1,nblobs);
			for i=1:nblobs
				clustsum(i) = sum(tmap(blobinfo.PixelIdxList{i}));
			end
			tmax(s,1) = max(abs(clustsum));
		end
	end
	
	
	%% Calculate the maximum cluster statistic
	J = sort(tmax);
	%95th percentile for one-tailed test
	percentile = min(intReps,max(1,round(intReps.*(1-dblClusterCutOff))));
	%This is the critical vlaue of maximum t
	cluscrit = J(percentile);
	
	%% Now cluster the real data and check to see whether each cluster was significant
	%PErform the t-test
	[~,pmap,~,stats] = ttest2(matCond1,matCond2,'dim',1);
	tmap = stats.tstat;
	
	%% Cluster level correction
	%Threshold with the pmap
	tmap_pos = zeros(size(tmap));
	tmap_pos(tmap>0&pmap<dblClusterCutOff) = tmap(tmap>0&pmap<dblClusterCutOff);
	
	%Intiialise outputs
	clusters = [];
	cc = 0;
	
	% get labeled map
	blobinfo = bwconncomp(tmap_pos);
	nblobs = blobinfo.NumObjects;
	if nblobs>0
		clustsum   = zeros(1,nblobs);
		for i=1:nblobs
			clustsum(i)   = sum(tmap(blobinfo.PixelIdxList{i}));
		end
		
		%Clusters larger than threshold
		clustix = find(abs(clustsum)>=cluscrit);
		if ~isempty(clustsum)
			if isempty(clustix)
				[thisclustsum,clustix] = max(abs(clustsum));
				cc = cc+1;
				clusters(cc).map = zeros(intSampNum,1);
				%get quantile position of cluster in random data
				clusters(cc).p = 1-sum(thisclustsum>J)/(numel(J)+1);
				clusters(cc).pmap = pmap;
				clusters(cc).tmap = tmap;
				clusters(cc).clustsum = thisclustsum;
			else
				for j = clustix
					buf = zeros(intSampNum,1);
					buf(blobinfo.PixelIdxList{j}) = 1;
					cc = cc+1;
					clusters(cc).map = buf;
					%get quantile position of cluster in random data
					clusters(cc).p = 1-sum(clustsum(j)>J)/(numel(J)+1);
					clusters(cc).pmap = pmap;
					clusters(cc).tmap = tmap;
					clusters(cc).clustsum = clustsum(j);
				end
			end
		else
			cc = cc+1;
			clusters(cc).map = zeros(intSampNum,1);
			clusters(cc).p = 1;
			clusters(cc).pmap = pmap;
			clusters(cc).tmap = tmap;
			clusters(cc).clustsum = 0;
		end
	else
		cc = cc+1;
		clusters(cc).map = zeros(intSampNum,1);
		clusters(cc).p = 1;
		clusters(cc).pmap = pmap;
		clusters(cc).tmap = tmap;
		clusters(cc).clustsum = 0;
	end
	
	if boolPlotFig
		
		figure
		plot(vecT,log10(pmap)),hold on
		title('Uncorrected stats'),ylabel('log10(P)')
		
		%Mark significant clusters on map
		figure
		conddiff = nanmean(matCond1-matCond2,1);
		plot(vecT,conddiff,'k','LineWidth',2),hold on
		Y = get(gca,'YLim');
		for j = 1:length(clusters)
			st = find(clusters(j).map,1,'first');
			ed = find(clusters(j).map,1,'last');
			if ~isempty(st) & ~isempty(ed)
				fill([vecT(st) vecT(st) vecT(ed) vecT(ed)],[Y(1) Y(2) Y(2) Y(1)],'g')
			end
		end
		hold on,plot(vecT,conddiff,'k','LineWidth',2)
		title('Significant Clusters')
		
	end
end