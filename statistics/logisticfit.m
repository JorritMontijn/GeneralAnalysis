function y = logisticfit(beta,x)
	%UNTITLED2 Summary of this function goes here
	%   Detailed explanation goes here
	
	%define parameters
	if length(beta) < 1, L=1; else L = beta(1);end %asymptote
	if length(beta) < 2, k=1; else k = beta(2);end %slope
	if length(beta) < 3, x0=0; else x0 = beta(3);end %x-offset
	
	%calc
	y=(L)./(1+exp(-k*(x-x0)));
end
%0=2, 0.5=1, 1=2/3

