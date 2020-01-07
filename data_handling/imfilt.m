function matImage = imfilt(matImage,matFilt,strPadVal)
	%imfilt 2D image filtering. Syntax:
	%   matData = imfilt(matImage,matFilt,strPadVal)
	%
	%	input:
	%	- matImage; [X by Y] image matrix (can be gpuArray)
	%	- matFilt: [M by N] filter matrix (can be gpuArray)
	%	- strPadVal: optional (default: 'symmetric'), padding type using padarray.m
	%
	%Version history:
	%1.0 - 16 Dec 2019
	%	Created by Jorrit Montijn
	
	%get padding type
	if ~exist('strPadVal','var') || isempty(strPadVal)
		strPadVal = 'symmetric';
	end
	
	%pad array
	matImage = padarray(matImage,floor(size(matFilt)/2),strPadVal);
	
	%filter
	matImage = conv2(matImage,matFilt,'valid');
end

