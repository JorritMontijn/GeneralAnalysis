function y = logisticfitx0(beta,x)
	%logisticfit0 Logistic growth centered at (x=0,y=0)
	%   Syntax: y = logisticfit0(beta,x)
	%	beta(1) = L (asymptote) [default 1]
	%	beta(2) = k (slope) [default 1]
	%	beta(3) = x0 (x-offset) [default 0]
	
	%define parameters
	if length(beta) < 1, L=1; else L = beta(1);end %asymptote
	if length(beta) < 2, k=1; else k = beta(2);end %slope
	if length(beta) < 3, x0=0; else x0 = beta(3);end %x-offset
	if length(beta) < 4, y0=0; else y0 = beta(4);end %y-offset
	
	%calc
	y=L*(((1./(1+exp(-k*(x-x0)))) -0.5) * 2)+y0;
end

