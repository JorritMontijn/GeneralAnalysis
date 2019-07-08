function [cellCoeffs,matX,cellFunctions,vecLinCoeffs,vecLinCoeffFunctions] = gnmfit(matX,vecY,cellCoeffs0,varargin)
	%gnmfit Fits a generalized non-linear model where predictors are
	%		related to parameter values through non-linear functions.
	%
	%[cellCoeffs,matXwithBias,cellFunctions,vecLinCoeffs,vecLinCoeffFunctions] = 
	%	gnmfit(matX,vecY,cellCoeffs0,@function1,index1,...,sOptions)
	%
	%Inputs:
	% - matX; [n x p]  Matrix of n observations of p predictors
	% - vecY; [n x 1] Vector n observations of responses 
	% - cellCoeffs0; [(1 or 3) x p] Cell array of initial x0 coefficients
	%				If you supply a [3 x p] cell array, cellCoeffs0(2,:)
	%				and cellCoeffs0(3,:) are respectively the lower and
	%				upper bounds (lsqcurvefit or lsqnonlin only).
	% - Pairs of ['function'], [predictor idx]; see below.
	% - sOptions; [struct] Structure with fields to be passed to the solver.
	%				You can set the solver by changing "sOptions.Solver" to
	%				'lsqcurvefit' (default), 'lsqnonlin' or 'fminsearch'.
	%				
	%Fitted function values can be returned by:
	%vecPredY = gnmval(cellCoeffs,matXwithBias,cellFunctions)
	%
	%Function specification for predictors:
	%Specify the function for predictor i as a combination of the function
	%name followed by a vector that indexes which predictors use this
	%function. For example: gnmfit(...,'gnmgauss',[2 3]) specifies
	%predictors 2 and 3 relate X to y through a Gaussian function. For
	%example, predictor i would now predict Y as follows:
	%	vecYhat_i = cellCoeffs{i}(1) * normpdf(matX(:,i),cellCoeffs{i}(2),cellCoeffs{i}(3))
	%
	%Note on default linear function:
	%If no function is specified, it is assumed to be linear, in the sense
	%that predictor i relates X to y through:
	%	vecYhat_i = matX(:,i) * cellCoeffs{i}(1)
	%
	%Note on constant offset:
	%If no function is specified with the name 'constant', a column of
	%constants is added to matX, and a bias term is added to cellCoeffs
	%
	%Example:
	%sOptions.Solver='lsqcurvefit';
	%intObs = 10000;
	%intPreds = 6;
	%matX = rand(intObs,intPreds);
	%vecY = rand(intObs,1);
	%cellCoeffs0 = {0,0,0,[1 0 1],0,0};
	%[cellCoeffs,matX,cellFunctions] = gnmfit(matX,vecY,cellCoeffs0,'gnmgauss',4,sOptions);
	%
	%Note on relationship to GLM:
	%Show that the GNM is equivalent to a GLM when using only linear functions:
	%cellCoeffs0 = {0,0,0,0,0,0};
	%[cellCoeffs,matOutX,cellFunctions] = gnmfit(matX,vecY,cellCoeffs0);
	%vecYhat_LinearGNM = gnmval(cellCoeffs,matOutX,cellFunctions);
	%vecCoeffsGLM = glmfit(matX,vecY,'normal');
	%vecYhat_GLM = glmval(vecCoeffsGLM,matX,'identity');
	%figure;scatter(vecYhat_LinearGNM,vecYhat_GLM);
	%
	%Version History:
	%2019-05-22 Created gnmfit function [by Jorrit Montijn]
	
	%% set globals
	global gCellFunctions;
	global gVecLinCoeffFunctions;
	global gMatX;
	global gVecY;
	
	%get additional inputs
	cellInputs = varargin;
	cellSolvers = {'lsqcurvefit','lsqnonlin','fminsearch'};
	
	%% check inputs and parse input functions
	%check consistency
	intObservationsFromX = size(matX,1);
	intPredictorsFromX = size(matX,2);
	intObservationsFromY = size(vecY,1);
	intPredictorsFromC0 = size(cellCoeffs0,2);
	if intObservationsFromX ~= intObservationsFromY || intPredictorsFromX ~= intPredictorsFromC0
		error([mfilename ':ParseError'],sprintf('Input parse error; # of obs: %d (x), %d (y); # of preds: %d (x), %d (coeffs)',...
			intObservationsFromX,intObservationsFromY,intPredictorsFromX,intPredictorsFromC0));
	end
	intObs = intObservationsFromX;
	intPreds = intPredictorsFromX;
	%check functions
	cellFunctions = cellfill('times',[1,intPreds]); %times is linear, Y = Xb
	boolAddConstant = true;
	intInputCounter = 0;
	strSolver = 'lsqcurvefit';
	while intInputCounter < numel(cellInputs)
		intInputCounter = intInputCounter + 1;
		strFunc = cellInputs{intInputCounter};
		if ischar(strFunc)
			intInputCounter = intInputCounter + 1;
			vecAsgnToLinks = cellInputs{intInputCounter};
			cellFunctions(vecAsgnToLinks) = {strFunc};
			if strcmpi(strFunc,'constant')
				boolAddConstant = false;
			end
		elseif isstruct(strFunc)
			sOpt = strFunc;
			if isfield(sOpt,'Solver')
				if ismember(sOpt,cellSolvers)
					strSolver = sOpt.Solver;
					sOpt = rmfield(sOpt,'Solver');
				else
					error([mfilename ':ParseError'],sprintf('Parse error; solver "%s" not recognized',sOpt.Solver));
				end
			end
		else
			disp(strFunc);
			error([mfilename ':ParseError'],sprintf('Parse error; optional argument %d not recognized',intInputCounter));
		end
	end
	
	%% set optim options
	sOptimOptions = struct;
	sOptimOptions.MaxFunEvals = 1000;
	sOptimOptions.MaxIter = 1000;
	sOptimOptions.Display = 'off';
	if exist('sOpt','var') && isstruct(sOpt)
		sOptimOptions = catstruct(sOptimOptions,sOpt);
	end
	
	%% build model
	%linearize coefficients
	dblMaxVal = max([numel(vecY) sum(abs(vecY))]);
	dblLB = -dblMaxVal;
	dblUB = dblMaxVal;
	vecLinCoeffs0 = [];
	vecLinCoeffsLB = [];
	vecLinCoeffsUB = [];
	vecLinCoeffFunctions = [];
	for intPred = 1:intPreds
		vecCoeffs = cellCoeffs0{1,intPred};
		vecIdx = (numel(vecLinCoeffs0)+1):(numel(vecLinCoeffs0) + numel(vecCoeffs));
		vecLinCoeffs0(vecIdx) = vecCoeffs; %#ok<AGROW>
		vecLinCoeffFunctions(vecIdx) = intPred; %#ok<AGROW>
		
		%define lower and upper bounds
		if size(cellCoeffs0,1) == 3
			vecLinCoeffsLB(vecIdx) = cellCoeffs0{2,intPred}; %#ok<AGROW>
			vecLinCoeffsUB(vecIdx) = cellCoeffs0{3,intPred}; %#ok<AGROW>
		else
			vecLinCoeffsLB(vecIdx) = dblLB; %#ok<AGROW>
			vecLinCoeffsUB(vecIdx) = dblUB; %#ok<AGROW>
		end
	end
	
	%add constant
	if boolAddConstant
		matX(:,end+1) = 1;
		cellFunctions(end+1) = {'constant'};
		cellCoeffs0(:,end+1) = {0};
		vecLinCoeffFunctions(end+1) = numel(cellFunctions);
		vecLinCoeffsLB(end+1) = min(vecY);
		vecLinCoeffsUB(end+1) = max(vecY);
		vecLinCoeffs0(end+1) = mean(vecY);
	end
	
	%update global link functions
	gCellFunctions = cellFunctions;
	gVecLinCoeffFunctions = vecLinCoeffFunctions;
	gMatX = matX;
	gVecY = vecY;
	
	%% run fit
	if strcmpi(strSolver,'lsqcurvefit')
		%vecLinCoeffs = lsqcurvefit('gnmlinfunc', vecLinCoeffs0, matX, vecY,vecLinCoeffsLB,vecLinCoeffsUB,sOptimOptions);
		vecLinCoeffs = curvefitfun('gnmlinfunc', vecLinCoeffs0, matX, vecY,vecLinCoeffsLB,vecLinCoeffsUB,sOptimOptions);
	elseif strcmpi(strSolver,'lsqnonlin')
		vecLinCoeffs = lsqnonlin('gnmnonlinfunc', vecLinCoeffs0,vecLinCoeffsLB,vecLinCoeffsUB,sOptimOptions);
	elseif strcmpi(strSolver,'fminsearch')
		vecLinCoeffs = fminsearch(@gnmerrfunc,vecLinCoeffs0,sOptions);
	end
	
	%turn linear coefficients back into cell array
	intAllPreds = size(cellCoeffs0,2);
	cellCoeffs = cell(1,intAllPreds);
	for intPred=1:intAllPreds
		%get arguments
		cellCoeffs{intPred} = vecLinCoeffs(vecLinCoeffFunctions==intPred);
	end
end

