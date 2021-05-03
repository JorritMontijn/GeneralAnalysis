function clabel(varargin)
	%clabel Assigns label to color axis (colorbar)
	%    clabel([handle],strTitle)
	
	%assert inputs
	assert(nargin <3);
	any(cellfun(@ischar,varargin))
	assert(any(cellfun(@ischar,varargin)));
	
	%get handle
	if nargin == 1
		hBar = cbhandle('force');
		strTit = varargin{1};
	else
		hBar = varargin{1};
		strTit = varargin{2};
	end
	
	%set title
	hBar.Label.String = strTit;
end