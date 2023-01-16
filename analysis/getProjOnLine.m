function [vecProjectedLocation,matProjectedPoints,vecProjLocDimNorm] = getProjOnLine(matPoints,vecRef)
	%getProjOnLine Summary of this function goes here
	%   [vecProjectedLocation,matProjectedPoints,vecProjLocDimNorm] = getProjOnLine(matPoints,vecRef)
	%
	%vecProjectedLocation: norm of projected points along reference vector (dimensionality-dependent)
	%matProjectedPoints: ND locations of projected points
	%vecProjLocDimNorm: norm of projected points, normalized for dimensionality (i.e., /sqrt(D))
	
	%get data
	intD=size(matPoints,1);
	intPoints = size(matPoints,2);
	if intPoints < intD
%		error([mfilename ':WrongDims'],'Number of dimensions is larger than number of points; please make sure matrix is in form [Trials x Neurons]');
	end
	assert(size(vecRef,2)==1,[mfilename ':WrongVectorSize'],'Reference vector input is not a [D x 1] vector');
	assert(size(vecRef,1)==intD,[mfilename ':WrongVectorSize'],'Reference vector input has a different dimensionality to points matrix');
	
	%recenter
	matProj = ((vecRef*vecRef')/(vecRef'*vecRef));
	vecNormRef = vecRef/norm(vecRef);
	
	%calculate projected points
	matProjectedPoints = nan(size(matPoints));
	vecProjectedLocation = nan(size(matPoints,2),1);
	for intTrial=1:size(matPoints,2)
		vecPoint = matPoints(:,intTrial);
		vecOrth = matProj*vecPoint;
		matProjectedPoints(:,intTrial) = vecOrth;
		vecProjectedLocation(intTrial) = vecOrth'/vecNormRef';
	end
	vecProjLocDimNorm = vecProjectedLocation./sqrt(intD);%normalize for number of dimensions so 1 is the norm of the reference vector
	
end
