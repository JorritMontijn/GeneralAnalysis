function matOut = imcontrastx(matIn,dblContrast,dblBaseline)
	%imcontrast Change contrast of image
	%   matOut = imcontrast(matIn,dblContrast,dblBaseline)
	%
	%	matIn can be matrix of class uint8 or double in range [0-1];
	%	dblContrast will change contrast by this factor (0.5 will half the
	%	contrast); dblBaseline is optional and specifies the background
	%	luminance (default 0.5)
	%
	%	Note: this function does not check under- or oversaturation;
	%	increasing the contrast can lead to values >1
	
	%check inputs
	if nargin < 3
		dblBaseline = 0.5;
	end
	
	%check class
	strClass = class(matIn);
	if strcmp(strClass,'uint8')
		matGrating = im2double(matIn);
		clear matIn;
	elseif strcmp(strClass,'double')
		matGrating = matIn;
		clear matIn;
	else
		error([mfilename ':IncorrectClass'],'Class "%s" is not supported by function %s',strClass,mfilename)
	end
	
	%perform contrast alteration
	matOut = matGrating*dblContrast+(dblBaseline*(1-dblContrast));
	
	%transform type if necessary
	if strcmp(strClass,'uint8')
		matOut = im2uint8(matOut);
	end
end

