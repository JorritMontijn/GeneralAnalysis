%function [vecMuFit,vecSigmaFit,resnorm,residual,exitflag,matFit] = getFitGaussMV(matDataGrid,vecMu0,matSigma0,boolUniform)
	%getFitGaussMV Fits multivariate Gaussian to input matrix. Syntax:
	%   [vecMuFit,vecSigmaFit,resnorm,residual,exitflag,matFit] = getFitGaussMV(matDataGrid,vecMu0,matSigma0,boolUniform)
	%
	%When boolUniform is set to [true], all off-diagonal elements in the
	%covariance matrix will be set to zero
	
	
	
	
	%% input
	matDataGrid = rot90(eye(6));
	vecMu0 = [3.5 3.5];
	matSigma0 = rand(2);
	%matSigma0 = matSigma
	
	%run
	[matD1,matD2]=ndgrid(1:size(matDataGrid,1),1:size(matDataGrid,2));
	vecD1 = matD1(:);
	vecD2 = matD2(:);
	matGrid = [vecD1 vecD2];
	
	
	[x,dblNormResidualsRot,residual,exitflag,matFit2] = getFitGauss2D(matDataGrid,[max(matSFTF(:)) 3.5 1 3.5 1 0],1)
	
	
	[x,resnorm,residual,exitflag,matFit] = getFitGauss2D(matDataGrid,[1,vecMu0(1),1,vecMu0(2),1,0],1)
	
	%set options
	intIters = 10^4;
	sOptions = optimset('MaxFunEvals',intIters,'MaxIter',intIters);
	
	%transform parameters
	[vecParams,vecLowerBounds,vecUpperBounds] = getParamsMuSigma(vecMu0,matSigma0);
	
	%run fitting
	x = [0.81;0.91;0.13;0.91;0.63;0.098;0.28;0.55;...
0.96;0.96;0.16;0.97;0.96];
y = [0.17;0.12;0.16;0.0035;0.37;0.082;0.34;0.56;...
0.15;-0.046;0.17;-0.091;-0.071];
ft = fittype( 'getGaussMV(vecParams,x)' )
f = fit( x, y, ft, 'StartPoint', [1, 0, 1, 0, 0.5] )
plot( f, x, y ) 

vecV = getGaussMV(vecParams,matGrid)
fitobject = fit(vecD1,vecD2,matDataGrid(:),@getGaussMV)
	
	%run fitting
	[vecFitParams,resnorm,residual,exitflag] = curvefitfun(@getGaussMV,vecParams,matGrid,matDataGrid(:),vecLowerBounds,vecUpperBounds,sOptions);
	%if nargout > 4
		vecFit = getGaussMV(vecFitParams,matGrid);
		matFit = reshape(vecFit,size(matDataGrid));
	%end
	subplot(2,2,1)
	imagesc(matDataGrid)
	axis xy
	
	subplot(2,2,2)
	imagesc(matFit)
	axis xy
	

%end

