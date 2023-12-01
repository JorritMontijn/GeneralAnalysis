function clusters = ez_clusterstat_time(cond1,cond2,reps,t)
	%ez_clusterstat_time Cluster-based statistical test for paired data; Maris and Oostenveld (2007)
	%clusters = ez_clusterstat_time(cond1,cond2,reps,t)
	%
	%Inputs:
	%cond1 and cond2: 2d matrices with dimensions [trials, time]
	%	Any missing data should be converted to NaNs before running this script
	%	These are the two conditions you want to compare e.g. figure and ground
	%reps = number of bootstraps (default=1000)
	%t = time vector (only used for plotting). If set to true, it will generate a 1:n t vector
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
	if nargin < 3 || isempty(reps)
		reps = 1000;
	elseif reps < 2
		error([mfilename ':InputError'],'Number of bootstraps cannot be <2');
	end
	if nargin<4 || isempty(t)
		figon = false;
		t = [];
	elseif length(t) == size(cond1,1)
		figon = true;
	elseif isscalar(t) && t==1
		figon = true;
		t = 1:size(cond1,1);
	end
	
	%% data dimensions
	ntrials = size(cond1,1);
	nsamps = size(cond1,2);
	
	%% Make a joint distribution contiang the data from both conditions
	matAggregateTrials = cat(1,cond1,cond2);
	intTrials1 = size(cond1,1);
	intTrials2 = size(cond2,1);
	intTotTrials = intTrials1+intTrials2;
	
	%% permutation stats
	tmax = zeros(reps,1);
	for s = 1:reps
		
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
		tmap_pos(tmap>0&pmap<0.05) = tmap(tmap>0&pmap<0.05);
		
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
	percentile = round(reps.*0.95);
	%This is the critical vlaue of maximum t
	cluscrit = J(percentile);
	
	%% Now cluster the real data and check to see whether each cluster was significant
	%PErform the t-test
	[~,pmap,~,stats] = ttest2(cond1,cond2,'dim',1);
	tmap = stats.tstat;
	
	%% Cluster level correction
	%Threshold with the pmap
	tmap_pos = zeros(size(tmap));
	tmap_pos(tmap>0&pmap<0.05) = tmap(tmap>0&pmap<0.05);
	
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
		clustix = find(abs(clustsum)>cluscrit);
		if ~isempty(clustsum)
			if isempty(clustix)
				[thisclustsum,clustix] = max(abs(clustsum));
				cc = cc+1;
				clusters(cc).map = zeros(nsamps,1);
				%get quantile position of cluster in random data
				clusters(cc).p = 1-sum(thisclustsum>J)/(numel(J)+1);
				clusters(cc).pmap = pmap;
				clusters(cc).tmap = tmap;
				clusters(cc).clustsum = thisclustsum;
			else
				for j = clustix
					buf = zeros(nsamps,1);
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
			clusters(cc).map = zeros(nsamps,1);
			clusters(cc).p = 1;
			clusters(cc).pmap = pmap;
			clusters(cc).tmap = tmap;
			clusters(cc).clustsum = 0;
		end
	else
		cc = cc+1;
		clusters(cc).map = zeros(nsamps,1);
		clusters(cc).p = 1;
		clusters(cc).pmap = pmap;
		clusters(cc).tmap = tmap;
		clusters(cc).clustsum = 0;
	end
	
	if figon
		
		figure
		plot(t,log10(pmap)),hold on
		title('Uncorrected stats'),ylabel('log10(P)')
		
		%Mark significant clusters on map
		figure
		conddiff = nanmean(cond1-cond2,2);
		plot(t,conddiff,'k','LineWidth',2),hold on
		Y = get(gca,'YLim');
		for j = 1:length(clusters)
			st = find(clusters(j).map,1,'first');
			ed = find(clusters(j).map,1,'last');
			if ~isempty(st) & ~isempty(ed)
				fill([t(st) t(st) t(ed) t(ed)],[Y(1) Y(2) Y(2) Y(1)],'g')
			end
		end
		hold on,plot(t,conddiff,'k','LineWidth',2)
		title('Significant Clusters')
		
	end
end

%% Colormap generation
function semap = makesemap(minval,maxval)
	
	%MAke a suppression/enhancement colormap
	cspace = linspace(minval,maxval,64);
	
	%Find zero-point
	zp = find(cspace>=0,1,'first');
	semap = zeros(64,3)+0.5;
	semap(zp:end,1) = linspace(0.5,1,64-zp+1)';
	semap(zp:end,2) = linspace(0.5,0,64-zp+1)';
	semap(zp:end,3) = linspace(0.5,0,64-zp+1)';
	%All pojts below scale from grey to blue
	semap(1:zp,1) = linspace(0,0.5,zp)';
	semap(1:zp,2) = linspace(0,0.5,zp)';
	semap(1:zp,3) = linspace(1,0.5,zp)';
	
	return
end


