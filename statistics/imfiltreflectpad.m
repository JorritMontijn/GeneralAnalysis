function matFilteredSignal = imfiltreflectpad(matSignal,matFilter)
	%buildConvolutedMatrix applies 2D convolution of matFilter to matSignal
	%with edge-reflected copies of the signal matrix
	%   matFilteredSignal = imfiltreflectpad(matSignal,matFilter)
	%
	%	Version history:
	%	2.0 - July 20 2015
	%	Created by Jorrit Montijn
	
	
	%which one is bigger?
	if ((size(matSignal,1) >= size(matFilter,1)) && (size(matSignal,2) >= size(matFilter,2)))
		matLarge = matSignal; matSmall = matFilter;
	elseif  ((size(matSignal,1) <= size(matFilter,1)) && (size(matSignal,2) <= size(matFilter,2)))
		matLarge = matFilter; matSmall = matSignal;
	else
		error(['buildConvolutedMatrix: incompatible dimensions: ' num2str(size(matSignal)) ' ' num2str(size(matFilter))]);
	end
	
	%padding size
	ly = size(matLarge,1);
	lx = size(matLarge,2);
	sy = size(matSmall,1);
	sx = size(matSmall,2);
	
	%increase size of large matrix by half of small matrix minus one
	sy2 = floor((sy-1)/2);
	sx2 = floor((sx-1)/2);
		
		
	intPaddingType = 0;
	if intPaddingType ~= 1
		% pad with reflected copies (by Eero Simoncelli, 6/96; modified by Jorrit Montijn for cylindrical space (top/down connected))
		
		%reflected padding
		lMatrix = [
			matLarge(sy-sy2:-1:2,sx-sx2:-1:2), matLarge(sy-sy2:-1:2,:), matLarge(sy-sy2:-1:2,lx-1:-1:lx-sx2); ...
			matLarge(:,sx-sx2:-1:2),    matLarge,   matLarge(:,lx-1:-1:lx-sx2); ...
			matLarge(ly-1:-1:ly-sy2,sx-sx2:-1:2), matLarge(ly-1:-1:ly-sy2,:), matLarge(ly-1:-1:ly-sy2,lx-1:-1:lx-sx2) ];
		
		%cylindrial (top-down connected) with reflected padding
		%lMatrix = [
		%	matLarge(ly-sy2:1:ly-1,sx-sx2:-1:2), matLarge(ly-sy2:1:ly-1,:), matLarge(ly-sy2:1:ly-1,lx-1:-1:lx-sx2); ...
		%	matLarge(:,sx-sx2:-1:2),    matLarge,   matLarge(:,lx-1:-1:lx-sx2); ...
		%	matLarge(2:1:sy-sy2,sx-sx2:-1:2), matLarge(2:1:sy-sy2,:), matLarge(2:1:sy-sy2,lx-1:-1:lx-sx2) ];
		
		%uses matlab's built-in convolution function. because of the 'valid'
		%parameter it will only return the inner part of the convoluted matrix
		%that were not computed using zero-padded edges
		matFilteredSignal = conv2(lMatrix,matSmall,'valid');
	else
		lMatrix = padarray(matLarge, [sy2 sx2],1);
		matFilteredSignal = conv2(lMatrix,matSmall,'valid');
	end
	
	%toc(tStart);
	if size(matSignal,1) ~= size(matFilteredSignal,1) || size(matSignal,2) ~= size(matFilteredSignal,2)
		error(['Size of input matrix: [' num2str(size(matSignal)) '] is not size of convoluted matrix: [' num2str(size(matFilteredSignal)) ']'])
	end
end

