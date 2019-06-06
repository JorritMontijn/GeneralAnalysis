function implot(matData,vecScale,matColormap,dblLineWidth)
	%implot Creates vectorized heat map plot using lines instead of bitmaps
	%as with imagesc(). Syntax:
	%   implot(matData,vecScale,matColormap,dblLineWidth)
	%
	%
	%	Version history:
	%	1.0 - July 22 2015
	%	Created by Jorrit Montijn
	%
	%Dependencies: makeBins.m
	
	%scale input
	if nargin < 2 || isempty(vecScale)
		vecScale = [min(matData(:)) max(matData(:))];
	end
	dblMin = vecScale(1);
	dblMax = vecScale(2);
	matData(matData<dblMin) = dblMin;
	matData(matData>dblMax) = dblMax;
	
	%get binning parameters
	if nargin < 3 || isempty(matColormap)
		intValues = min([length(unique(matData(:))) 128]);
		if intValues == 2
			matColormap = [1 1 1; 0 0 0];
		else
			matColormap = hot(intValues);
		end
	else
		intValues = size(matColormap,1);
	end
	vecBin =  linspace(dblMin-eps, dblMax+eps, intValues+1);
	
	%get line width
	if nargin < 4 || isempty(dblLineWidth)
		dblLineWidth = 1.5;
	end
	
	%bin input & plot
	hold on;
	for intBin=1:intValues
		if intValues == 2 && intBin == 1
			continue;
		end
		vecColor = matColormap(intBin,:);
		dblThisMin = vecBin(intBin);
		dblThisMax = vecBin(intBin+1);
		[row,col] = find(matData>dblThisMin & matData<=dblThisMax);
		line([col';col'],[row'-0.5;row'+0.5],'Color',vecColor,'LineWidth',dblLineWidth);
	end
	hold off;
	xlim([0 size(matData,2)+1]);
	ylim([0.5 size(matData,1)+0.5]);
end

