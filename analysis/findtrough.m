function [intTrough,dblTrough] = findtrough(vecV,intLoc,intDirection)
	%findtrough Finds nearest trough in leftward (-1) or rightward (+1) direction
	%   [intTrough,dblTrough] = findtrough(vecV,intLoc,intDirection)
	
	if intDirection == -1 %left
		intTrough = nan;
		while isnan(intTrough) && intLoc > 2
			dblDist = vecV(intLoc-1) - vecV(intLoc);
			if dblDist > 0 || intLoc < 3
				intTrough = intLoc;
				break;
			else
				intLoc = intLoc - 1;
			end
		end
		if isnan(intTrough)
			intTrough = 1;
		end
	else
		intTrough = nan;
		intMax = numel(vecV)-1;
		while isnan(intTrough) && intLoc < intMax
			dblDist = vecV(intLoc+1) - vecV(intLoc);
			if dblDist > 0 || intLoc > (intMax-1)
				intTrough = intLoc;
				break;
			else
				intLoc = intLoc + 1;
			end
		end
		if isnan(intTrough)
			intTrough = numel(vecV);
		end
	end
	dblTrough = vecV(intTrough);
end

