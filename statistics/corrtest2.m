function [p,z,r1,r2,S] = corrtest2(x1,y1,x2,y2)
	%corrtest2 Tests difference between correlations r(x1,y1) and r(x2,y2)
	%   [p,z,r1,r2,S] = corrtest2(x1,y1,x2,y2)
	
	%calc Pearson corr & n
	r1 = corr(x1(:),y1(:));
	n1 = numel(x1);
	r2 = corr(x2(:),y2(:));
	n2 = numel(x2);
	
	%sd
	S  = sqrt((1/(n1-3))+(1/(n2-3)));
	
	%Fisher-transformed
	r1_prime = 0.5*log((1+r1)/(1-r1));
	r2_prime = 0.5*log((1+r2)/(1-r2));
	
	%z-score
	z = (r1_prime - r2_prime)/S;
	
	%p-value
	p = 2*normcdf(-abs(z));
end

