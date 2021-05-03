function Hn = harmonicnumber(n,intForceType)
	%harmonicnumber n'th harmonic number
	%   Hn = harmonicnumber(n)
	if ~exist('intForceType','var') || isempty(intForceType)
		intForceType = 0;
	end
	
	indApprox = intForceType == 1 | (n > (10^8)) & intForceType ~= 2;
	Hn = zeros(size(n));
	for intRunType=1:2
		if intRunType==1
			%approximation
			dblEulerMascheroni = 0.5772156649015328606065120900824; %vpa(eulergamma)
			Hn(indApprox) = dblEulerMascheroni + log(n(indApprox));
		else
			%exact
			vecN = n(~indApprox);
			for intIdxN=1:numel(vecN)
				intN = vecN(intIdxN);
				Hn(intIdxN) = sum(1./(1:intN));
			end
		end
	end
end

