function vecY = getBimodalGaussCF(vecP,vecX)
	%getBimodalGauss Fits bimodal gauss
	%Syntax: vecY = getBimodalGaussCF(vecP,vecX)
	%   [mu1,sigma1,peak1,mu2,sigma2,peak2] = vecP(1:6);
	
	%params
	mu1 = vecP(1);
	sigma1 = vecP(2);
	peak1 = vecP(3);
	mu2 = vecP(4);
	sigma2 = vecP(5);
	peak2 = vecP(6);
	
	vecY = normpdf(vecX,mu1,sigma1)*peak1 + normpdf(vecX,mu2,sigma2)*peak2;
end

