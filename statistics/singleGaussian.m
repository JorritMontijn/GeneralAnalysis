function gaussVector = singleGaussian(xVector,params)
	%singleGaussian builds a Gaussian with inputs: (xVector,params)
	%params is a vector: [mu sigma peak baseline]
	
	%mu, sigma, peak, baseline
	mu=params(1);
	sigma=params(2);
	peak=params(3);
	baseline=params(4);
	
	%uses matlab's built-in normpdf() function
	gauss = normpdf(xVector,mu,sigma);
	
	%set max value to 1
	multiplicationFactor = 1/max(gauss);
	normGauss = gauss*multiplicationFactor;
	
	%set max value to peak-baseline
	gaussVector = (peak-baseline)*normGauss;
	
	%add baseline
	gaussVector = gaussVector+baseline;
end

