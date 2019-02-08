function y = gausspdf(x,mu,sigma)
%GAUSSPDF Gaussian probability density function (pdf).
%   Y = GAUSSPDF(X,MU,SIGMA) returns the pdf of the Gauss distribution with
%   mean MU and standard deviation SIGMA, evaluated at the values in X.
%   The size of Y is the common size of the input arguments.  A scalar
%   input functions as a constant matrix of the same size as the other
%   inputs.
%
%   Default values for MU and SIGMA are 0 and 1 respectively.

if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

y = exp(-0.5 * ((x - mu)./sigma).^2) ./ (sqrt(2*pi) .* sigma);
