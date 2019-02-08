function struct = remel(struct,vecElements)
	%RemEl Summary of this function goes here
	%   Detailed explanation goes here
	
	struct = structfun(@doRemEl,struct,'UniformOutput',false);
	function varField = doRemEl(varField)
		varField = varField(vecElements);
	end
end
