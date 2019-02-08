function plotTube( mat3Resp )
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	%
	%mat3Resp: [intNeuron x intType x intRep]
	
	
	
	
	mat3Mean = xmean(mat3Resp,3);
	
	vecW = xstd(mat3Resp,3)/2;
	vecX = mat3Mean(1,:);
	vecY = mat3Mean(2,:);
	vecZ = mat3Mean(3,:);
	
	%plot wide tube
	%close all;
	figure
	hold on
	
	
	
	% plot tube
	[pnts,conn,line1,line2] = generate_closed_tube(0,vecW,10,vecX,vecY,vecZ);
	
	matC = hsv(length(conn));
	for k=1:length(conn)
		patch('Faces',     conn{k}, ...
			'Vertices',  pnts', ...
			'FaceAlpha', 0.8, ...
			'FaceColor', matC(k,:), ...
			'EdgeColor', 'none' ) ;
	end
	colormap('hsv')
	%xlim([-0.1 1.1]);
	%ylim([-0.1 1.1]);
	%zlim([-0.1 1.1]);
	set(gcf,'Renderer','zbuffer')
	
	%patch([-0.1 -0.1 1.1 1.1],[-0.1 1.1 1.1 -0.1],-0.1*[1 1 1 1],[0.9 0.9 0.9],...
	%	'FaceAlpha',0.1,'FaceColor',[0.9 0.9 0.9],'EdgeColor','none');
	h= cline(vecX,vecY,-0.1*ones(size(vecY)),1:length(vecY));
	set(h,'LineWidth',3,'EdgeColor','interp')
	hold off
	grid on
	
	light('Position',[5 5 7],'Style','infinite');
	lighting gouraud
	
	xlabel('Norm. act. neuron 1')
	ylabel('Norm. act. neuron 2')
	zlabel('Norm. act. neuron 3')
	xlabel(get(get(gca,'xlabel'), 'String'),'FontSize',14); %set x-label and change font size
	ylabel(get(get(gca,'ylabel'), 'String'),'FontSize',14);%set y-label and change font size
	zlabel(get(get(gca,'zlabel'), 'String'),'FontSize',14); %set x-label and change font size
	dblFontSize = 10;
	set(gca,'FontSize',dblFontSize,'Linewidth',2); %set grid line width and change font size of x/y ticks
	
	%vecCamPos = [6.787 -7.2632 3.3646];
	vecCamPos = [17.4080  -12.5633   22.2541];
	set(gca,'cameraposition',vecCamPos)
	
end

