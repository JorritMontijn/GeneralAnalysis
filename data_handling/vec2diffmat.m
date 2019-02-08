function matDiff = vec2diffmat(vecVals,sParams)
	%UNTITLED3 Summary of this function goes here
	%   Detailed explanation goes here
	
	%check input
	if ndims(vecVals) > 2 || (size(vecVals,1) > 1 && size(vecVals,2) > 1)
		error([mfilename ':NotAVector'],'Input is not a vector');
	end
	if ~exist('sParams','var'), sParams = [];end
	if isempty(sParams) || ~isfield(sParams,'boolAngDiff')
		boolAngDiff = false;
	else
		boolAngDiff = sParams.boolAngDiff;
	end
	if isempty(sParams) || ~isfield(sParams,'boolMean')
		boolMean = false;
	else
		boolMean = sParams.boolMean;
	end
	%transform
	intL = length(vecVals);
	vecZ=1:intL;
	vecZ(:) = vecVals;
	
	matX=repmat(vecZ,[intL 1]);
	matY=repmat(vecZ',[1 intL]);
	
	if boolAngDiff
		matDiff =  circ_dist(matY,matX);
	elseif boolMean
		matDiff = (matY+matX)./2;
	else
		matDiff = matY-matX;
	end
end

