function c = greenblack(m)
	%greenblack    Shades of green and black color map
	
	if nargin < 1, m = size(get(gcf,'colormap'),1); end
	
	g = linspace(0,1,m)';
	r = zeros(size(g));
	b = zeros(size(g));
	
	c = [r g b];
	
