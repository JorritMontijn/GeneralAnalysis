function dblP = chiSquare(x,y)
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	
	%get unique values
	vecValTypes = getUniqueVals([getUniqueVals(x) getUniqueVals(y)]);
	k = length(vecValTypes);
	
	%transform to equal-length count
	M = length(x);
	N = length(y);
	m = histc(x,vecValTypes);
	n = histc(y,vecValTypes);
	
	%perform test
	phat = (m+n) ./ (M+N);
	em = phat*M; en = phat*N;
	chi2 = sum(([m n] - [em en]).^2 ./ [em en]);
	df = k-1;
	dblP = 1 - chi2cdf(chi2,df);
end

