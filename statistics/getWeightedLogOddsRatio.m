function dblWLOR = getWeightedLogOddsRatio(vecData)
	%getFracLogDevInt Summary of this function goes here
	%   dblWLOR = getWeightedLogOddsRatio(vecData)
	
	if ~isvector(vecData) || length(vecData) < 3
		error('not a vector');
	end
	
	%sort
	vecData = sort(vecData(:));
	vecNorm = linspace(1/numel(vecData),1,numel(vecData));
	vecLogOdds = abs(log(vecData(:)./vecNorm(:)));
	vecLogStep = diff(log(vecData(:)));
	dblWLOR = sum(vecLogOdds(1:(end-1)).*vecLogStep)/sum(vecLogStep);
end

