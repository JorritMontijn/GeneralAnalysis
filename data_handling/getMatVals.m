function vecVals = getMatVals(matGrid,vecRow,vecCol)
%getMatVals Description
% 
%   SYNTAX
%    vecVals = getMatVals(matGrid,vecRow,vecCol)
%
%   INPUT
%     matGrid: data matrix (2D)
%     vecRow: vector that determines in which row the corresponding value of
%       vecVals will be entered
%     vecCol: vector that determines in which column the corresponding value
%     of vecVals will be entered
% 
%   OUTPUT
%     vecVals: vector with values corresponding Row-Col pairs 

	global matGridTemp
	matGridTemp = matGrid;
	vecVals = arrayfun(@doGetEl,vecRow,vecCol,'UniformOutput',true);
	clear global matGridTemp
end
function dblVal = doGetEl(intRow,intCol)
	global matGridTemp
	dblVal= matGridTemp(intRow,intCol);
end