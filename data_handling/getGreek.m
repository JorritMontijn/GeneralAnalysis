function strGreek = getGreek(intChar,strUpLow)
	%getGreek Get Greek letter; 1=alpha,25=omega
	%   strGreek = getGreek(intChar,strUpLow)
	
	if ~exist('strUpLow','var')
		strUpLow = 'upper';
	end
	if strcmpi(strUpLow,'upper')
		intOffset = 912;
	elseif strcmpi(strUpLow,'lower')
		intOffset = 944;
	else
		error([mfilename ':UnknownSpecifier'],'Please use ''upper'' or ''lower'' as second arg');
	end
	strGreek = char(intOffset+intChar);
end

