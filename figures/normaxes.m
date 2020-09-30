function vecLim = normaxes(varargin)
	%normaxes Sets the same axis limits for selected subplots
	%   vecLim = normaxes(hFig,strAxis,vecSubplots)
	%
	%Note: subplots is given in children IDs, not in subplot numbers
	
	%set defaults
	drawnow;
	hFig=gcf;
	vecSubplots = 1:numel(hFig.Children);
	strAxis = 'y';
	cellCheckAxes = {'x','y','z'};
	for intArgIn=1:numel(varargin)
		varIn = varargin{intArgIn};
		if ishandle(varIn)
			hFig=varIn;
		elseif ischar(varIn)
			strAxis=varIn;
		elseif isnumeric(varIn)
			vecSubplots=varIn;
		end
	end
	
	%get min/max limits
	dblMinV = inf*ones(size(cellCheckAxes));
	dblMaxV = -inf*ones(size(cellCheckAxes));
	for intAx=vecSubplots(:)'
		if ~isa(hFig.Children(intAx),'matlab.graphics.axis.Axes'),continue;end
		for intChAx=1:numel(cellCheckAxes)
			if contains(strAxis,cellCheckAxes{intChAx})
				vecLim = get(hFig.Children(intAx),strcat(cellCheckAxes{intChAx},'lim'));
				dblMinV = min([dblMinV vecLim]);
				dblMaxV = max([dblMaxV vecLim]);
			end
		end
	end
	
	%set limits
	for intAx=vecSubplots(:)'
		if ~isa(hFig.Children(intAx),'matlab.graphics.axis.Axes'),continue;end
		for intChAx=1:numel(cellCheckAxes)
			if contains(strAxis,cellCheckAxes{intChAx})
				set(hFig.Children(intAx),strcat(cellCheckAxes{intChAx},'lim'),[dblMinV dblMaxV]);
			end
		end
	end
end

