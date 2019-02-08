function [cellHandles,sOut] = doPEP2(vecTrace1,vecTrace2,vecOn,sEvents)
	%doPEP2 Performs Peri-Event Plot of 2 supplied traces
	%syntax: [cellHandles,sOut] = doPEP2(vecTrace1,vecTrace2,vecOn,sEvents)
	%	input:
	%	- sEvents, structure containing the following fields:
	%		- handleFig; handle to figure
	%		- vecOn; vector containing starts of events
	%		- vecOff; vector containing stops of events [default; same as vecOn]
	%		- cellSelect; combo from getStimulusTypes /
	%			getSelectionVectors supplying event types [optional input]
	%			- if cellSelect is defined; sTypes is an optional field for
	%				supplying variable names
	%		- vecTypes; vector supplying event types [optional input]
	%			- if vecTypes is defined; varNames is an optional field for
	%				supplying variable names
	%		- vecWindow; 2-element vector specifying which window to plot
	%			around events [default; [-75 125]]
	%		- dblFrameRate; frame rate [optional; used for setting x-axis]
	%	- vecTrace; trace containing data to be plotted
	%
	%	Note: sTypes/cellSelect and vecTypes are mutually exclusive. Use
	%	either one of the two ways to supply the stimulus identities.
	%
	%
	%	Version history:
	%	1.0 - August 1 2013
	%	Created by Jorrit Montijn
	%	2.0 - Feb 5 2019
	%	Split doPEP into two functions that are easier to use [by JM]. 
	%	For future reference, prior syntax was: 
	%		cellHandles = doPEP(sEvents,vecTrace,vecTrace2)
	
	
	%% get inputs
	if ~exist('sEvents','var'),sEvents=struct;end
	if isfield(sEvents,'vecColorFill'), vecColorFill = sEvents.vecColorFill; else vecColorFill=[0.75 0.75 1]; end
	if isfield(sEvents,'vecColorLine'), vecColorLine = sEvents.vecColorLine; else vecColorLine=[0 0 1]; end
	if isfield(sEvents,'handleFig'), handleFig = sEvents.handleFig; end
	if isfield(sEvents,'vecOff'), vecOff = sEvents.vecOff; else vecOff = vecOn; end
	if isfield(sEvents,'dblFrameRate'), dblFrameRate = sEvents.dblFrameRate; else dblFrameRate = 25; end
	if isfield(sEvents,'vecWindowSecs')
		vecWindowSecs = sEvents.vecWindowSecs;
		vecWindow =  round(vecWindowSecs*dblFrameRate);
	elseif isfield(sEvents,'vecWindow'),
		vecWindow = sEvents.vecWindow; 
		vecWindowSecs = vecWindow/dblFrameRate;
	else
		vecWindowSecs = [-3 5];
		vecWindow = round(vecWindowSecs*dblFrameRate);
	end
	vecWindow = [max(vecWindow(1),-(min(vecOn)-1)) min((length(vecTrace1)-max(vecOn)-1),vecWindow(end))];
	
	if isfield(sEvents,'cellSelect')
		intTypes = numel(sEvents.cellSelect);
		vecTypes = zeros(1,length(vecOn));
		for intType=1:intTypes
			vecTypes(sEvents.cellSelect{intType}) = intType;
		end
		if isfield(sEvents,'sTypes'), varNames=sEvents.sTypes.matTypes(1,:);else varNames=1:intTypes;end%mat2cell(sEvents.sTypes.matTypes,1,ones(1,length(sEvents.sTypes.matTypes)));
	elseif isfield(sEvents,'vecTypes')
		vecTypes = sEvents.vecTypes;
		intTypes = max(vecTypes);
		if isfield(sEvents,'varNames'), varNames=sEvents.varNames;else varNames=1:intTypes;end%mat2cell(sEvents.sTypes.matTypes,1,ones(1,length(sEvents.sTypes.matTypes)));
	else
		intTypes = 1;
		vecTypes = ones(1,length(vecOn));
		varNames=1:intTypes;
	end
	
	%pre-compute variables
	vecWindowSelect = vecWindow(1):vecWindow(end);
	intWL = length(vecWindowSelect);
	vecWindowInv = intWL:-1:1;
	vecWindowPlotInv = vecWindow(end):-1:vecWindow(1);
	
	%% plot peri-event trace
	for intType=1:intTypes
		vecSelect = vecTypes == intType;
		vecOnT = vecOn(vecSelect);
		intReps = length(vecOnT);
		%if intReps<2,error([mfilename ':NoRepetitions'],'Number of repetitions is less than 2; calculation is of sd error is impossible');end
		
		%make selection matrix
		matSelect = repmat(vecOnT',[1 intWL]) + repmat(vecWindowSelect,[intReps 1]);
		
		%get data
		matReps=vecTrace1(matSelect);
		vecMean = mean(matReps,1);
		vecSE = std(matReps,[],1)/sqrt(intReps);
		vecMinTrace = vecMean-vecSE;
		vecMaxTrace = vecMean+vecSE;
		
		if ~isempty(vecTrace2)
			matReps2=vecTrace2(matSelect);
			vecColor = mean(matReps2,1);
		end
		
		%plot
		if ~exist('handleFig','var'),h=figure;figure(h);set(gcf,'Color',[1 1 1]);else h=handleFig;end
		
		if ~isempty(h),hold on;end
		if isempty(vecTrace2)
			vecX = [vecWindowSelect vecWindowPlotInv]/dblFrameRate;
			vecY = [vecMinTrace vecMaxTrace(vecWindowInv)];
			vecC = vecColorFill;
			if ~isempty(h),fill(vecX,vecY,vecC,'EdgeColor','none');end
			
			vecLineX = vecWindowSelect/dblFrameRate;
			vecLineY = vecMean;
			vecLineC = vecColorLine;
			if ~isempty(h),plot(vecLineX,vecLineY,'-','LineWidth',2,'Color',vecLineC);end
		else
			colormap(jet(256));
			vecX = [vecWindowSelect vecWindowPlotInv]/dblFrameRate;
			vecY = [vecMinTrace vecMaxTrace(vecWindowInv)];
			vecC = [vecColor vecColor(vecWindowInv)];
			if ~isempty(h),fill(vecX,vecY,vecC,'EdgeColor','none');end
			
			vecLineX = vecWindowSelect/dblFrameRate;
			vecLineY = vecMean;
			vecLineC = vecColor;
			if ~isempty(h)
				hLine = cline(vecLineX,vecLineY, [], vecLineC);
				set(hLine,'LineWidth',2);
				colorbar;
			end
		end
		
		%set properties
		if ~isempty(h)
			hold off;
			xlim(vecWindowSecs);
			%[min(vecMinTrace) max(vecMaxTrace)]
			if min(vecMinTrace) ~= max(vecMaxTrace),ylim([min(vecMinTrace) max(vecMaxTrace)]);end
			xlabel('Time from event (s)');
			ylabel(sprintf('Trace for type %s',num2str(varNames(intType))))
			grid on;
			cellHandles{intType} = h;
		else
			cellHandles = [];
		end
		
		%output
		sOut.vecX = vecX;
		sOut.vecY = vecY;
		sOut.vecC = vecC;
		sOut.vecLineX = vecLineX;
		sOut.vecLineY = vecLineY;
		sOut.vecLineC = vecLineC;
	end
end

