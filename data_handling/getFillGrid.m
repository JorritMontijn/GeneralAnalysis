function matGrid = getFillGrid(matGrid,vecRow,vecCol,vecVals)
%getFillGrid Adds values in vecVals to the paired locations [vecRow
%vecCol] in the 2D matrix matGrid
% 
%   SYNTAX
%     matGrid = getFillGrid(matGrid,vecRow,vecCol,vecVals)
%
%   INPUT
%     matGrid: 2D input matrix
%     vecRow: vector that determines in which row the corresponding value of
%       vecVals will be entered
%     vecCol: vector that determines in which column the corresponding value
%		 of vecVals will be entered
%     vecVals: vector of to-be-assigned values, if scalar it will be
%		enlarged to the size of vecRow and vecCol
% 
%   OUTPUT
%     matGrid: summation of input matGrid and assigned values from vecVals
%
%	Version history:
%	1.0 - March 13 2015
%	Created by Jorrit Montijn

	
	if nargin < 4,vecVals=ones(size(vecRow,1),1);end
	if numel(vecVals) == 1,vecVals=vecVals*ones(size(vecRow));end
	
	%global vecMatSize;
	%vecMatSize = size(matGrid);
	for intIdx=1:numel(vecRow)
		matGrid(vecRow(intIdx),vecCol(intIdx)) = matGrid(vecRow(intIdx),vecCol(intIdx))+vecVals(intIdx);
	end
	%clear global vecMatSize;
end
function matGridTemp = doFillEl(intRow,intCol,dblVal)
	global vecMatSize;
 	matGridTemp = zeros(vecMatSize);
	matGridTemp(intRow,intCol) = dblVal;
end