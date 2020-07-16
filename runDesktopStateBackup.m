%get target directory
function runDesktopStateBackup
	strDir = prefdir();
	strBackupDir = strcat(strDir,filesep,'DesktopBackups');
	if ~exist(strBackupDir,'dir')
		mkdir(strBackupDir);
	end
	
	%get current files
	sFiles = dir(strBackupDir);
	
	%remove old files (>1 week old)
	vecDaysAgo = daysdif(getDate,{sFiles(:).date});
	vecRemFiles = vecDaysAgo > 7 & flat(contains({sFiles(:).name},'MATLABDesktop'));
	for intRemFile = find(vecRemFiles(:))'
		delete(strcat(strBackupDir,filesep,sFiles(intRemFile).name));
	end
	
	%copy new file
	strSourceFile = strcat(strDir,filesep,'MATLABDesktop.xml.prev');
	strTargetFile = strcat(strBackupDir,filesep,'MATLABDesktop.xml.prev.',getDate);
	try
		copyfile(strSourceFile,strTargetFile);
	catch ME
		warning([mfilename ':CopyError'],sprintf('Could not copy desktop backup file: %s',ME.message));
	end
end