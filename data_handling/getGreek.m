function strGreek = getGreek(intChar,strUpLow)
	%getGreek Get Greek letter; 1=alpha,25=omega
	%   strGreek = getGreek(intChar,strUpLow); e.g., "getGreek(1,'lower')"
	%OR:
	%   strGreek = getGreek(strChar,strUpLow); e.g., "getGreek('rho','upper')"
	
	if ~exist('strUpLow','var') || isempty(strUpLow)
		if ischar(intChar)
			if isstrprop(intChar(1),'upper')
				strUpLow = 'upper';
			else
				strUpLow = 'lower';
			end
		else
			strUpLow = 'upper';
		end
	end
	if ischar(intChar)
		cellNames = {'alpha','beta','gamma','delta','epsilon','zeta','eta',...
			'theta','iota','kappa','lambda','mu','nu','xi','omicron','pi',...
			'rho','sigma2','sigma','tau','upsilon','phi','chi','psi','omega'};
		intChar = find(ismember(cellNames,lower(intChar)));
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

