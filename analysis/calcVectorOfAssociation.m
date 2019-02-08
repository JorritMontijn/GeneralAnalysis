function dblR = calcVectorOfAssociation(matData,vecY,vecZ)
	%calcVectorOfAssociation Measure of correlation for binned grid data
	%   dblR = calcVectorOfAssociation(matData)
	
	if nargin == 1 && all(size(matData) > 2) %compute grid-based VoA
		%get center of mass
		vecCoM = calcCenterOfMass(matData);
		
		%calculate vectors to CoM & decompose x-y components
		[mat1,mat2] = ndgrid(1:size(matData,1),1:size(matData,2));
		mat1 = (mat1 - vecCoM(1));
		mat2 = (mat2 - vecCoM(2));
		
		%take product of x/y components & multiply those products by squared probability density value
		matProd = mat1.*mat2.*(matData.*matData);
		
		%divide sum of those values by sum of absolute of those values
		dblR = sum(matProd(:))/sum(abs(matProd(:)));
		dblR = dblR*abs(dblR);
	elseif nargin > 1 && all([min(size(matData)) min(size(vecY))] == 1) && numel(matData) == numel(vecY) %use coordinate-based VoA
		%rename variable
		vecX=matData;clear matData; 
		
		%check for z-vector
		if nargin < 3 || isempty(vecZ),vecZ = ones(size(vecX));end
		
		%normalize x/y range
		vecX = vecX - min(vecX);
		vecX = vecX / max(vecX);
		vecY = vecY - min(vecY);
		vecY = vecY / max(vecY);
		
		%calculate center of mass
		dblCenterX = sum(vecX.*vecZ)/sum(vecZ);
		dblCenterY = sum(vecY.*vecZ)/sum(vecZ);
		
		%calculate x/y components
		vecDistX = vecX - dblCenterX;
		vecDistY = vecY - dblCenterY;
		
		%take product of x/y components & multiply those products by squared probability density value
		vecProd = vecDistX.*vecDistY.*(vecZ.*vecZ);
		
		%divide sum of those values by sum of absolute of those values
		dblR = sum(vecProd(:))/sum(abs(vecProd(:)));
		dblR = dblR*abs(dblR);
	else
		error([mfilename ':InputError'],'Inputs are inconsistent');
	end
end

