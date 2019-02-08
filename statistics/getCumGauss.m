function vecY = getCumGauss(varargin)
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	if nargin == 2
		vecParams = varargin{1};
		vecX = varargin{2};
	elseif nargin > 2 && nargin < 5
		vecParams(1:2) = varargin{1};
		vecX = varargin{2};
		vecParams = [vecParams varargin{3}];
	end
	
	if length(vecParams) < 3
		vecParams(3) = 0;
	end
	if length(vecParams) < 4
		vecParams(4) = 1;
	end
	dblRange = vecParams(4) - vecParams(3);
	
	vecY = normcdf(vecX,vecParams(1),vecParams(2));
	vecY = vecY - min(vecY);
	vecY = vecY./(max(vecY));
	vecY = vecY.*dblRange;
	vecY = vecY+vecParams(3);
	
end

