function cellOut = groupby(varData,varGroups)
	%groupby Summary of this function goes here
	%   cellOut = groupby(varData,vecGroups)
	if ndims(varGroups) ~= ndims(varData) || ~all(size(varData) == size(varGroups))
		error([mfilename ':DimensionMismatch'],'Size of data and grouping variable are different');
	end
	[vecGroupIdx,vecUnique] = val2idx(varGroups);
	cellOut = cell(1,numel(vecUnique));
	for i=1:numel(vecUnique)
		cellOut{i} = varData(varGroups==vecUnique(i));
	end
end

