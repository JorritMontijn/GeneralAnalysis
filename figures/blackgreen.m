function c = blackgreen(m)
%blackgreen    Shades of green color map
%   blackgreen(M), is an M-by-3 matrix that defines a colormap.
%   The colors begin with bright blue, range through shades of
%   blue to white, and then through shades of red to bright red.
%   redgreen, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(redblue)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

if nargin < 1, m = size(get(gcf,'colormap'),1); end

% From [0 0 1] to [1 1 1], then [1 1 1] to [1 0 0];
g = linspace(0,1,m)';
r = 0*g;
b = 0*r;

c = [r g b];

