function h = cline(varargin)
	%cline Draw colored lines. Syntax:
	%	h = cline([hAx],vecX, vecY, vecZ, vecC, boolPatch)
	%
	%The original cline() function works with patch objects, which cannot
	%be exported to a vector image (e.g., pdf or eps). I therefore built
	%this function that has an identical syntax, but instead uses multiple
	%coloured lines between points. To use patch objects, use boolPatch=1.
	%
	%Inputs can be 2, 3, or 4 vectors. The function assumes the last vector
	%indexes the color and retrieves the colormap from the axis. After
	%plotting, the colormap can no longer be changed.
	%
	%NOTE: set the axis's colormap BEFORE calling this function.
	%
	%Version history:
	%1.0 - 6 February 2020
	%	Created by Jorrit Montijn
	%1.1 - 4 August 2021
	%	Easier color map usage & switch for patch objects [by JM]
	
	% Check input arguments
	narginchk(2, 6)
	if isaxes(varargin{1})
		hAx = varargin{1};
		varargin(1) = [];
	else
		hAx = gca;
	end
	if numel(varargin{end}) == 1 && (varargin{end} == 1 || varargin{end} == 0)
		boolPatch = varargin{end};
		varargin(end) = [];
	else
		boolPatch = false;
	end
	vecX = varargin{1};
	vecY = varargin{2};
	vecZ = varargin{end-1};
	vecC = varargin{end};

	% fill arrays if none supplied
	if numel(varargin) < 3
		vecY = zeros(size(vecX));
	end
	if numel(varargin) < 4
		vecZ = zeros(size(vecX));
	end
	
	if ~isnumeric(vecX) || ~isnumeric(vecY) || ~isvector(vecX) || ~isvector(vecY) || length(vecX)~=length(vecY)
		error('x and y must be numeric and conforming vectors');
	end
	if (nargin == 3 && (~isnumeric(vecZ) || ~isvector(vecZ) || length(vecX)~=length(vecZ))) || ...
			(nargin == 4 && ~isempty(vecZ) && (~isnumeric(vecZ) || (~isvector(vecZ) && length(vecX)~=length(vecZ)))) || ...
			(nargin == 4 && (~isnumeric(vecC) || (~isvector(vecC) && (length(vecX)~=length(vecC) && length(vecC) ~= 3))))
		error('z (and cdata) must be a numeric vector and conforming to x and y');
	end
	
	
	%fill empties
	if isempty(vecY)
		vecY = zeros(size(vecX));
	end
	if isempty(vecZ)
		vecZ = zeros(size(vecX));
	end
	
	%get colormap
	cMap = get(hAx, 'Colormap');
	
	%expand colormap to number of points
	intMaxL = numel(vecX)-1;
	
	%plot
	boolOldHold = ishold(hAx);
	hold(hAx,'on');
	if boolPatch
		%patches
		h = patch(hAx,[vecX(:)' nan], [vecY(:)' nan], [vecZ(:)' nan], 0);
		if numel(vecC) == 3 && numel(vecX) ~= 3
			set(h,'edgecolor',vecC,'facecolor','none')
		else
			cdata = [vecC(:)' nan];
			set(h,'cdata', cdata, 'edgecolor','interp','facecolor','none')
		end
	else
		%lines
		if numel(vecC) == 3 && numel(vecX) ~= 3
			cMap2 = repmat(vecC(:)',[intMaxL 1]);
		elseif size(vecC,1) == numel(vecX) && size(vecC,2) == 3
			cMap2 = vecC;
		else
			vecLinSpaceC = linspace(min(vecC),max(vecC),size(cMap,1));
			cMap2 = cat(2,interp1(vecLinSpaceC,cMap(:,1),vecC(:)')',...
				interp1(vecLinSpaceC,cMap(:,2),vecC(:)')',...
				interp1(vecLinSpaceC,cMap(:,3),vecC(:)')');
		end
		
		set(hAx,'ColorOrder',cMap2);
		h = gobjects(1,intMaxL);
		for i=1:intMaxL
			h(i) = plot3(hAx,[vecX(i) vecX(i+1)],[vecY(i) vecY(i+1)],[vecZ(i) vecZ(i+1)],'color',cMap2(i,:));
		end
	end
	if ~boolOldHold,hold(hAx,'off');end
end
function h = clineOld(x, y, z, cdata)
	% Draw a color-coded line by using the edge of a patch with no facecolor
	%
	% SYNTAX
	% ======
	% h = cline(x, y [, z, cdata])
	%
	% INPUT
	% =====
	% x                     vector with x-values
	% y                     vector with y-values
	% z (opt.)              vector with z-values
	% cdata (opt.)          vector with color-data
	%
	% 2 input arguments =>  cdata = y; z=0      % s. Example 1
	% 3 input arguments =>  cdata = z           % s. Example 2
	% 4 i.a. & z = []   =>  cdata = y; z=0      % s. Example 4
	%
	% OUPUT
	% =====
	% h                 Handle to line (i.e. patch-object !!!)
	%
	% Examples
	% ========
	% t = 2*pi:.1:8*pi;
	%
	% cline(sqrt(t).*sin(t), sqrt(t).*cos(t)); view(3)                       % Example 1
	% cline(sqrt(t).*sin(t), sqrt(t).*cos(t), t); view(3)                    % Example 2
	% cline(sqrt(t).*sin(t), sqrt(t).*cos(t), t, rand(size(t))); view(3)     % Example 3
	% cline(sqrt(t).*sin(t), sqrt(t).*cos(t), [], rand(size(t))); view(3)	 % Example 4
	%
	%
	% Author & Version
	% ================
	% S. Hölz, TU-Berlin, seppel_mit_ppATweb.de
	% V 1.0, 16.4.2007
	% Created using Matlab 7.0.4 (SP2)
	%
	
	% Info
	% ====
	% This function uses the edges of a patch to represent the colored 2D/3D-line. The marker-related
	% properties (i.e. 'maker','markersize','markeredgecolor','markerfacecolor') can be used as with a
	% regular line.
	%
	% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	% The line-related properties (i.e. 'linestyle','linewidth') WILL HAVE NO EFFECT
	% while displaying the line on screen, but will change the output when printing to file !!!
	% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!
	%
	% This is not a flaw of this function but rather the way Matlab interprets the interpolated edges of
	% a patch on screen and when printing. I do not know, if this behavior is consistent in other
	% versions of Matlab.
	%
	
	% Check input arguments
	error(nargchk(2, 4, nargin))
	if ~isnumeric(x) || ~isnumeric(y) || ~isvector(x) || ~isvector(y) || length(x)~=length(y);
		error('x and y must be numeric and conforming vectors');
	end
	if (nargin == 3 && (~isnumeric(z) || ~isvector(z) || length(x)~=length(z))) || ...
			(nargin == 4 && ~isempty(z) && (~isnumeric(z) || ~isvector(z) || length(x)~=length(z))) ...
			(nargin == 4 && (~isnumeric(cdata) || ~isvector(cdata) || length(x)~=length(cdata)))
		error('z (and cdata) must be a numeric vector and conforming to x and y');
	end
	
	% Draw line as patch
	if nargin == 2
		p = patch([x(:)' nan], [y(:)' nan], 0);
		cdata = [y(:)' nan];
	elseif nargin == 3
		p = patch([x(:)' nan], [y(:)' nan], [z(:)' nan], 0);
		cdata = [z(:)' nan];
	elseif nargin == 4
		if isempty(z); z = zeros(size(x)); end
		p = patch([x(:)' nan], [y(:)' nan], [z(:)' nan], 0);
		cdata = [cdata(:)' nan];
	end
	
	set(p,'cdata', cdata, 'edgecolor','interp','facecolor','none')
	
	
	% Create output
	if nargout == 1; h = p; end
end