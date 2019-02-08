function [vecMeans,vecBinEdges,cellValues] = getQuintiles(vecIn,vecBinEdges,intSegments)
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	
	
	
	%calc edges (if necessary)
	vecIn = vecIn(:);
	if nargin < 2 || isempty(vecBinEdges)
		if nargin < 3 || isempty(intSegments)
			intSegments = 5;
		end
		vecSort=sort(vecIn);
		intN = length(vecSort);
		
		
		vecLow=round(linspace(1,intN+1,intSegments+1));
		vecHigh=round(linspace(0,intN,intSegments+1));
		vecLow = vecLow(1:(end-1));
		vecHigh = vecHigh(2:end);
		
		vecLowVal = vecSort(vecLow);
		vecHighVal = vecSort(vecHigh);
		
		vecBinEdges = (vecHighVal(1:(end-1))-vecLowVal(2:end))/2 + vecLowVal(2:end);
	end
	intSegments = length(vecBinEdges)+1;
	
	%get values per segment
	vecMeans = nan(1,intSegments);
	indSegment = vecIn<=vecBinEdges(1);
	vecMeans(1) = mean(vecIn(indSegment));
	if nargout>2
		cellValues = cell(1,intSegments);
		cellValues{1} = vecIn(indSegment);
	end
	for intSegment=2:(intSegments-1)
		indSegment = vecIn>vecBinEdges(intSegment-1) & vecIn<=vecBinEdges(intSegment);
		vecMeans(intSegment) = mean(vecIn(indSegment));
		if nargout>2,cellValues{intSegment} = vecIn(indSegment);end
	end
	indSegment = vecIn>vecBinEdges(intSegments-1);
	vecMeans(intSegments) = mean(vecIn(indSegment));
	if nargout>2,cellValues{intSegments} = vecIn(indSegment);end
end

