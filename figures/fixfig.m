function fixfig(handle,boolMakeActive)
	
	%inputs
	if ~exist('handle','var') || isempty(handle)
		handle=gcf;
	end
	if ~exist('boolMakeActive','var') || isempty(boolMakeActive)
		boolMakeActive=true;
	end
	
	if boolMakeActive
		figure(handle);
	end
	
	dblFontSize=14; %change the figure font size
	grid(handle,'on'); %show grid
	xlabel(get(get(handle,'xlabel'), 'String'),'FontSize',dblFontSize); %set x-label and change font size
	ylabel(get(get(handle,'ylabel'), 'String'),'FontSize',dblFontSize);%set y-label and change font size

	title(get(get(handle,'title'),'string'),'FontSize',14);
	set(handle,'FontSize',dblFontSize,'Linewidth',2); %set grid line width and change font size of x/y ticks
	set(handle,'TickDir', 'out');
	if ~strcmp(get(get(handle,'Children'),'Type'),'image'),set(get(handle,'Children'),'Linewidth',2);end %change default linewidth to 2
end

