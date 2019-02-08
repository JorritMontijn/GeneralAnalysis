function vecCoM = calcCenterOfMass(matData,intDim)
	%calcCenterOfMass Gives center of mass for 2D images/matrices
	%   vecCoM = calcCenterOfMass(matData)
	
	[mat1,mat2] = ndgrid(1:size(matData,1),1:size(matData,2));
	dblSum=sum(matData(:));
	vecCoM = zeros(1,2);
	vecCoM(1) = sum(sum(matData.*mat1))/dblSum;
	vecCoM(2) = sum(sum(matData.*mat2))/dblSum;
	
	if nargin == 2
		vecCoM = vecCoM(intDim);
	end
end

