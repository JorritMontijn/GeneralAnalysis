function [matX,matY,matV] = ind2mat(vecX,vecY,vecV)
	vecMeshX = getUniqueVals(vecX);
	vecIndX = nan(1,length(vecX));
	for intVal=1:length(vecMeshX)
		vecThisIndex = vecX==vecMeshX(intVal);
		vecIndX(vecThisIndex) = intVal;
	end
	vecMeshY = getUniqueVals(vecY);
	vecIndY = nan(1,length(vecY));
	for intVal=1:length(vecMeshY)
		vecThisIndex = vecY==vecMeshY(intVal);
		vecIndY(vecThisIndex) = intVal;
	end
	[matX,matY] = meshgrid(vecMeshX,vecMeshY);
	matV = nan(size(matX));	
	vecLinearIndex = sub2ind(size(matX), vecIndY, vecIndX);
	matV(vecLinearIndex) = vecV;
end