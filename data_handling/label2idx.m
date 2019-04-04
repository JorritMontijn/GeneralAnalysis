function [varDataOut,vecUnique,vecCounts] = label2idx(varData)
	%label2idx Transforms label-entries to consecutive integer-based data
	%Syntax: [varDataOut,vecUnique,vecCounts] = label2idx(varData)
	
	varDataOut = nan(size(varData));
	vecUnique = unique(varData);
	vecCounts = zeros(size(vecUnique));
	vecIdx = 1:length(vecUnique);
	for intIdx=vecIdx
		indEntries = varData==vecUnique(intIdx);
		varDataOut(indEntries) = intIdx;
		vecCounts(intIdx) = sum(indEntries);
	end
end

