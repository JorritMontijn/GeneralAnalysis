function c = grey(m)
%REDBLUEPURPLE

if nargin < 1, m = size(get(gcf,'colormap'),1); end

if (mod(m,2) == 0)
    % From [0 0 1] to [1 1 1], then [1 1 1] to [1 0 0];
    r = linspace(0,1,m)';
    g = r;
    b = r;
end

c = [r g b]; 

