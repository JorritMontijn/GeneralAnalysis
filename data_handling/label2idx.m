function [varDataOut,vecUnique] = label2idx(varData)
	%UNTITLED6 Summary of this function goes here
	%   Detailed explanation goes here
	
	varDataOut = nan(size(varData));
	vecUnique = unique(varData);
	vecIdx = 1:length(vecUnique);
	for intIdx=vecIdx
		varDataOut(varData==vecUnique(intIdx)) = intIdx;
	end
end

