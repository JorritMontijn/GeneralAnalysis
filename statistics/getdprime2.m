function dPrime = getdprime2(vecIn1,vecIn2,intDim)
	if ~exist('intDim','var') || isempty(intDim)
		intDim=1;
	end
	dPrime = (mean(vecIn1,intDim) - mean(vecIn2,intDim))./sqrt(0.5*(var(vecIn1,[],intDim)+var(vecIn2,[],intDim)));
end