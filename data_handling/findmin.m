function [C,I] = findmin(A,minnum)
%findmin Finds the lowest n values from a vector
%   syntax: [C,I] = findmin(A,n)
%	input:
%	- A: data vector
%	- n: number of lowest values to be returned
%	output:
%	- C: Vector containing lowest values
%	- I: Vector containing indices of lowest values
%
%	Note: findmin is just an easy way to use min() consecutively to
%	find the n lowest values. If minnum is larger than the amount
%	of valid numbers, it will have a NaN for every unvalid number.
%
%
%	Version history:
%	1.0 - April 21 2011
%	Created by Jorrit Montijn

if min(size(A)) > 1
	error('Input Error: findmin() only works with vectors, but input is a matrix')
end
C = nan(1,minnum);
I = nan(1,minnum);
mincount = 0;
boolStop = false;

while ~boolStop
	mincount = mincount + 1;
	
	[tC,tI] = min(A);
	
	A(tI) = nan(1,length(tI));
	if min(isnan(tC)) == 1
		boolStop = true;
	else
		C(mincount) = tC;
		I(mincount) = tI;
	end
	if mincount >= minnum
		boolStop = true;
	end
end