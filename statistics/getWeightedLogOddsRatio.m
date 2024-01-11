function dblWLOR = getWeightedLogOddsRatio(vecData)
	%getFracLogDevInt Summary of this function goes here
	%   dblWLOR = getWeightedLogOddsRatio(vecData)
	
	if ~isvector(vecData) || length(vecData) < 3
		error('not a vector');
	end
	
	%sort
	vecData = sort(vecData(:));%sort
	vecNorm = linspace(1/numel(vecData),1,numel(vecData)); %theoretical norm, uniform over [0,1]
	vecLogOdds = abs(log(vecData(:)./vecNorm(:))); %absolute of log-odds of random controls to theoretical norm
	vecLogStep = diff(log(vecData(:))); %step size of random controls on log scale
	dblWLOR = sum(vecLogOdds(1:(end-1)).*vecLogStep)/sum(vecLogStep); %sum over absolute log-odds weighted by log step size
end

