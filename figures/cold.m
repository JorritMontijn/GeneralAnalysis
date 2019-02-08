function c = cold(m)
%COOL   Shades of cyan and blue color map
%   COOL(M) returns an M-by-3 matrix containing a "cool" colormap.
%   COOL, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(cool)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

if nargin < 1, m = size(get(gcf,'colormap'),1); end
r = (0:m-1)'/max(m-1,1);
c = [zeros(m,1) 1-r ones(m,1)]; 