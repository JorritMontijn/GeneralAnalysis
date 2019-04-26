function [upperEnv,lowerEnv] = getEnvelope(x, n)
	%getEnvelope Envelope detector.
	%   [YUPPER,YLOWER] = getEnvelope(X) returns the upper and lower envelopes of
	%   the input sequence, X, using the magnitude of its analytic signal.
	%
	%   The function initially removes the mean of X and restores it after
	%   computing the envelopes.  If X is a matrix, ENVELOPE operates
	%   independently over each column of X.
	%
	%   [YUPPER,YLOWER] = getEnvelope(X,N) uses an N-tap Hilbert filter to compute
	%   the upper envelope of X.
	
	%% remove DC offset
	if isrow(x),boolTranspose=true;else,boolTranspose=false;end
	xmean = mean(x);
	xcentered = bsxfun(@minus,x(:),xmean);
	
	%% compute filter
	if isscalar(n)
		% construct ideal hilbert filter truncated to desired length
		t = 1/2 * ((1-n)/2:(n-1)/2)';
		
		hfilt = sinc(t) .* exp(1i*pi*t);
		
		% multiply ideal filter with tapered window
		beta = 8;
		firFilter = hfilt .* kaiser(n,beta);
		firFilter = firFilter / sum(real(firFilter));
	else %input is filter
		firFilter = n;
	end
	
	%% put filter on gpu
	if strcmp(class(xcentered),'gpuArray')
		firFilter = gpuArray(firFilter);
	end
	
	%% compute envelope amplitude
	% apply filter and take the magnitude
	vecEnv = abs(conv(xcentered,firFilter,'same'));

	%% restore offset
	upperEnv = bsxfun(@plus,xmean,vecEnv);
	lowerEnv = bsxfun(@minus,xmean,vecEnv);
	
	%% transpose
	if boolTranspose
		upperEnv = upperEnv';
		lowerEnv = lowerEnv';
	end
end
