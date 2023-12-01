function [dblClustP,sClustPos,sClustNeg] = clustertest(cond1,cond2,reps,t)
	%clusertest Summary of this function goes here
	%   [dblClustP,sClustPos,sClustNeg] = clustertest(cond1,cond2,reps,t)
	
	%% check inputs
	if nargin < 3
		reps = [];
	end
	if nargin<4
		t = [];
	end
	
	%% run
	sClustPos = ez_clusterstat_time(cond1,cond2,reps,t);
	sClustNeg = ez_clusterstat_time(cond2,cond1,reps,t);
	vecPosP = cell2vec({sClustPos.p});
	vecNegP = cell2vec({sClustNeg.p});
	dblClustP=min(1,min(bonf_holm([min(vecPosP) min(vecNegP)])));
end

