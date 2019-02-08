function [matX,matY,matV] = idx2mat(vecX,vecY,vecV)
	%idx2mat Transforms a vector into a triple of indexed vectors; one
	%	vector containing x-locations; one vector containing y-locations;
	%	and one vector containing the value so that v(i) corresponds the
	%	original value of the input matrix at y-location y(i) and
	%	x-location x(i)
	%syntax: [matX,matY,matV] = idx2mat(vecX,vecY,vecV)
	%	Version history:
	%	1.0 - Feb 19 2018
	%	Created by Jorrit Montijn
	
	vecMeshX = unique(vecX);
	vecIndX = nan(1,length(vecX));
	for intVal=1:length(vecMeshX)
		vecThisIndex = vecX==vecMeshX(intVal);
		vecIndX(vecThisIndex) = intVal;
	end
	vecMeshY = unique(vecY);
	vecIndY = nan(1,length(vecY));
	for intVal=1:length(vecMeshY)
		vecThisIndex = vecY==vecMeshY(intVal);
		vecIndY(vecThisIndex) = intVal;
	end
	[matX,matY] = meshgrid(vecMeshX,vecMeshY);
	matV = zeros(size(matX));	
	vecLinearIndex = sub2ind(size(matX), vecIndY, vecIndX);
	matV(vecLinearIndex) = vecV;
end
