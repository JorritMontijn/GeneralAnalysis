function [hMain,hTop,hRight]=multiGraph(varargin)
	%multiGraph Makes 3 axes in a single graph
	%	Syntax: [hMain,hTop,hRight]=multiGraph([left offset] [,bottom offset] [,size of small graphs])
	%	params must contain four values:
	%lO1: left offset
	%bO1: bottom offset
	%sGZ: size of small graphs
	figure

	[lO1,bO1,sGZ] = defaultValues(varargin,0.1,0.1,0.14);


	bGZ=0.9-sGZ-0.09;
	
	lO2=lO1+bGZ+0.04;
	bO2=bO1+bGZ+0.04;
	
	
	hMain=subplot('Position',[lO1 bO1 bGZ bGZ]);
	hTop=subplot('Position',[lO1 bO2 bGZ sGZ],'xticklabel',[]);
	hRight=subplot('Position',[lO2 bO1 sGZ bGZ],'yticklabel',[]);
end