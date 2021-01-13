function matGabor = getGabor(matMeshX,matMeshY,dblCenterX,dblCenterY,sigma,length,theta,dblSF,psi)
	%getGabor Creates scaleable gabor filter
	%   matGabor = getGabor(matMeshX,matMeshY,dblCenterX,dblCenterY,sigma,length,theta,dblSF,psi)
	%
	% inputs:
	%matMeshX = mesh grid for x
	%matMeshY = mesh grid for y
	%dblCenterX = x-center
	%dblCenterY = y-center
	%sigma = sd of gaussian envelope (width)
	%length = length of gabor along direction of bars, relative to width (gamma=1/length)
	%theta = orientation
	%dblSF = spatial frequency (lambda=1/dblSF)
	%psi = phase
	
	%% derived parameters
	boolPlot = false;
	x0 = dblCenterX; %RF center x
	y0 = dblCenterY; %RF center y
	lambda = 1/dblSF; %wavelength
	width = 1; %width is fixed
	gamma = width/length; %aspect ratio
	
	%grid and RFs
	[m,n] = size(matMeshX);
	x = matMeshX;
	y = matMeshY;
	
	%% scale & rotation
	xscale = 1;
	yscale = 1;
	matS = [xscale 0;...
		0 yscale]; %no longer used
	matR = [cos(theta) -sin(theta);...
		sin(theta) cos(theta)];
	matXY = matS*matR*[flat(x-x0)';flat(y-y0)'];
	xprime = matXY(1,:);
	yprime = matXY(2,:);
	
	%% compute gabor
	matGabor = ...
		exp(-0.5*(((xprime.^2) + (gamma^2)*(yprime.^2))/(sigma^2)))...
		.* cos(2*pi*(xprime./lambda)+psi);
	%reshape
	matGabor = reshape(matGabor,[m n]);
	
	%% plot?
	if boolPlot
		figure
		imagesc(matGabor)
		daspect([1 1 1])
	end
end

%{
%function [outputArg1,outputArg2] = getGabor(inputArg1,inputArg2)
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	clear all
	m = 256;
	n = 256;
	
	dblSF = 1/16; %in input units
	psi = 0; %phase
	lambda = 1/dblSF; %wavelength
	scale = dblSF;
	sigma = 8; %sd of gaussian width
	theta = pi/8; %orientation
	
	
	width = 1; %width is fixed
	length = 1; %length is variable
	
	%scale = scale*width;
	gamma = width/length; %aspect ratio
	
	xscale = 1;%1/width;
	yscale = 1;%1/length;
	
	[x,y] = meshgrid(1:m,1:n);
	x0 = ((m+1)/2); %RF center x
	y0 = ((n+1)/2); %RF center y
	
	%scaling matrix
	matS = [xscale 0;...
		0 yscale];
	%rotation
	matR = [cos(theta) -sin(theta);...
		sin(theta) cos(theta)];
	matXY = matS*matR*[flat(x-x0)';flat(y-y0)'];
	xprime = matXY(1,:);
	yprime = matXY(2,:);
	
			%xprime = (x-x0)*cos(theta)+(y-y0)*sin(theta);
			%yprime = -(x-x0)*sin(theta)+(y-y0)*cos(theta);
			
			%xprime = (x-x0)*cos(-theta)+(y-y0)*sin(-theta);
			%yprime = -(x-x0)*sin(-theta)+(y-y0)*cos(-theta);
			
			
			%gFilter = ((scale^2)/(2*pi)).*exp(-((alpha^2)*(xprime.^2)+(beta^2)*(yprime.^2))).*exp(1i.*2.*pi.*scale.*xprime);

			%gFilter = ((scale^2)/(2*pi)).*exp(-(((xprime.^2)+(yprime.^2))/(2*sigma^2))).*exp(1i.*2.*pi.*scale.*xprime);

			
			gFilter = ...
				exp(-0.5*(((xprime.^2) + (gamma^2)*(yprime.^2))/(sigma^2)))...
				.* cos(2*pi*(xprime./lambda)+psi);
		
			
			gFilter = reshape(gFilter,[m n]);
	figure
imagesc(real(gFilter))
daspect([1 1 1])
%end

%}