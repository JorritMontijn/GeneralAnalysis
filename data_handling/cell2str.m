function strOut = cell2str(cellArray)
	%cell2str Cell to string conversion
	%    strOut = cell2str(cellArray)
	strOut = '';
	for intEl=1:numel(cellArray)
		strOut = strcat(strOut,cellArray{intEl},';');
	end
	strOut = strOut(1:(end-1));
end

