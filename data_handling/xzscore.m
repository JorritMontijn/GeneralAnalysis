function [vecZ,dblMu,dblSigma] = xzscore(vecX,intDim)
	%xzscore Fast zscore calculation.
	%time. Syntax:
	%   [z,mu,sigma] = xzscore(vecX,intDim)
	%
	%	By Dr. Jorrit S. Montijn, 26-11-18 (dd-mm-yy; Netherlands Institute for Neuroscience)



% Compute X's mean and sd, and standardize it
dblMu = xmean(vecX,intDim);
dblSigma = xstd(vecX,intDim);
vecZ = bsxfun(@rdivide,bsxfun(@minus,vecX, dblMu),dblSigma);
