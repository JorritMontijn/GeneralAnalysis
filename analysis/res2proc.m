function strOut = res2proc(strIn)
	%transforms results directory to process directory
	intStart=strfind(strIn,'Processed');
	strOut = [strIn(1:(intStart-1)) 'Results' strIn((intStart+9):end)];
end

