function varargout = dimfun(intSplitDim,hFunc,matData,varargin)
	%dimfun Performs hFunc over matrix split by supplied dimension
	%   varargout = dimfun(intSplitDim,hFunc,matData,varargin)
	
	%split into cells
	vecSize = size(matData);
	strSplit = '';
	for intDim=1:numel(vecSize)
		if intDim==intSplitDim
			strSplit = strcat(strSplit,['[' repmat('1 ',[1 vecSize(intDim)]) '],']);
		else
			strSplit = strcat(strSplit,sprintf('[%d],',vecSize(intDim)));
		end
	end
	strSplit(end) = [];
	
	%create cellData
	strEval = ['cellData = mat2cell(matData,' strSplit ');'];
	eval(strEval);
	
	%build cellfun parameters
	strArgs = '';
	for intArgIn = 1:numel(varargin)
		strArgs = strcat(strArgs,['cellfill(varargin{' num2str(intArgIn) '},size(cellData)),']);
	end
	if numel(strArgs) > 0
		strArgs(end) = [];
	end
	
	%build output
	strOut = '[';
	for intOut=1:nargout
		strOut = strcat(strOut,['varargout{' num2str(intOut) '},']);
	end
	strOut(end) = ']';
	
	%execute
	strEval2 = [strOut ' = cellfun(hFunc,cellData,' strArgs ',''UniformOutput'',false);'];
	eval(strEval2);
end

