function strDate = datemod(strFile)
	%datemod Returns last modified date for file
	%   strDate = datemod(strFile)
	try
		sDate = System.IO.File.GetLastWriteTime(strFile);
		strDate = sprintf('%04d-%02d-%02d',sDate.Year,sDate.Month,sDate.Day);
	catch
		strDate = 'Unable-to-read';
	end
end

