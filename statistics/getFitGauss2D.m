function [vecParams,matFit,resnorm,residual,exitflag] = getFitGauss2D(matDataGrid,vecParam0)
	%% getFitGauss2D Fit a 2D gaussian to data
	% Syntax: [vecParams,resnorm,residual,exitflag,matFit] = getFitGauss2D(matDataGrid,x0)
	%
	% Inputs:
	%   matDataGrid: 2D data matrix
	%   vecParam0 = [z0, gain, x0, x-width, y0, y-width, angle(in rad)]: Initial parameters
	%		Note: angle is optional
	%
	% outputs:
	%	vecParams: [z0, gain, x0, x-width, y0, y-width, angle(in rad)]: Fitted parameters
	%
	% Uses curvefitfun to fit (replace by lsqcurvefit if you have the
	% optimization toolbox), uses get2DGauss to create Gaussians
	% This function automatically removes any non-finite (NaN or Inf)
	% values from the input and linearizes the coordinate system during the
	% fitting process to avoid errors due to NaNs or Infs in the input.
	%
	% If you provide a seventh parameter to vecParam0, it will fit the
	% angle of the Gaussian as well, by rotating the grid. If no second
	% argument is provided, or a vector with only six elements, no rotation
	% is performed.
	%
	%	Version history:
	%	2.0 - October 24 2018
	%	Created by Jorrit Montijn

	
	%% check inputs
	% parameters: [gain, x0, x-width, y0, y-width, angle(in rad)]
	if ~exist('vecParam0','var') || isempty(vecParam0),vecParam0 = [0 max(matDataGrid(:)) size(matDataGrid,1)/2 size(matDataGrid,1)/8 size(matDataGrid,2)/2 size(matDataGrid,2)/8];end
	if length(vecParam0) < 7 %fit for orientation?
		boolFitForOrientation = false;
	else
		boolFitForOrientation = true;
	end
	
	%transform input
	[matGridX,matGridY] = meshgrid(1:size(matDataGrid,2),1:size(matDataGrid,1));
	matGridXY(:,:,1) = matGridX;
	matGridXY(:,:,2) = matGridY;
	dblSize = max(size(matDataGrid));
	dblMaxVal = max(abs(matDataGrid(:)));
	
	%% remove nans
	matNan = isnan(matDataGrid);
	matLinearGridXY(:,1) = matGridX(~matNan);
	matLinearGridXY(:,2) = matGridY(~matNan);
	matLinearData = matDataGrid(~matNan);
	
	%% set lower and upper bounds
	vecLB = [-dblMaxVal,0,0,0,0,0];
	vecUB = [dblMaxVal,realmax('double'),dblSize,dblSize^2,dblSize,dblSize^2];
		
	%% fit
	if boolFitForOrientation ~= 0
		% add dummy lower and upper bounds for rotation
		vecLB(end+1) = -realmax('double');
		vecUB(end+1) = realmax('double');
		[vecParams,resnorm,residual,exitflag] = curvefitfun(@get2DGauss,vecParam0,matLinearGridXY,matLinearData,vecLB,vecUB);
		if nargout > 1
			matFit = get2DGauss(vecParams,matGridXY);
		end
	else
		[vecParams,resnorm,residual,exitflag] = curvefitfun(@get2DGauss,vecParam0,matLinearGridXY,matLinearData,vecLB,vecUB);
		if nargout > 1
			matFit = get2DGauss(vecParams,matGridXY);
		end
	end
	
end

