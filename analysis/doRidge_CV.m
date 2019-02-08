function [vecR2_CV, sSuppOut,intOutputFlag] = doRidge_CV(matX, matY, intFoldK, dblLambda)
	%doRidge_CV Performs CV ridge regression.
	%   [vecR2_CV, sSuppOut] = doRidge_CV(matX, matY, intFoldK, dblLambda)
	
	
	% Make sure matrices are the same length
	assert(size(matX,1)==size(matY,1), 'X and Y must have the same number of observations.')
	intOutputFlag = 0;
	
	%default K
	if ~exist('intFoldK','var')
		intFoldK = 10;
	end
	
	%default lambda
	if ~exist('dblLambda','var')
		dblLambda = 0;
	end
	
	%% remove means
	vecMeanX = mean(matX);
	vecMeanY = mean(matY);
	matXN = bsxfun(@minus,matX,vecMeanX);
	matYN = bsxfun(@minus,matY,vecMeanY);
	
	%% select data
	if (any(range(matXN,1)==0) || any(range(matYN,1)==0))
		warning([mfilename ':Range0'],'Range is zero for >=1 predictors');
		intOutputFlag = 1;
	end
	
	%% general metadata
	intRepetitions = size(matX,1);
	intNeuronsX = size(matX,2);
	intNeuronsY = size(matY,2);
	intTrialsPerFold = floor(min(intRepetitions)/intFoldK); %take lowest number of repetitions for the two classes, and round down when dividing in equal K-folds
	
	%% get folds
	[cellFoldsX,cellFoldsY,cellFoldsShuffledX,cellFoldsShuffledY] = getFolds(intFoldK,matX,matY);
	
	%% pre-allocate output
	%parfor intFold=1:intFoldK
	vecR2_CV = nan(1,intFoldK);
	
	sSuppOut = struct;
	sSuppOut.cellB = cell(1,intFoldK);
	sSuppOut.vecR2_CV = nan(1,intFoldK);
	sSuppOut.vecR2_NonCV = nan(1,intFoldK);
	
	%% run
	for intFold=1:intFoldK
		%% non-shuffled
		%get training & test set
		indFolds = true(1,intFoldK);
		indFolds(intFold) = false;
		matTrainX = cell2mat(cellFoldsX(indFolds));
		matTestX = cell2mat(cellFoldsX(~indFolds));
		matTrainY = cell2mat(cellFoldsY(indFolds));
		matTestY = cell2mat(cellFoldsY(~indFolds));
		
		%% perform ridge regression
		B_ridge = (matTrainX' * matTrainX + dblLambda*eye(intNeuronsX)) \ (matTrainX' * matTrainY); %left-divide is same as inverse and multiplication
		
		%% compute test performance
		%predict responses
		matY_pred_Test = matTestX * B_ridge;
		
		%get R^2
		vecMu = mean(matTestY);
		dblSSRes_ridge = sum(sum((matTestY - matY_pred_Test).^2));
		dblSSTot = sum(sum(bsxfun(@minus,matTestY,vecMu).^2));
		dblR2_CV = 1 - dblSSRes_ridge / dblSSTot;
		
		%% compute train performance
		%predict responses
		matY_pred_Train = matTrainX * B_ridge;
		
		%get R^2
		vecMu = mean(matTrainY);
		dblSSRes_Train = sum(sum((matTrainY - matY_pred_Train).^2));
		dblSSTot_Train = sum(sum(bsxfun(@minus,matTrainY,vecMu).^2));
		dblR2_NonCV = 1 - dblSSRes_Train / dblSSTot_Train;
		
		
		%% save output
		vecR2_CV(intFold) = dblR2_CV;
		sSuppOut.cellB{intFold} = B_ridge;
		sSuppOut.vecR2_CV(intFold) = dblR2_CV;
		sSuppOut.vecR2_NonCV(intFold) = dblR2_NonCV;
		
		%% shuffled
		%get training & test set
		matTrainX = cell2mat(cellFoldsShuffledX(indFolds));
		matTestX = cell2mat(cellFoldsShuffledX(~indFolds));
		matTrainY = cell2mat(cellFoldsShuffledY(indFolds));
		matTestY = cell2mat(cellFoldsShuffledY(~indFolds));
		
	end
	%% perform ridge regression on full data
	B_ridge_Full = (matXN' * matXN + dblLambda*eye(intNeuronsX)) \ (matXN' * matYN); %left-divide is same as inverse and multiplication
	
	%% compute test performance
	%predict responses
	matY_pred_Full = matXN * B_ridge_Full;
	
	%get R^2
	vecMu = mean(matYN);
	dblSSRes_ridge = sum(sum((matYN - matY_pred_Full).^2));
	dblSSTot = sum(sum(bsxfun(@minus,matYN,vecMu).^2));
	dblR2_Full = 1 - dblSSRes_ridge / dblSSTot;
	
	%% save output
	sSuppOut.matB_Full = B_ridge_Full;
	sSuppOut.dblR2_Full = dblR2_Full;
	
end
