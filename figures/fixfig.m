function fixfig(handle)
	
	if nargin < 1
		handle=gcf;
	end
	figure(handle);
	
	dblFontSize=14; %change the figure font size
	grid on; %show grid
	xlabel(get(get(gca,'xlabel'), 'String'),'FontSize',dblFontSize); %set x-label and change font size
	ylabel(get(get(gca,'ylabel'), 'String'),'FontSize',dblFontSize);%set y-label and change font size

	title(get(get(gca,'title'),'string'),'FontSize',14);
	set(gca,'FontSize',dblFontSize,'Linewidth',2); %set grid line width and change font size of x/y ticks
	if ~strcmp(get(get(gca,'Children'),'Type'),'image'),set(get(gca,'Children'),'Linewidth',2);end %change default linewidth to 2
end

