function i = findfirst(dblVal,vecVals)
	%findfirst Find first entry in sorted vector vecVals where dblVal >= vecVals
	%   i = findfirst(dblVal,vecVals)
	dblMax = max(vecVals);
	dblMin = min(vecVals);
	dblRange = dblMax-dblMin;
	intNum = numel(vecVals);
	if dblVal>dblMax
		i = intNum;
	elseif dblVal<dblMin
		i = 1;
	else
		%estimate initial position
		intStart=round(intNum*((dblVal-dblMin)/dblRange));
		if intStart < 1,intStart=1;end
		if intStart > intNum,intStart=intNum;end
		if dblVal>vecVals(intStart)
			%go up
			for i=(intStart+1):intNum
				if dblVal<=vecVals(i)
					break;
				end
			end
		else
			%go up
			for i=intStart:-1:1
				if dblVal>=vecVals(i)
					break;
				end
			end
		end
	end
end

