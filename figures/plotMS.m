function [h,ax,sOut] = plotMS(vecX,vecY,sParams)
	%plotMS Plot mean and standard deviation
	%   Detailed explanation goes here
	
	if nargin == 3
		if isstruct(sParams)
			if isfield(sParams,'boolPlot'), boolPlot = sParams.boolPlot;else boolPlot = true;end
			if isfield(sParams,'vecBins'), vecBins = sParams.vecBins;end
			if isfield(sParams,'vecColor'), vecColor = sParams.vecColor;else vecColor = [0 0 1];end
			if isfield(sParams,'vecFillColor'), vecFillColor = sParams.vecFillColor;else vecFillColor= [0.75 0.75 1];end
			if isfield(sParams,'boolErr'), boolErr = sParams.boolErr;else boolErr = false;end
			if boolPlot
				if isfield(sParams,'h'), h=sParams.h;figure(h);else h = figure;end
				if isfield(sParams,'ax'), ax=sParams.ax;axes(ax);else ax = gca;end %#ok<MAXES>
			else h=[];ax=[];
			end
		else
			vecBins = sParams;
		end
	end
	
	%get step size
	if ~exist('vecBins','var')
		intBins = calcnbins(vecX);
		dblStep = (max(vecX) - min(vecX))/intBins;
		vecBins = min(vecX):dblStep:max(vecX);
	else
		dblStep = vecBins(2) - vecBins(1);
		intBins = length(vecBins)-1;
	end
	vecBins(1) = floor(vecBins(1));
	vecBins(end) = ceil(vecBins(end));
	vecPlot = (min(vecX)+dblStep/2-eps):dblStep:(max(vecX)-dblStep/2+eps);
	
	%calculate mean/std
	vecMean = nan(1,intBins);
	vecSE = nan(1,intBins);
	
	for intBin=1:intBins
		%get range
		dblMin = vecBins(intBin);
		dblMax = vecBins(intBin+1);
		
		%get vals
		vecSelect = vecX > dblMin & vecX < dblMax;
		vecVals = vecY(vecSelect);
		
		%calculate mean/std
		vecMean(intBin) = mean(vecVals);
		vecSE(intBin) = std(vecVals);
		if boolErr, vecSE(intBin) = vecSE(intBin)/sqrt(length(vecVals));end
	end
	
	%prep plot vecs
	vecInv = length(vecPlot):-1:1;
	vecPlotInv = vecPlot(vecInv);
	
	vecMinTrace = vecMean-vecSE;
	vecMaxTrace = vecMean+vecSE;
	
	%plot
	if boolPlot
		hold on;
		fill([vecPlot vecPlotInv],[vecMinTrace vecMaxTrace(vecInv)],vecFillColor,'EdgeColor',vecFillColor);
		plot(vecPlot,vecMean,'-','Color',vecColor,'LineWidth',2);
		hold off;
	end
	
	%make output
	sOut.vecBins = vecBins;
	sOut.intBins = intBins;
	sOut.vecPlot = vecPlot;
	sOut.vecInv = vecInv;
	sOut.vecPlotInv = vecPlotInv;
	sOut.vecMinTrace = vecMinTrace;
	sOut.vecMaxTrace = vecMaxTrace;
	sOut.vecMean = vecMean;
end

