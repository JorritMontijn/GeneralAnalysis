function hcb = nancolorbar(varargin)
	%nancolorbar Create color bar with nan values, hiding nan entry
	%   hcb = nancolorbar(matIn,[minVal,maxVal],colmap,nancol)
	
	matIn = varargin{1};
	if nargin > 1 && numel(varargin{2}) == 2
		cMin = varargin{2}(1);
		cMax = varargin{2}(end);
	else
		cMin = min(matIn(:));
		cMax = max(matIn(:));
	end
	if nargin > 2
		if ischar(varargin{3})
			cm = colormap(gca,varargin{3});
		else
			cm = varargin{3};
		end
	else
		cm = colormap(gca,'parula');
	end
	if nargin > 3
		vecNanCol = varargin{4};
	else
		vecNanCol = [1 1 1];
	end
	
	cL = length(cm);
	cStep = (cMax - cMin) / cL;
	caxis(gca,[cMin-cStep cMax])
	colormap(gca,[vecNanCol; cm]);
	
	
	
	
	%# place a colorbar
	hcb = colorbar;
	%# change Y limit for colorbar to avoid showing NaN color
	ylim(hcb,[cMin cMax])
	
end

