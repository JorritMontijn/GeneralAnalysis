function [valueVector,yVector,xVector] = mat2ind(matrix)
	[rowNum,columnNum] = size(matrix);
	
	indexMax = rowNum * columnNum;
	valueVector = zeros(1,indexMax);
	yVector = zeros(1,indexMax);
	xVector = zeros(1,indexMax);
	index = 0;
	for x=1:columnNum
		for y=1:rowNum
			index = index + 1;
			yVector(index) = y;
			xVector(index) = x;
			valueVector(index) = matrix(y,x);
		end
	end
end