function c = redbluered(m)
	%REDBLUEPURPLE
	
	if nargin < 1, m = size(get(gcf,'colormap'),1); end
	
	% From [0 0 1] to [1 1 1], then [1 1 1] to [1 0 0];
	r = [linspace(1,0,floor(m/2)) linspace(0,1,ceil(m/2))]';
	g = 0*r;
	b = 1-r;
	
	c = [r g b];
	
