function [im,imBackground,vecAdjustLim,intSurroundSize] = doEnhanceContrast(im,intSurroundSize,vecAdjustLim)
	%doEnhanceContrast Enhance contrast of image
	%   [im,imBackground,vecAdjustLim,intSurroundSize] = doEnhanceContrast(im,[intSurroundSize/imBackground],vecAdjustLim)
	
	%normalize range
	if max(im(:))>1 || min(im(:)) < 0
		error([mfilename ':InputError'],'Input is not a double in range [0 1]');
	end
	
	%set surround size
	if ~exist('intSurroundSize','var') || isempty(intSurroundSize)
		intSurroundSize = round(min(size(im))/30);
		imBackground = imopen(im, strel('disk', intSurroundSize));
	elseif all(size(intSurroundSize) == size(im))
		%input is background image
		imBackground = intSurroundSize;
	else
		%input is surround size
		intSurroundSize = max(round(min(round(intSurroundSize),max(size(im)))),2);
		imBackground = imopen(im, strel('disk', intSurroundSize));
	end
	
	
	%find new range
	im = imsubtract(im, imBackground);
	if ~exist('vecAdjustLim','var') || isempty(vecAdjustLim)
		vecAdjustLim = stretchlim(im);
	end
	%sharpen
	im = imsharpen(im);
	
	%make new im
	im = imadjust(im,vecAdjustLim);
end

