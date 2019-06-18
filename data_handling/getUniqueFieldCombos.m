function sUniqueCombos = getUniqueFieldCombos(sData,cellFields)
	%getUniqueFieldCombos Retrieve unique value-combinations from data structure
	%   Syntax: sUniqueCombos = getUniqueFieldCombos(sData,cellFields)
	%
	%	Outputs four fields in structOut:
	%		vecUniqueIdx	vector containing unique indices corresponding to matIdx
	%		matIdx			matrix containing indexed label values
	%		vecNumTypes		vector containing number of unique values per field
	%		cellNames		cell array containing names of fields
	%
	%	Version history:
	%	1.0 - June 11 2019
	%	Created by Jorrit Montijn, based on getStimulusTypes()
	
	%% check which fields are present
	%field list
	if ~exist('cellFields','var')
		cellFields = fieldnames(sData);
	end
	
	%pre-allocate variables
	cellNames = {};
	intUseFields = 0;
	
	%loop through fields to check for presence
	for intField=1:numel(cellFields)
		strField = cellFields{intField};
		if isfield(sData,strField) && min(cell2mat({sData.(strField)})) ~= max(cell2mat({sData.(strField)}))
			cellNames{end+1} = strField; %#ok<AGROW>
			intUseFields = intUseFields + 1;
		end
	end
	
	%% check if only single combination is present
	if intUseFields == 0
		sUniqueCombos.vecUniqueIdx = ones(size(sData,2),1);
		sUniqueCombos.matIdx = [];
		sUniqueCombos.vecNumTypes = [];
		sUniqueCombos.cellNames = {};
		return;
	end
	
	%% loop through fields to retrieve types
	intEntries = size(sData,2);
	vecNumTypes = zeros(1,intUseFields);
	matIdx = nan(intEntries,intUseFields);
	for intField=1:intUseFields
		strField = cellNames{intField};
		
		%get stim values of all trials
		cellVals = {sData.(strField)};
		if all(cellfun(@isnumeric,cellVals))
			cellVals = cell2mat(cellVals);
			[vecUniqueVals,dummy,vecUniqueIdx] = unique(cellVals);
			cellUniqueVals = vec2cell(vecUniqueVals);
		else
			[cellUniqueVals,dummy,vecUniqueIdx] = unique(cellVals);
		end
		
		%assign uniques
		matIdx(:,intField) = vecUniqueIdx;
		
		%assign number to output vector
		intVals = length(cellUniqueVals);
		vecNumTypes(intField) = intVals;
	end
	
	%% calculate which combinations are copies
	vecReqBits = floor(log2(max(matIdx,[],1))+1);
	vecEndBit = cumsum(vecReqBits);
	intBinarySize = vecEndBit(end);
	binArray = false(intEntries,intBinarySize);
	for intEntry=1:intEntries
		for intField=1:intUseFields
			indUseBits = false(1,intBinarySize);
			indUseBits((vecEndBit(intField)-vecReqBits(intField)+1):vecEndBit(intField)) = true;
			indBinVal = bitget(matIdx(intEntry,intField),1:vecReqBits(intField),'uint64');
			binArray(intEntry,indUseBits) = indBinVal;
		end
	end
	vecMult = 2.^((1:intBinarySize)-1);
	[dummy,dummy,vecUniqueIdx] = unique(sum(bsxfun(@times,binArray,vecMult),2));
	
	%% assign output
	sUniqueCombos.vecUniqueIdx = vecUniqueIdx;
	sUniqueCombos.matIdx = matIdx;
	sUniqueCombos.vecNumTypes = vecNumTypes;
	sUniqueCombos.cellNames = cellNames;
end

