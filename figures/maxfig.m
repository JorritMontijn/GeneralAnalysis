function jFig = maxfig(ptrHandle,dblRescaleHeight)
	%maxfig Maximizes figure. Syntax:
	%   jFig = maxfig(ptrHandle,dblRescaleHeight)
	
	%get handle
	if ~exist('ptrHandle','var') || isempty(ptrHandle)
		ptrHandle = gcf;
	end
	if ~exist('dblRescaleHeight','var') || isempty(dblRescaleHeight)
		dblRescaleHeight = 1;
	end
	
	%maximize
	sWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
	drawnow;
	jFig = get(handle(ptrHandle), 'JavaFrame');
	jFig.setMaximized(true);
	drawnow;
	warning(sWarn);
	
	%adjust distances
	if dblRescaleHeight ~= 1
		vecAxes = ptrHandle.Children;
		intNumAxes = numel(vecAxes);
		matPos = nan(intNumAxes,4);
		for intAx=1:numel(vecAxes)
			matPos(intAx,:) = get(vecAxes(intAx),'Position');
			set(vecAxes(intAx),'Position',[matPos(intAx,1:3) dblRescaleHeight*matPos(intAx,4)]);
		end
	end
	drawnow;
end

