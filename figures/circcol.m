function c = circcol(m,chroma)
	%REDBLUEPURPLE
	
	if nargin < 1, m = size(get(gcf,'colormap'),1); end
	if nargin < 2,chroma = 45; end %38
	
	theta = linspace(0, 2*pi, m)'; % hue
	a = chroma * cos(theta);
	b = chroma * sin(theta);
	L = (ones(1, m)*65)'; % lightness (65)
	Lab = [L, a, b];
	c=colorspace('RGB<-Lab',Lab(end:-1:1,:));
	
	%minor adjustment to make the colors a bit brighter
	c(:,3) = c(:,3)*(0.8);
	c = c - min(c(:));
	c = c./max(c(:));