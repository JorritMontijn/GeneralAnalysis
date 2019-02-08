function imageEnhanced = imenhance(image)
	%imHQ Transform image to contrast-enhanced version
	%   imageEnhanced = imHQ(image)
	image = im2double(image);

	imageEnhanced = zeros(size(image));
	for intCh=1:size(image,3)
		imThis = image(:,:,intCh);
		imThis(isnan(imThis)) = nanmean(imThis(:));
		imMin = min(imThis(:));
		imMax = max(imThis(:));
		if imMin == imMax
			imThisNew = zeros(size(image,1),size(image,2));
		else
			backGroundRaw = imopen(imThis, strel('disk', 30)) ;
			imThisNew = imsubtract(imThis, backGroundRaw) ;
			imThisNew = imadjust(imThisNew);
		end
		imageEnhanced(:,:,intCh) = imThisNew;
	end
end

