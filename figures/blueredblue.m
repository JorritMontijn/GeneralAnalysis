function c = blueredblue(m)
	%REDBLUEPURPLE
	
	if nargin < 1, m = size(get(gcf,'colormap'),1); end
	
	% From [0 0 1] to [1 1 1], then [1 1 1] to [1 0 0];
	b = [linspace(1,0,floor(m/2)) linspace(0,1,ceil(m/2))]';
	g = 0*b;
	r = 1-b;
	
	c = [r g b];
	
