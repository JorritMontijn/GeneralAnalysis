function intTrough = findtrough(vecV,intLoc,intDirection)
	%findtrough Summary of this function goes here
	%   intTrough = findtrough(vecV,intLoc,intDirection)
	
	if intDirection == -1 %left
		intTrough = nan;
		while isnan(intTrough) && intLoc > 2
			dblDist = vecV(intLoc-1) - vecV(intLoc);
			if dblDist > 0 || intLoc < 3
				intTrough = intLoc-1;
				break;
			else
				intLoc = intLoc - 1;
			end
		end
	else
		intTrough = nan;
		intMax = numel(vecV)-1;
		while isnan(intTrough) && intLoc < intMax
			dblDist = vecV(intLoc+1) - vecV(intLoc);
			if dblDist > 0 || intLoc > (intMax-1)
				intTrough = intLoc+1;
				break;
			else
				intLoc = intLoc + 1;
			end
		end
	end
end

