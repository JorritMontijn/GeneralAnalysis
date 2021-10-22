function [p,z] = bino2test(k1,n1,k2,n2,boolForceFloat)
	%bino2test Two-sample binomial test
	%  [p,z] = bino2test(k1,n1,k2,n2)
	
	%input
	if nargin==1
		vecIn = k1;
		k1 = vecIn(1);
		n1 = vecIn(2);
		k2 = vecIn(3);
		n2 = vecIn(4);
	end
	if ~exist('boolForceFloat','var')
		boolForceFloat = false;
	end
	if ~boolForceFloat && (any(round(k1)~=roundi(k1,6)) || any(round(n1)~=roundi(n1,6)) || any(round(k2)~=roundi(k2,6)) || any(round(n2)~=roundi(n2,6)))
		error([mfilename ':InputsNotIntegers'],'All inputs must be integer counts');
	end
	
	% Observed data
	p1 = k1./n1;
	p2 = k2./n2;
	
	p0 = (k1+k2) ./ (n1 + n2);
	
	z = (p1-p2) ./ sqrt((p0.*(1-p0)) .* (1./n1 + 1./n2));

	p = normcdf(abs(z),'upper')*2;
	%p = 1 - abs(normcdf(z)-normcdf(-z));
end

