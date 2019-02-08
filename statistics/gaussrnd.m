function r = gaussrnd(mu,sigma,vecSize)
%GAUSSRND Random arrays from the normal distribution.
%   R = GAUSSRND(MU,SIGMA) returns an array of random numbers chosen from a
%   normal distribution with mean MU and standard deviation SIGMA.  The size
%   of R is the common size of MU and SIGMA if both are arrays.  If either
%   parameter is a scalar, the size of R is the size of the other
%   parameter.
%
%   R = GAUSSRND(MU,SIGMA,M,N,...) or R = GAUSSRND(MU,SIGMA,[M,N,...])
%   returns an M-by-N-by-... array.


% Return NaN for elements corresponding to illegal parameter values.
sigma(sigma < 0) = NaN;

r = randn(vecSize) .* sigma + mu;
