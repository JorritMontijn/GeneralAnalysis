%clean paths
cleanPaths();

%get all paths
cellPaths = strsplit(path(),';');

%remove matlab root
cellPaths(contains(cellPaths,matlabroot)) = [];

%get all files
cellAllFiles = cellfill('',[1 1000]);
intNewFilePtr = 1;
for intPath=1:numel(cellPaths)
	strPath = cellPaths{intPath};
	sFiles = dir(fullpath(strPath,'*.m'));
	cellFiles = {sFiles.name};
	
	intNewFiles = numel(cellFiles);
	if intNewFilePtr + intNewFiles > numel(cellAllFiles)
		cellAllFiles((numel(cellAllFiles)+1):(2*numel(cellAllFiles))) = {''};
	end
	
	cellAllFiles(intNewFilePtr:(intNewFilePtr+intNewFiles-1)) = cellFiles;
	intNewFilePtr = intNewFilePtr + intNewFiles;
end
cellAllFiles(intNewFilePtr:end) = [];

%find duplicates
[cellNames,a,b]=unique(cellAllFiles);
vecCounts = accumarray(b,1);
cellDuplicatedNames = cellNames(vecCounts>1);

%set list to ignore
cellIgnore = {'backup','Untitled','Psychtoolbox','Contents.m','contents.m',...
	'runExampleZETA.m','runCreatePreDataAggregate.m','getTunedStimDetectionNeurons','plotAsProbe.m','best_fit_line.m'...
	'getOr.m','getIFR.m','export_fig.m','circ_dist','countUnique.m','clusterAverage.m','buildMultiSesAggregate.m','getMultiScaleDeriv.m'};
indRem = contains(cellDuplicatedNames,cellIgnore);
cellDuplicatedNames(indRem) = [];

%check if there are differences between instances of files
indIsProblematic = false(size(cellDuplicatedNames));
for intDuplicateName = 1:numel(cellDuplicatedNames)
	%get all copies
	cellCopies = which(cellDuplicatedNames{intDuplicateName},'-all');
	cellCopies(contains(cellCopies,matlabroot)) = [];
	cellCopies(contains(cellCopies,cellIgnore)) = [];
	
	%compare files
	cellMD5 = cell(size(cellCopies));
	for intFile=1:numel(cellCopies)
		cellMD5{intFile} = GetMD5(cellCopies{intFile}, 'File');
	end
	
	%check if they're all identical
	cellUniques = unique(cellMD5);
	if numel(cellUniques) ~= 1 && numel(cellCopies) > 1
		fprintf('\nFile %s has multiple copies with different content. MD5 hashes:\n',cellDuplicatedNames{intDuplicateName});
		indIsProblematic(intDuplicateName) = true;
		for intFile=1:numel(cellCopies)
			fprintf('   %s at %s\n',cellMD5{intFile},cellCopies{intFile});
		end
	end
end
fprintf('Found %d non-identical duplicate .m files [%s]\n',sum(indIsProblematic),getTime);