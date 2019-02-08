function c = bw(m)
	%black & white colormap
	
	if nargin < 1, m = size(get(gcf,'colormap'),1); end
	
	v = round(linspace(1,0,m)');
	c = [v v v];
	
