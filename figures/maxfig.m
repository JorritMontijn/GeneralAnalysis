function jFig = maxfig(ptrHandle)
	%maxfig Maximizes figure. Syntax:
	%   jFig = maxfig(ptrHandle)
	
	%get handle
	if ~exist('ptrHandle','var') || isempty(ptrHandle)
		ptrHandle = gcf;
	end
	
	%maximize
	sWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
	drawnow;
	jFig = get(handle(ptrHandle), 'JavaFrame');
	jFig.setMaximized(true);
	drawnow;
	warning(sWarn);
end

