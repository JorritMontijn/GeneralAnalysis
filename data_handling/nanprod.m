function m = nanprod(x,dim)
	%NANPROD Product over x, ignoring NaNs.
	%   M = NANPROD(X) returns the sample prod of X, treating NaNs as missing
	%   values.  For vector input, M is the prod value of the non-NaN elements
	%   in X.  For matrix input, M is a row vector containing the prod value of
	%   non-NaN elements in each column.  For N-D arrays, NANPROD operates
	%   along the first non-singleton dimension.
	%
	%   NANPROD(X,DIM) takes the prod along dimension DIM of X.
	%
	%   See also PROD, NANMEDIAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.
	
	% Find NaNs and set them to one
	x(isnan(x)) = 1;
	
	if nargin == 1 % let prod deal with figuring out which dimension to use
		m = prod(x);
	else
		m = prod(x,dim);
	end
end	
