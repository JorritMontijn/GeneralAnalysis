function intDay = date2day(varargin)
	%UNTITLED Summary of this function goes here
	%   Supported formats:
	%	'YYYMMDD' (str)
	%	YYYYMMDD (dbl)
	%	'MMDD'
	%	MMDD
	%	'Y', 'M', 'D'
	%	Y, M, D
	%	'M', 'D'
	%	M, D
	
	%assign vals to year, month, day
	if nargin == 1
		date=varargin{1};
		if ~ischar(date)
			date = num2str(date);
		end
		dateL = length(date);
		if dateL == 8
			year=date(1:4);
			mo=date(5:6);
			da=date(7:8);
		elseif dateL == 4
			year=0;
			mo=date(5:6);
			da=date(7:8);
		else
			error
		end
	elseif nargin == 2
		year=0;
		mo=varargin{1};
		da=varargin{2};
	elseif nargin == 3
		year=varargin{1};
		mo=varargin{2};
		da=varargin{3};
	else
		error
	end
	
	%turn to double
	if ischar(year)
		year=str2double(year);
	end
	if ischar(mo)
		mo = str2double(mo);
	end
	if ischar(da)
		da = str2double(da);
	end
	
	%get day number
	intDay = datenum([year mo da]);
end

