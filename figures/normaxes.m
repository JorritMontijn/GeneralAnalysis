function vecLim = normaxes(varargin)
	%normaxes Sets the same axis limits for selected subplots
	%   vecLim = normaxes(hFig,strAxis,vecSubplots)
	%
	%Note: subplots is given in children IDs, not in subplot numbers
	
	%set defaults
	hFig=gcf;
	strAxis = 'y';
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
	dblMinV = inf;
	dblMaxV = -inf;
	for intAx=vecSubplots(:)'
		if contains(strAxis,'y')
			vecLim = get(hFig.Children(intAx),'ylim');
		elseif contains(strAxis,'x')
			vecLim = get(hFig.Children(intAx),'xlim');
		elseif contains(strAxis,'z')
			vecLim = get(hFig.Children(intAx),'zlim');
		end
		dblMinV = min([dblMinV vecLim]);
		dblMaxV = max([dblMaxV vecLim]);
	end
	
	%set limits
	vecLim = [dblMinV dblMaxV];
	for intAx=vecSubplots(:)'
		if contains(strAxis,'y')
			set(hFig.Children(intAx),'ylim',vecLim);
		elseif contains(strAxis,'x')
			set(hFig.Children(intAx),'xlim',vecLim);
		elseif contains(strAxis,'z')
			set(hFig.Children(intAx),'zlim',vecLim);
		end
	end
end

