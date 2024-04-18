function h = swarmchart(varargin)
	%SWARMCHART Swarm chart.
	%   SWARMCHART(x,y) displays a scatter plot where points are jittered in
	%   the x dimension based on an estimate of the  kernel density in the y
	%   dimension for each unique x. Swarm charts provide a visualization for
	%   discrete x data that captures the distribution of y data. SWARMCHART
	%   sets the maximum jitter width to be 90% of the minimum difference
	%   between distinct values of x.
	%
	%   SWARMCHART(x,y,sz) draws the markers at the specified sizes (sz)
	%   SWARMCHART(x,y,sz,c) uses c to specify color, see SCATTER for a
	%   description of how to manipulate color.
	%
	%   SWARMCHART(...,M) uses the marker M instead of 'o'.
	%   SWARMCHART(...,'filled') fills the markers
	%
	%   SWARMCHART(tbl,xvar,yvar) creates a swarm chart using the variables
	%   xvar and yvar from table tbl. Multiple swarm charts are created if xvar
	%   or yvar reference multiple variables. For example, this command creates
	%   two swarm charts:
	%   swarmchart(tbl, {'var1', 'var2'}, {'var3', 'var4'})
	%
	%   SWARMCHART(tbl,xvar,yvar,'filled') specifies data in a table and fills
	%   in the markers.
	%
	%   SWARMCHART(AX,...) plots into AX instead of GCA.
	%   S = SWARMCHART(...) returns handles to the scatter object created.
	%
	%   Example:
	%       x=randi(4,1000,1);
	%       y=randn(1000,1);
	%       SWARMCHART(x,y)
	
	%wrapper for swarmchart
	cellOthers= which(mfilename,'-all');
	strThisFile = mfilename('fullpath');
	indOtherFiles = ~contains(cellOthers,strThisFile);
	if any(indOtherFiles)
        varinput = varargin;
        vecOtherFiles = find(indOtherFiles);
		sFiles = dir(cellOthers{vecOtherFiles(1)});
		for intFile=2:numel(vecOtherFiles)
			sFiles(intFile) = dir(cellOthers{vecOtherFiles(intFile)});
		end
		[dummy,intTargetFile] = max(cell2vec({sFiles.bytes}));
		strTarget = fullpath(sFiles(intTargetFile).folder,sFiles(intTargetFile).name);
		strPath=fileparts(strTarget);
		strOldPath=cd(strPath);
		%get function handle
		fFunc=str2func(mfilename);
		%move back & eval
		cd(strOldPath);
		if nargout > 0
			h = feval(fFunc,varargin{:});
		else
			feval(fFunc,varargin{:});
        end
    else
		if nargin > 0
			validateJitterable(varargin);
		end
		
		%remove JitterWidth
		intIsJitter = find(strcmpi(varargin,'JitterWidth'));
		if ~isempty(intIsJitter)
			dblUseJitter = varargin{intIsJitter+1};
			varargin(intIsJitter:(intIsJitter+1))=[];
		else
			dblUseJitter = [];
		end
		try
			obj = scatter(varargin{:});
		catch ME
			throw(ME)
		end
		
		if ~isempty(obj)
			% Collect diffs from all created series and use the minimum to set XJitterWidth
			jitwidth = nan(1, numel(obj));
			for i = 1:numel(obj)
				x = obj(i).XData_I;
				
				if iscategorical(x) || isempty(x)
					uniquex = 1;
				elseif ~isnumeric(x)
					error('MATLAB:scatter:InvalidSwarmXData', getString(message('MATLAB:scatter:InvalidSwarmData','X')))
				else
					uniquex=unique(x);
				end
				
				if numel(uniquex)==1
					jitwidth(i) = .9;
				else
					jitwidth(i) = .9 * min(diff(uniquex));
				end
			end
			if isempty(dblUseJitter)
				dblUseJitter = min(jitwidth);
			end
			
			obj.XData = obj.XData + rand(size(obj.XData ))*dblUseJitter-dblUseJitter/2;
			
		end
		
		if nargout > 0
			h = obj;
		end
	end
end

function validateJitterable(args)
	% To calculate JitterWidth the Data must be categorical or numeric.
	% Validate here (when possible) before creating any Scatter objects.
	
	% The user may have specified JitterWidth, in which case these values
	% shouldn't be validated. However, the combination of renameable
	% properties (e.g. ThetaJitterWidth), partial matching rules (e.g.
	% LatitudeJitterW), and the possiblity of table variables with property
	% names makes resolving this difficult. Ignore validation if there are
	% any Char or String args that begin XJitterW, ThetaJitterW,
	% LatitudeJitterW. This leans towards accepting data and letting
	% scatter throw exceptions for things that are missed here.
	textargs = string(args(cellfun(@(x)ischar(x) || (isstring(x) && isscalar(x)), args)));
	if any(startsWith(textargs,{'XJitterW' 'ThetaJitterW' 'LatitudeJitterW'},'IgnoreCase',true))
		return
	end
	
	ind = 1;
	if isgraphics(args{1})
		ind = ind + 1;
	end
	
	if numel(args)<ind
		return
	end
	
	
	if numel(args) < ind + 1
		return
	end
	tbl = args{ind};
	xvar = args{ind+1};
	
	try
		dataSource = matlab.graphics.data.DataSource(tbl);
		dataMap = matlab.graphics.data.DataMap(dataSource);
		dataMap = dataMap.addChannel('X',xvar);
	catch
		% If anything is wrong with making the dataMap, defer to
		% Scatter to throw
		return
	end
	for i = 1:dataMap.NumObjects
		xdata = dataSource.getData(dataMap.slice(i).X);
		if ~iscategorical(xdata{1}) && ~isnumeric(xdata{1})
			ME = MException('MATLAB:scatter:InvalidSwarmXData', message('MATLAB:scatter:InvalidSwarmData','X'));
			throwAsCaller(ME);
		end
	end
end