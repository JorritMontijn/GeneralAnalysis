function cellPaths = getSubDirs(strMasterPath,intMaxDepth,cellExcludePathName)
	%getSubDirs Returns cell array of target directory and all its subfolders
	%   Syntax: cellPaths = getSubDirs(strMasterPath,intMaxDepth,strExcludePathName)
	%
	%Default search depth (intMaxDepth) is set at [2] subfolders
	%Default folder exclusion (cellExcludePathName) is {' '}; can either be
	%a single cell or a cell array of strings for multiple exlusions
	%
	%	Version 1.0 [2014-06-02]
	%	2014-06-02; Created by Jorrit Montijn
	
	
	%set default values
	if nargin < 2 || ~exist('intMaxDepth','var') || ~isnumeric(intMaxDepth),intMaxDepth = 2;end
	if nargin < 3 ||  ~exist('cellExcludePathName','var') || isnumeric(cellExcludePathName),cellExcludePathName = {' ','.','..'};end
	%initialize variables
	intPathCounter = 1;
	intIncrement = 100; %base increment of cell array elements; can be changed
	intCurMax = intIncrement;
	cellPaths = cell(1,intIncrement);
	cellPaths{1} = strMasterPath;
	boolRunning = true;
	vecCurNode = 0;
	strCurNode = strMasterPath;
	if strcmp(filesep,'\'), strDelimiter = '\\';else strDelimiter = filesep;end
	
	%keep searching until we're done
	while boolRunning
		%increase size of cell array if needed
		if intPathCounter >= intCurMax
			cellPaths = cat(2,cellPaths,cell(1,intIncrement));
			intCurMax = intCurMax + intIncrement;
		end
		%set current node number to be one higher than the last value of
		%the node counter vector end point
		intCurNode = vecCurNode(end) + 1;
		
		%check current node for directories
		sDir = dir(strCurNode);
		vecDirList = find(vertcat(sDir.isdir));
		if intCurNode+2 <= length(vecDirList) && ismember(sDir(vecDirList(intCurNode+2)).name,cellExcludePathName)
			%if object corresponds to exclusion name, then we increase the
			%end value of the node counter vector by one; and we add this
			%subfolder to the cell array list
			vecCurNode(end) = vecCurNode(end) + 1;
			intPathCounter = intPathCounter + 1;
			cellPaths{intPathCounter} = [strCurNode filesep sDir(vecDirList(intCurNode+2)).name];
		elseif intCurNode+2 <= length(vecDirList) && exist([strCurNode filesep sDir(vecDirList(intCurNode+2)).name],'dir') && length(vecCurNode) <= intMaxDepth
			%if object corresponds to inclusion parameters (is within
			%object list, is folder, does not need to be excluded and does
			%not exceed maximum search depth), then we increase the end
			%value of the node counter vector by one and increase its size
			%by 1 to keep track that we switched to a new subfolder; and we
			%add this subfolder to the cell array list
			vecCurNode(end) = vecCurNode(end) + 1;
			vecCurNode = [vecCurNode 0];
			strCurNode = [strCurNode filesep sDir(vecDirList(intCurNode+2)).name];
			intPathCounter = intPathCounter + 1;
			cellPaths{intPathCounter} = strCurNode;
		else
			%if object does not correspond to subsearch criteria, we move
			%up one folder by reconstructing the master folder from the
			%current node path; we also remove the endpoint from the node
			%counter vector so its new endpoint value corresponds to the
			%folder number we just finished
			cellCurPath = textscan(strCurNode,'%s','delimiter',strDelimiter);
			strCurNode = cellCurPath{1}{1};
			for intSub=2:(length(cellCurPath{1})-1)
				strCurNode = [strCurNode filesep cellCurPath{1}{intSub}];
			end
			vecCurNode = vecCurNode(1:(end-1));
		end
		%if moving up from last folder emptied the node counter vector we
		%have completed the subfolder search of the master directory, so we
		%can stop and return the results
		if isempty(vecCurNode),boolRunning=false;end
	end
	
	%remove empty elements from the over-allocated cell array
	cellPaths = cellPaths(1:intPathCounter);
	
	%remove excluded paths
	indRemove = false(size(cellPaths));
	for intEntry=1:numel(indRemove)
		cellSplit = strsplit(cellPaths{intEntry},filesep);
		if any(ismember(cellSplit,cellExcludePathName))
			indRemove(intEntry) = true;
		end
	end
	cellPaths(indRemove) = [];
end

