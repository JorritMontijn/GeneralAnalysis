function vecVals = getValByIdx(matVals,matSelection)
%getMatVals Description
% 
%   SYNTAX
%    vecVals = getMatVals(matVals,matSelection)
%
%   INPUT
%     matVals: data matrix
%     matSelection: selection matrix of integers (same size as matVals)
% 
%   OUTPUT
%     vecVals: vector with values corresponding to selection of values in
%			matVals at locations specified by matSelection

	intNrVals = sum(matSelection(:));
	vecVals = nan(1,intNrVals);
	intCounter = 0;
	for intIter=1:max(matSelection(:))
		matSelect = matSelection>0;
		intVals = sum(matSelect(:));
		vecVals((intCounter+1):(intVals+intCounter)) = matVals(matSelect);
		intCounter = intCounter + intVals;
		matSelection = matSelection - 1;
	end
	if numel(vecVals) ~= intNrVals,warning([mfilename ':IncorrectNrOfElements'],'Number of output elements is different from expected');end
end