function strOut = proc2res(strIn)
	%transforms processed directory to results directory
	intStart=strfind(strIn,'Processed');
	strOut = [strIn(1:(intStart-1)) 'Results' strIn((intStart+9):end)];
end

