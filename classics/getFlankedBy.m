function [strOut,intStop] = getFlankedBy(strInput,strBefore,strAfter)
	%getFlankedBy Returns string flanked by two other strings
	%Syntax: [strOut,intStop] = getFlankedBy(strInput,strBefore,strAfter)
	%
	%	Version history:
	%	1.0 - August 6 2013
	%	Created by Jorrit Montijn
	intStop = -1;
	strOut = '';
	vecStart = strfind(strInput,strBefore);
	if ~isempty(vecStart) || isempty(strBefore)
		if isempty(strBefore)
			intStart = 1;
		else
			intStart = vecStart(1) + length(strBefore);
		end
		findLast = strfind(strInput,strAfter);
		if ~isempty(findLast) || isempty(strAfter)
			if isempty(strAfter)
				intStop = length(strInput) + 1;
			else
				intStop = findLast(find(strfind(strInput,strAfter) > intStart,1,'first'));
			end
			if ~isempty(intStop)
				strOut = strInput(intStart:(intStop-1));
			end
		end
	end
end

