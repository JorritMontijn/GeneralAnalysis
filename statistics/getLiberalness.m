function dblPosInt = getLiberalness(vecData)
	%getLiberalness Summary of this function goes here
	%   dblPosInt = getLiberalness(vecData)
	
	if ~isvector(vecData) || length(vecData) < 3
		error('not a vector');
	end
	
	%sort
	vecData = sort(vecData(:));
	intN = numel(vecData);
	vecNorm = linspace(1/intN,1,intN); %theoretical norm, uniform over [0,1]
	%vecData = vecNorm/exp(1);%creates dblPosInt=1.0
	vecDiff = log(vecNorm(:)) - log(vecData(:));
	vecDiff(vecDiff<0)=0;
	vecLogStep = diff(log(vecNorm(:))); %step size of random controls on log scale
	dblPosInt = sum(vecDiff(1:(end-1)).*vecLogStep)./sum(vecLogStep);
end

