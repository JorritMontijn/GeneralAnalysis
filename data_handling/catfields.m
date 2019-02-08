function sCat = catfields(sIn,cellFields,boolRemNans)
	%catfields Concatenates fields in structure
	%   Syntax:  sCat = catfields(sIn,cellFields,boolRemNans)
	
	%get fieldnames to run
	if nargin < 2 || isempty(cellFields)
		cellFields = fieldnames(sIn);
	end
	if nargin < 3 || isempty(boolRemNans)
		boolRemNans = true;
	end
	
	%run through fields
	sCat = struct;
	for intField=1:numel(cellFields)
		strField = cellFields{intField};
		sCat.(strField) = [];
		
		%run through elements of structure
		for intE=1:numel(sIn)
			if iscell(sIn(intE).(strField)) %special case; go down one level
				for intCell=1:numel(sIn(intE).(strField))
					if boolRemNans
						vecCat = sIn(intE).(strField){intCell}(~isnan(sIn(intE).(strField){intCell}));
					else
						vecCat = sIn(intE).(strField){intCell};
					end
					if ~iscell(sCat.(strField))
						sCat.(strField) = cell(size(sIn(intE).(strField)));
					end
					sCat.(strField){intCell} = cat(find(size(sIn(intE).(strField){intCell})==max(size(sIn(intE).(strField){intCell})),1,'last'),sCat.(strField){intCell},vecCat);
				end
			elseif isa(sIn(intE).(strField),'numeric') %easy concat
				if boolRemNans
					vecCat = sIn(intE).(strField)(~isnan(sIn(intE).(strField)));
				else
					vecCat = sIn(intE).(strField);
				end
				sCat.(strField) = cat(find(size(sIn(intE).(strField))==max(size(sIn(intE).(strField))),1,'last'),sCat.(strField),vecCat);
			elseif isstruct(sIn(intE).(strField)) %attempt recursive calling
				warning([mfilename ':RecursiveStructs'],'Input struct has embedded structs... Attempting recursive call');
				sCat.(strField) = catfields(sIn(intE).(strField));
			end
		end
	end
end

