function handleLines = plotGrid3D(handle)
	%plotTube3D Plots 3D tube with specified color-range and width
	%Syntax: handle = plotTube3D(vecX,vecY,vecZ,vecR,vecC,intPointsPerRadius)
	
	%plot 3D tube
	%{
	vecX = [-1 -0.8 -0.3 -0.1 0.05 0.2 0.4 0.7 0.9 1.0];
	vecY = [-0.9 -0.85 -0.2 -0.15 0.1 0.1 0.4 0.7 0.9 1.0];
	vecZ = [-1 -0.8 -0.3 -0.1 0.05 0.2 0.4 0.7 0.9 1.0];
	vecR = [0.1 0.2 0.1 0.3 0.1 0.2 0.2 0.2 0.1 0.3];
	vecC = [0 0.01 0.05 0.1 0.2 0.4 0.5 0.8 0.9 0.95];
	%}
	%check optional inputs
	if nargin < 1 || isempty(handle)
		handle = gca;
	end
	axes(handle); %bring to front
	
	%get x
	vecTickX = get(gca,'xtick');
	strLabelsX = get(gca,'xticklabel');
	cellLabelsX = mat2cell(strLabelsX,ones(1,size(strLabelsX,1)),size(strLabelsX,2));
	vecLimX = [min(vecTickX) max(vecTickX)];
	
	%get y
	vecTickY = get(gca,'ytick');
	strLabelsY = get(gca,'yticklabel');
	cellLabelsY = mat2cell(strLabelsY,ones(1,size(strLabelsY,1)),size(strLabelsY,2));
	vecLimY = [min(vecTickY) max(vecTickY)];
	
	%get z
	vecTickZ = get(gca,'xtick');
	strLabelsZ = get(gca,'xticklabel');
	cellLabelsZ = mat2cell(strLabelsZ,ones(1,size(strLabelsZ,1)),size(strLabelsZ,2));
	vecLimZ = [min(vecTickZ) max(vecTickZ)];
	
	
	%prep x-grid lines
	matX = [vecTickX vecTickX;vecTickX vecTickX];
	matY = [0*vecTickX (0*vecTickX)+vecLimY(1);0*vecTickX (0*vecTickX)+vecLimY(2)];
	matZ = [(0*vecTickX)+vecLimZ(1) 0*vecTickX;(0*vecTickX)+vecLimZ(2) 0*vecTickX];
	
	%prep y-grid lines
	matY = [matY [vecTickY vecTickY;vecTickY vecTickY]];
	matX = [matX [0*vecTickY (0*vecTickY)+vecLimX(1);0*vecTickY (0*vecTickY)+vecLimX(2)]];
	matZ = [matZ [(0*vecTickY)+vecLimZ(1) 0*vecTickY;(0*vecTickY)+vecLimZ(2) 0*vecTickY]];
	
	%prep z-grid lines
	matZ = [matZ [vecTickZ vecTickZ;vecTickZ vecTickZ]];
	matX = [matX [0*vecTickZ (0*vecTickZ)+vecLimX(1);0*vecTickZ (0*vecTickZ)+vecLimX(2)]];
	matY = [matY [(0*vecTickZ)+vecLimY(1) 0*vecTickZ;(0*vecTickZ)+vecLimY(2) 0*vecTickZ]];
	
	%plot
	hold on
	handleLines = line(matX,matY,matZ,'color',[0.5 0.5 0.5],'linestyle',':');
	axis on
	grid on
end