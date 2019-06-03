function [vecPredY_CV,cellMeanCoeffs,matX,cellFunctions,cellFoldCoeffs,cellFoldTestObs] = gnmkfold(intFoldK,vecRepetitionIdx,matX,vecY,cellCoeffs0,varargin)
	%gnmkfold Uses K-fold cross-validation on gnmfit()
	%
	%[vecPredY_CV,cellMeanCoeffs,matOutX,cellFunctions,cellFoldCoeffs,cellFoldTestObs] = 
	%	gnmkfold(intFoldK,vecRepetitionIdx,matX,vecY,cellCoeffs0,@function1,index1,...,sOptions)
	%
	%Inputs:
	% - intFoldK; [int] Number of slices to partition the data into for use
	%					with K-fold cross-validation
	% - vecRepetitionIdx; [n x 1] Indexing vector denoting the repetition
	%						number of the corresponding observation. The
	%						data slicing will attempt to use the same
	%						number of repetitions in each fold. If this is
	%						not possible, the remainders will be allocated
	%						starting with the first fold. Note that
	%						repetition index "0" will be ignored.
	% - Other inputs: see help description of gnmfit() function
	%	
	%Outputs:
	% - vecPredY_CV; [n x 1] Cross-validated predicted values
	% - cellMeanCoeffs; [1 x p] Mean across folds of model coefficients
	% - matOutX; [n x p] Mean across folds of model coefficients
	% - cellFunctions; [1 x p cell] Functions per predictor
	% - cellFoldCoeffs; [K x p cell] Coefficients per fold
	% - cellFoldTestObs; [K x 1 cell] Indexing vector of test observations
	%						used to predict vecPredY_CV
	%
	%Version History:
	%2019-05-29 Created gnmkfold function [by Jorrit Montijn]
	
	%% k-fold data split
	intPreds = size(matX,2);
	intObs = size(matX,1);
	intMaxRep = max(vecRepetitionIdx);
	vecRepsPerFold = floor(intMaxRep / intFoldK)*ones(intFoldK,1);
	intRemainder = mod(intMaxRep,intFoldK);
	vecRepsPerFold(1:intRemainder) = vecRepsPerFold(1:intRemainder) + 1;
	vecFoldRepStart = cumsum(vecRepsPerFold) - vecRepsPerFold(1) + 1;
	vecFoldRepEnd = cumsum(vecRepsPerFold);
	
	%% run k-folds
	%add constant
	if ~any(cellfun(@strcmpi,cellfill('constant',size(varargin)),varargin))
		intPreds = intPreds + 1;
		matX(:,end+1) = 1;
		varargin(end+1) = {'constant'};
		varargin(end+1) = {intPreds};
		cellCoeffs0(:,end+1) = {0};
	end
	%pre-allocate
	cellFoldCoeffs = cell(intFoldK,intPreds);
	vecPredY_CV = nan(size(vecY));
	%assign data
	cellFoldTestObs = cell(intFoldK,1);
	cellTestX = cell(intFoldK,1);
	cellTrainX = cell(intFoldK,1);
	cellTrainY = cell(intFoldK,1);
	indAllObs = vecRepetitionIdx>0;
	for intThisFold=1:intFoldK
		%get repetitions
		vecTestReps = vecFoldRepStart(intThisFold):vecFoldRepEnd(intThisFold);
		
		%get observations
		vecTestObs = ismember(vecRepetitionIdx,vecTestReps);
		indTrainObs = indAllObs;
		indTrainObs(vecTestObs) = false;
		
		%assign
		cellFoldTestObs{intThisFold} = vecTestObs;
		cellTestX{intThisFold} = matX(vecTestObs,:);
		cellTrainX{intThisFold} = matX(indTrainObs,:);
		cellTrainY{intThisFold} = vecY(indTrainObs,:);
	end
	
	%% run
	cellCoeffs = cellCoeffs0;
	for intThisFold=1:intFoldK
		%run fit
		[cellCoeffs,matOutX,cellFunctions] = gnmfit(cellTrainX{intThisFold},cellTrainY{intThisFold},cellCoeffs,varargin{:});
		cellFoldCoeffs(intThisFold,:) = cellCoeffs;
		
		%predict
		vecPredY_CV(cellFoldTestObs{intThisFold}) = gnmval(cellCoeffs,cellTestX{intThisFold},cellFunctions);
	end
	
	%% aggregate data
	cellMeanCoeffs = cell(1,intPreds);
	for intPred=1:intPreds
		cellMeanCoeffs(intPred) = {mean(cell2mat(cellFoldCoeffs(:,intPred)),1)};
	end
end

