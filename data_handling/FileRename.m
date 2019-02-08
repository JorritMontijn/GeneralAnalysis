function FileRename(strOldFileName, strNewFileName)
	
	objJava = java.io.File(strOldFileName);
	objJava.renameTo(java.io.File(strNewFileName));
end