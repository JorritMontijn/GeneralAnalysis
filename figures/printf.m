function printf(strBase,varargin) %#ok<INUSL>
	%printf Writes output to log file instead of printing to screen
	
	%define global pointer to file
	global ptrOutputFile
	
	%format input
	strExec = 'sprintf(strBase';
	for intArg=1:numel(varargin)
		strExec = [strExec ',varargin{' num2str(intArg) '}']; %#ok<AGROW>
	end
	strExec = [strExec ');'];
	strInput = eval(strExec);
	
	
	%open file
	if isempty(ptrOutputFile)
		cellFunctions=inmem;
		intFunc = find(~cellfun(@isempty,cellfun(@strfind,cellFunctions,cellfill('run',size(cellFunctions)),'UniformOutput',false)),1,'last');
		if isempty(intFunc),strFunction = '';else strFunction = cellFunctions{intFunc};end
		rng(now*cputime); %randomize initial seed of random number generator
		vecTime = fix(clock);
		strTime = sprintf('%02d%02d%02d',vecTime(4:6));
		strFile = [strFunction '_' date '_' strTime '_' num2str(round(9*rand(10,1)))' '.log'];
		ptrOutputFile = fopen(strFile,'w+');
	end
	
	%check if end is \n
	%strInput = [strInput '\n'];
	
	%write to file
	fwrite(ptrOutputFile,strInput);
end

