function [p,chi2stat] = chi2test(mat2x2)
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	
	       % Observed data
       n1 = mat2x2(1,1); N1 = mat2x2(1,2);
       n2 = mat2x2(2,1); N2 = mat2x2(2,2);
	   
       % Pooled estimate of proportion
       p0 = (n1+n2) / (N1+N2);
	   
       % Expected counts under H0 (null hypothesis)
       n10 = N1 * p0;
       n20 = N2 * p0;
	   
       % Chi-square test, by hand
       observed = [n1 N1-n1 n2 N2-n2];
       expected = [n10 N1-n10 n20 N2-n20];
       chi2stat = sum((observed-expected).^2 ./ expected);
       p = 1 - chi2cdf(chi2stat,1);
end

