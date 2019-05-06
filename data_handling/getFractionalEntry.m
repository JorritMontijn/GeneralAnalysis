function dblValue = getFractionalEntry(vecList,dblFractionalEntry)
	%getFractionalEntry Returns fractional entry from input list
	%	dblValue = getFractionalEntry(vecList,dblFractionalEntry)
	%
	%Inputs:
	% - vecList; [1 x N] data vector
	% - dblFractionalEntry; [scalar] fractional entry (e.g., 2.345)
	%
	%Output:
	% - dblValue; extracted value from vecList, weighted by dblFractionalEntry
	%
	%Version History:
	%2019-05-06 Created [by Jorrit Montijn]
	
	%calc indices
	intCeil = ceil(dblFractionalEntry);
	intFloor = floor(dblFractionalEntry);
	dblWeightFloor = intCeil - dblFractionalEntry;
	dblWeightCeil = 1 - dblWeightFloor;
	
	%get value
	dblValue = vecList(intCeil) * dblWeightCeil + vecList(intFloor) * dblWeightFloor;
end