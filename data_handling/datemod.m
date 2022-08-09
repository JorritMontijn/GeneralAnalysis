function strDate = datemod(strFile)
	%datemod Returns last modified date for file
	%   strDate = datemod(strFile)
	
	sDate = System.IO.File.GetLastWriteTime(strFile);
	strDate = sprintf('%04d-%02d-%02d',sDate.Year,sDate.Month,sDate.Day);
end

