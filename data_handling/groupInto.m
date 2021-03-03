function vecNewIdx = groupInto(cellOldNames,cellGroupInto)
	%groupInto Groups names in cellOldNames into groups defined by cellGroupInto
	%   vecNewIdx = groupInto(cellOldNames,cellGroupInto)
	[cellUnique,a,vecOldIdx] = unique(cellOldNames);
	cellGrouped = cellfun(@(x,y) find(contains(x,y,'IgnoreCase',true)),cellfill(cellUnique,size(cellGroupInto)),cellGroupInto,'UniformOutput',false);
	intUnique = numel(cellUnique);
	vecGroupInto = nan(1,intUnique);
	vecNewIdx = vecOldIdx;
	for intGroup=1:intUnique
		intNewIdx = find(cellfun(@ismember,cellfill(intGroup,size(cellGrouped)),cellGrouped));
		if isempty(intNewIdx),intNewIdx=0;end
		vecGroupInto(intGroup) = intNewIdx;
		vecNewIdx(vecOldIdx==intGroup)=intNewIdx;
	end
end

