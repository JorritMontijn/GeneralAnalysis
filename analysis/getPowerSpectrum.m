function [vecFreq,vecPower] = getPowerSpectrum(varData,dblSampFreq,intDim)

	
	%% check inputs
	if ~exist('intDim','var') || isempty(intDim)
		intDim = 1;
	end
	
	%% calculate power spectrum
	dblT = 1/dblSampFreq;             % Sampling period
	intL = size(varData,intDim);             % Length of signal
	vecTime = (0:intL-1)*dblT;        % Time vector
	
	varFiltered = fft(varData,[],intDim);
	
	P2 = abs(varFiltered/intL);
	vecPower = P2(1:intL/2+1);
	vecPower(2:end-1) = 2*vecPower(2:end-1);
	
	vecFreq = dblSampFreq*(0:(intL/2))/intL;
	%plot(vecFreq,vecPower)


end