cellPaths = strsplit(path(),';');

%remove paths
fprintf('Cleaning paths... [%s]\n',getTime);

intRem = 0;
cellRemove = {'backup','.git','.ignore','old'};
for intPath=1:numel(cellPaths)
	strPath = cellPaths{intPath};
	cellFolders = strsplit(strPath,filesep);
	if any(ismember(cellFolders,cellRemove))
		rmpath(strPath);
		intRem = intRem + 1;
	end
end

%save culled path file
status = savepath();
fprintf('%d paths removed [%s]\n',intRem,getTime);
