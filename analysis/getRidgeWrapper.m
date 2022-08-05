function dblR2 = getRidgeWrapper(dblLambda)
	%getRidgeWrapper Wrapper for doRidge_CV
	%    dblR2 = getRidgeWrapper(dblLambda)
	
	%% get globals
	global gMatX;
	global gMatY;
	global gIntFolds;
	
	[vecR2_Ridge_CV, sRidge] = doRidge_CV(gMatX, gMatY, gIntFolds, dblLambda);
	dblR2 = -mean(vecR2_Ridge_CV); %negative to minimize
	%fprintf('L%.0f, R2=%.3f\n',dblLambda,-dblR2)
end

