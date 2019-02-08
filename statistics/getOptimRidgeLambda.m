function [dblLambda,dblR2Optim] = getOptimRidgeLambda(matX1N,matY1N,intFoldK,dblInitLambda)
	%getOptimRidgeLambda Find optimal regularisation parameter for ridge regression
	%   [dblLambda,dblR2Optim] = getOptimRidgeLambda(matX1N,matY1N,intFoldK,dblInitLambda)
	
	%set globals
	global gMatX;
	global gMatY;
	global gIntFolds;
	
	gMatX = matX1N;
	gMatY = matY1N;
	gIntFolds = intFoldK;
	
	%find optimal lambda
	if ~exist('dblInitLambda','var'),dblInitLambda = 10;end
	[dblLambda,dblR2Optim] = fminsearch(@getRidgeWrapper,dblInitLambda);
end

