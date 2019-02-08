function imRotated = imrot(imIn,dblAngle)
	%imrot Rotates an image using nearest-neighbour assignment
	%    imRotated = imrot(imIn,dblAngle)
	%
	%This function rotates the input image coordinates, assigning new
	%nearest-neighbour values to the rotated frame. The output image is the
	%same size as the input image. dblAngle has to be specified in radians.
	%0 radians will lead to no rotation
	
	%get frame
	intImX = size(imIn,2);
	intImY = size(imIn,1);
	
	%get coordinate space
	vecSpaceX = ((-(intImX - 1)/2):(intImX - 1)/2);
	vecSpaceY = ((-(intImY - 1)/2):(intImY - 1)/2);
	[matMeshX,matMeshY] = meshgrid(vecSpaceX,vecSpaceY);
	
	
	% get rotation matrices
	matX_theta=matMeshX*cos(dblAngle)+matMeshY*sin(dblAngle);
	matY_theta=-matMeshX*sin(dblAngle)+matMeshY*cos(dblAngle);
	
	%perform rotation
	matSelectX = round(matX_theta-min(vecSpaceX)+1);
	vecSelectX = matSelectX(:);
	vecSelectX(vecSelectX<1) = 1;
	vecSelectX(vecSelectX>intImX) = intImX;
	matSelectY = round(matY_theta-min(vecSpaceY)+1);
	vecSelectY = matSelectY(:);
	vecSelectY(vecSelectY<1) = 1;
	vecSelectY(vecSelectY>intImY) = intImY;
	
	%get new values in rotated frame
	vecVals = getMatVals(imIn,vecSelectY,vecSelectX);
	imRotated = reshape(vecVals,[intImY intImX]);
	
end
