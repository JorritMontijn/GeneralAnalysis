function [optN, dblC, allN, allC] = opthist(x,N0,Nmax,intIterMax)
	% [optN, optC, allN, allC] = opthist(x,N0,Nmax,intIterMax)
	%
	% Uses `sshist' to find the optimal number of bins in a histogram
	% used for density estimation. Guaranteed to find a local (but not
	% necessarily global) minimum.
	
	if ~exist('N0','var') || isempty(N0)
		%friedman-draconis
		dblIQR = iqr(x);
		h=2*dblIQR*(numel(x)^-1/3);
		intFD=round(range(x)/h);
		N0 = intFD*2;
	else
		intFD = N0/2;
	end
	if ~exist('Nmax','var') || isempty(Nmax)
		Nmax = 1e9;
	end
	if ~exist('IterMax','var') || isempty(intIterMax)
		intIterMax = 1000;
	end
	
	%pre-allocate output if necessary
	if nargout > 2
		allN = nan(1,intIterMax);
		allC = nan(1,intIterMax);
	end
	intCounter = 1;
	
	%iterative line search
	vecMinMaxN = [1 N0];
	boolConverged = false;
	[vecC,vecN] = findC(x,vecMinMaxN);
	while ~boolConverged && intCounter < intIterMax && max(vecMinMaxN) < intFD*1000
		
		%get loss
		[vecC,vecN] = findC(x,vecMinMaxN);
		%save data?
		intPoints = numel(vecC);
		intPrevCounter = intCounter;
		intCounter = intCounter + intPoints;
		if nargout > 2
			allN(intPrevCounter:(intCounter-1)) = vecN;
			allC(intPrevCounter:(intCounter-1)) = vecC;
		else
			intCounter = intCounter + intPoints;
		end
		
		if range(vecN) < 10 || min(vecC) >= Nmax
			boolConverged = true;
			break;
		end
		[a,intMinIdx]=min(vecC);
		if intMinIdx== 1
			intMinN = vecN(intMinIdx);
			intMaxN = vecN(intMinIdx+1);
		elseif intMinIdx==numel(vecC)
			intMinN = vecN(intMinIdx);
			intMaxN = vecN(intMinIdx)*2;
		else
			intMinN = vecN(intMinIdx-1);
			intMaxN = vecN(intMinIdx+1);
		end
		vecMinMaxN = [intMinN intMaxN];
		
	end
	if nargout > 2
		allN(intCounter:end) = [];
		allC(intCounter:end) = [];
	end
	
	%get minimum
	[dblC,intMinIdx]=min(vecC);
	optN = vecN(intMinIdx);
end
function [vecC,vecN] = findC(x,vecMinMaxN)
	intUsePoints = 10;
	if range(vecMinMaxN) <= intUsePoints
		vecN = round(min(vecMinMaxN)):round(max(vecMinMaxN));
	else
		vecN = round(linspace(vecMinMaxN(1),vecMinMaxN(end),intUsePoints));
	end
	
	vecC = nan(size(vecN));
	for intNidx = 1:numel(vecN)
		[optN, C, N] = sshist(x,vecN(intNidx));
		vecC(intNidx) = C;
	end
end