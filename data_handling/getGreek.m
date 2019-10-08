function strGreek = getGreek(intChar,strUpLow)
	%getGreek Get Greek letter; 1=alpha,25=omega
	%   strGreek = getGreek(intChar,strUpLow); e.g., "getGreek(1,'lower')"
	%OR:
	%   strGreek = getGreek(strChar,strUpLow); e.g., "getGreek('rho','upper')"
	
	if ischar(intChar)
		cellNames = {'alpha','beta','gamma','delta','epsilon','zeta','eta',...
			'theta','iota','kappa','lambda','mu','nu','xi','omicron','pi',...
			'rho','sigma2','sigma','tau','upsilon','phi','chi','psi','omega'};
		intChar = find(ismember(cellNames,lower(intChar)));
	end
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

