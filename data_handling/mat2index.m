function [valueVector,yVector,xVector] = mat2index(matrix)
	%mat2index Transforms a matrix into a triple of indexed vectors; one
	%	vector containing x-locations; one vector containing y-locations;
	%	and one vector containing the value so that v(i) corresponds the
	%	original value of the input matrix at y-location y(i) and
	%	x-location x(i)
	%syntax: [valueVector,yVector,xVector] = mat2index(matrix)
	%	Version history:
	%	1.0 - May 11 2011
	%	Created by Jorrit Montijn
	
	[rowNum,columnNum] = size(matrix);
	
	indexMax = rowNum * columnNum;
	valueVector = nan(1,indexMax);
	yVector = nan(1,indexMax);
	xVector = nan(1,indexMax);
	index = 0;
	for x=1:columnNum
		for y=1:rowNum
			thisVal = matrix(y,x);
			if max(isnan(thisVal)) == 0
				index = index + 1;
				yVector(index) = y;
				xVector(index) = x;
				valueVector(index) = thisVal;
			end
		end
	end
	valueVector = valueVector(~isnan(xVector));
	yVector = yVector(~isnan(xVector));
	xVector = xVector(~isnan(xVector));
end