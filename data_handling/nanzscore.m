function [z,mu,sigma] = nanzscore(x,flag,dim)
%NANZSCORE Standardized z score with nans.
%   Z = NANZSCORE(X) returns a centered, scaled version of X, the same size
%   as X. For vector input X, Z is the vector of z-scores (X-NANMEAN(X)) ./
%   NANSTD(X). For matrix X, z-scores are computed using the mean and
%   standard deviation along each column of X.  For higher-dimensional
%   arrays, z-scores are computed using the mean and standard deviation
%   along the first non-singleton dimension.
%
%   The columns of Z have sample mean zero and sample standard deviation
%   one (unless a column of X is constant, in which case that column of Z
%   is constant at 0).
%
%   [Z,MU,SIGMA] = NANZSCORE(X) also returns NANMEAN(X) in MU and NANSTD(X)
%   in SIGMA.
%
%   See also ZSCORE


% [] is a special case for std and mean, just handle it out here.
if isequal(x,[]), z = []; return; end

if nargin < 2
    flag = 0;
end
if nargin < 3
    % Figure out which dimension to work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end

% Compute X's mean and sd, and standardize it
x(isinf(x)) = nan;
mu = nanmean(x,dim);
sigma = nanstd(x,flag,dim);
sigma0 = sigma;
sigma0(sigma0==0) = 1;
z = bsxfun(@minus,x, mu);
z = bsxfun(@rdivide, z, sigma0);

