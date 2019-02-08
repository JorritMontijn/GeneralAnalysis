function [vecParams,dblRes,matRes,matFit,vecRes] = getFitMultiStart(fFit,matX,matY,vecLower,vecUpper,matParams)
	%getFitMultiStart: Syntax:
	%	[vecParams,dblRes,matRes,matFit] = getFitMultiStart(fFit,matX,matY,vecLower,vecUpper,matParams)
	%
	%This function uses lsqcurvefit to fit. To improve
	%performance, it uses multiple initial parameters

	%spread seeds
	if nargin < 6
		intStartingPoints = 100;
		intParameters = numel(vecLower);
		matParams = nan(intParameters,intStartingPoints);
		for intP=1:intParameters
			matParams(intP,randperm(intStartingPoints)) = linspace(vecLower(intP),vecUpper(intP),intStartingPoints);
		end
	end
	
	%try different initializations
	intMaxIters = 10;
	sOptions = optimset('Algorithm','trust-region-reflective',...
		'TolX',10^-6,'TolFun',10^-6,'GradObj','on','MaxIter',intMaxIters,'Display','off');
	intStartingPoints = size(matParams,2);
	
	%run initial fits
	vecRes = nan(1,intStartingPoints);
	for intFit=1:intStartingPoints
		[vecP,dblRes] = lsqcurvefit(fFit,matParams(:,intFit),matX,matY,vecLower,vecUpper,sOptions);
		matParams(:,intFit) = vecP;
		vecRes(intFit) = dblRes;
	end
	
	%define second round
	[vecV,vecInd]=findmin(vecRes,5);
	matParams = matParams(:,vecInd);
	matParams(:,end+1) = mean(matParams,2);
	intMaxIters = 50;
	sOptions = optimset('Algorithm','trust-region-reflective',...
		'TolX',10^-6,'TolFun',10^-6,'GradObj','on','MaxIter',intMaxIters,'Display','off');
	intStartingPoints = size(matParams,2);
	
	%run second round
	vecRes = nan(1,intStartingPoints);
	for intFit=1:intStartingPoints
		[vecP,dblRes] = lsqcurvefit(fFit,matParams(:,intFit),matX,matY,vecLower,vecUpper,sOptions);
		matParams(:,intFit) = vecP;
		vecRes(intFit) = dblRes;
	end
	
		
	%define final round
	[vecV,vecInd]=findmin(vecRes,2);
	matParams = matParams(:,vecInd);
	intStartingPoints = size(matParams,2);
	intMaxIters = 1000;
	sOptions = optimset('Algorithm','trust-region-reflective',...
		'TolX',10^-6,'TolFun',10^-6,'GradObj','on','MaxIter',intMaxIters,'Display','off');
	
	
	%run final round
	vecRes = nan(1,intStartingPoints);
	for intFit=1:intStartingPoints
		[vecP,dblRes] = lsqcurvefit(fFit,matParams(:,intFit),matX,matY,vecLower,vecUpper,sOptions);
		matParams(:,intFit) = vecP;
		vecRes(intFit) = dblRes;
	end
	
	%get output
	[dblRes,intInd] = min(vecRes);
	vecParams = matParams(:,intInd);
	matFit = feval(fFit,vecParams,matX);
	matRes = matY-matFit;
end
