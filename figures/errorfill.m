function [handleFill,handleLine] = errorfill(vecX,vecY,vecErr1,varargin)
	%errorfill Plot mean +- shaded error region
	%   Syntax: [handleFill,handleLine] = errorfill(vecX,vecY,vecErr,[vecErr2],[vecColor])
	%
	%	input:
	%	- vecX; vector with x-values
	%	- vecY; vector with y-values
	%	- vecErr; vector with error-values for shaded area
	%	- [vecErr2]; optional, if supplied the above vector is used as
	%				upper-limits, and this vector is used as lower-limits
	%	- vecColor; optional 3-element RGB colour vector (default is blue)
	%	
	%	Version history:
	%	1.0 - August 1 2013
	%	Created by Jorrit Montijn
	%	2.0 - Feb 6 2019
	%	Updated to use alpha-mapping for transparency of shaded area
	
	%% check inputs
	if ~isempty(varargin) && length(varargin{1}) == length(vecErr1)
		intArgOffset = 1;
		vecErr2 = varargin{1};
	else
		intArgOffset = 0;
		vecErr2 = vecErr1;
	end
	
	if nargin >= 4+intArgOffset && length(varargin{1+intArgOffset}) == 3
		vecColor = varargin{1+intArgOffset};
	else
		vecColor = [0 0 1];
	end
	
	%% prep inputs
	%switch orientation
	vecX = vecX(:)';
	vecY = vecY(:)';
	vecErr1 = vecErr1(:)';
	vecErr2 = vecErr2(:)';
	
	%get selections
	intX = length(vecX);
	vecWindowInv = intX:-1:1;
	vecXinv = vecX(vecWindowInv);
	
	%plot
	hold on
	handleFill = patch([vecX vecXinv],[vecY+vecErr1 vecY(vecWindowInv)-vecErr2(vecWindowInv)],vecColor,'EdgeColor','none');
	alpha(handleFill,.5);
	handleLine = plot(vecX,vecY,'-','LineWidth',2,'Color',vecColor);
	hold off
	drawnow;
end

