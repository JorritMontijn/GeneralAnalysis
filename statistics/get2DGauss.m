function varZ = get2DGauss(vecParams,matGridXY)
%% get2DGauss build 2D Gaussian based on X and Y coordinates
% Syntax: varZ = get2DGauss(vecParams,matGridXY)
%	Rotation matrix is given by Mrot = [cos(phi) -sin(phi); sin(phi) cos(phi)]
%
% Inputs:
%	vecParams = [z-const, Amp, x0, wx, y0, wy, phi] 
%		(phi is optional for rotation)
%	matGridXY can take two formats:
%	1) [m x n x 2], with x-coordinates in (:,:,1) and y in (:,:,2)
%	2) [p x 2], with x-coordinates in (:,1) and y-coordinates in (:,2)
%
%	Option 1 conforms to meshgrid output, where 
%		matGridXY(:,:,1) = X
%		matGridXY(:,:,2) = Y
%	Option 2 is the native format of getFitGauss2D(), allowing it to ignore
%		possible NaN values in the fitting process
%
% Outputs:
%	varZ are the values at z=(x,y)
%
%	Version history:
%	2.0 - October 24 2018
%	Created by Jorrit Montijn

%% check format of grid
if ndims(matGridXY) == 3 && size(matGridXY,3) == 2
	varGridX = matGridXY(:,:,1);
	varGridY = matGridXY(:,:,2);
elseif ndims(matGridXY) == 2 && size(matGridXY,2) == 2 %#ok<ISMAT>
	varGridX = matGridXY(:,1);
	varGridY = matGridXY(:,2);
else
	error([mfilename ':WrongGridSyntax'],'Grid format not recogized');
end

%% get Gaussian
if length(vecParams) > 6
	%perform rotation
	vecGridX_rot = varGridX*cos(vecParams(7)) - varGridY*sin(vecParams(7));
	vecGridY_rot = varGridX*sin(vecParams(7)) + varGridY*cos(vecParams(7));
	dblX0rot = vecParams(3)*cos(vecParams(7)) - vecParams(5)*sin(vecParams(7));
	dblY0rot = vecParams(3)*sin(vecParams(7)) + vecParams(5)*cos(vecParams(7));
	
	%build Gaussian
	varZ = vecParams(1) + vecParams(2)*exp(   -((vecGridX_rot-dblX0rot).^2/(2*vecParams(4)^2) + (vecGridY_rot-dblY0rot).^2/(2*vecParams(6)^2) )    );
	
else
	%build Gaussian
	varZ = vecParams(1) + vecParams(2)*exp(   -((varGridX-vecParams(3)).^2/(2*vecParams(4)^2) + (varGridY-vecParams(5)).^2/(2*vecParams(6)^2) )    );
end

