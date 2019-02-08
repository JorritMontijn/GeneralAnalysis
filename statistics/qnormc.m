function  vecSigmaOut = qnormc(matCoordinates)
	%QNORMC		Calculates the number of standard deviations all points are
	%away from the center of mass of the whole sample assuming Euclidian
	%distances and a Gaussian probability distribution. Works with any
	%number of dimensions.
	%
	%Syntax: vecSigmaOut = qnormc(matCoordinates)
	%
	%Input: for matrix matCoordinates(n,i), n indexes the spatial
	%dimension, and i indexes the points.
	%
	%	By Jorrit Montijn, 09-01-15 (University of Amsterdam)
	
	%use zscore to transform distances to sigma values per spatial dimension
	matCoordinates = zscore(matCoordinates,[],2);
	
	%compute n-dimensional euclidian diagonal
	vecSigmaOut = sqrt(sum(matCoordinates.*matCoordinates,1));
end