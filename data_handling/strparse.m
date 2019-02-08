function cellOut = strparse(strInput,strDelimiter)
	%strparse Splits input string by delimiter
	%   cellOut = strparse(strInput,strDelimiter)
	
	intParts = sum(ismember(strInput, '_'));
	cellOut = cell(1,intParts);
	for intPart=1:(intParts+1)
		[strTok, strInput] = strtok(strInput,strDelimiter);
		cellOut{intPart} = strTok;
	end
end

