function vecGaussian = getGaussian(params,xVector)
	%singleGaussian builds a Gaussian with inputs: (params,xVector)
	%params is a vector: [mu sigma peak baseline]
	
	%define parameters
	if length(params) < 1, mu=0; else mu = params(1);end %mu
	if length(params) < 2, sigma=1; else sigma = params(2);end %sigma
	if length(params) < 3, peak=1; else peak = params(3);end %peak
	if length(params) < 4, baseline=0; else baseline = params(4);end %baseline

	%uses matlab's built-in normpdf() function
	gauss = normpdf(xVector,mu,sigma);
	
	%set max value to 1
	multiplicationFactor = 1/max(gauss);
	normGauss = gauss*multiplicationFactor;
	
	%set max value to peak-baseline
	vecGaussian = (peak-baseline)*normGauss;
	
	%add baseline
	vecGaussian = vecGaussian+baseline;
end

