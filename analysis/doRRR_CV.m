function [matW, dblMSE, intRankT, sSuppOut, intOutputFlag] = doRRR_CV(matX, matY, intRankT, intFoldK, dblLambda, matB, matCov)
	%doRRR_CV Performed CV reduced rank multivariate regression.
	%   [matW, dblMSE, intRankT, sSuppOut] = doRRR_CV(matX, matY, intRankT=min(R,S), intFoldK=10, dblLambda=0, [matB], [matCov])
	%   Finds the reduced rank regression using a full rank assumption. X
	%   is a n-by-r matrix, and Y is a n-by-s matrix. The rank, t, is
	%   defined as t = min(r, s). The structure sSuppOut supplies
	%   additional outputs as fields.
	%	matB and matCov are additional inputs for calculating performance
	%	when subtracting predictive dimensions from full rank space; matB
	%	is the regression matrix, matCov is the covariance
	
	%% initialize
	% Make sure matrices are the same length
	assert(size(matX,1)==size(matY,1), 'X and Y must have the same number of observations.')
	intOutputFlag = 0;
	intR_of_X = size(matX, 2); %source population size
	intS_of_Y = size(matY, 2); %target population size
	intN = size(matX, 1); %samples (trials)
	
	%default K
	if ~exist('intRankT','var') || isempty(intRankT)
		intRankT = min(intR_of_X, intS_of_Y);
	end
	if ~exist('intFoldK','var')
		intFoldK = 10;
	end
	%default Lambda
	if ~exist('dblLambda','var')
		dblLambda = 0;
	end
	
	%% remove means
	vecMeanX = mean(matX);
	vecMeanY = mean(matY);
	matXN = bsxfun(@minus,matX,vecMeanX);
	matYN = bsxfun(@minus,matY,vecMeanY);
	
	%% general metadata
	intRepetitions = size(matXN,1);
	intNeuronsX = size(matXN,2);
	intNeuronsY = size(matYN,2);
	intTrialsPerFold = floor(min(intRepetitions)/intFoldK); %take lowest number of repetitions for the two classes, and round down when dividing in equal K-folds
	
	%% select data
	if (any(range(matXN,1)==0) || any(range(matYN,1)==0))
		warning([mfilename ':Range0'],'Range is zero for >=1 predictors');
		intOutputFlag = 1;
	end
	
	%% get folds
	[cellFoldsX,cellFoldsY,cellFoldsShuffledX,cellFoldsShuffledY] = getFolds(intFoldK,matX,matY);
	
	
	%% pre-allocate output
	%parfor intFold=1:intFoldK
	sSuppOut = struct;
	sSuppOut.vecR2_CV = nan(1,intFoldK);
	sSuppOut.vecR2_Rem = nan(1,intFoldK);
	sSuppOut.vecR2_NoNCV = nan(1,intFoldK);
	sSuppOut.matW_Train = nan(intNeuronsX,intNeuronsY,intFoldK);
	sSuppOut.matMu_Train = nan(intNeuronsY,1,intFoldK);
	sSuppOut.matY_pred_CV = nan(intTrialsPerFold,intNeuronsY,intFoldK);
	sSuppOut.matErr_CV = nan(intTrialsPerFold,intNeuronsY,intFoldK);
	
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
		
		%get RRR output
		%[matW, dblMSE, intRankT, sSupp] = doRdRankReg(matTrainX, matTrainY, intRankT);
		[matW, dblMSE, intRankT, sSupp] = doRidgeRRR(matTrainX,matTrainY,intRankT,dblLambda);
		
		%% get prediction
		matY_pred = repmat(sSupp.matMu',[size(matTestX, 1) 1]) + matTestX*matW;
		
		%% compute MSE
		matErr = (matTestY - matY_pred).^2;
		vecMu = mean(matTestY);
		dblSSRes = sum(sum(matErr));
		dblSSTot = sum(sum(bsxfun(@minus,matTestY,vecMu).^2));
		dblR2 = 1 - dblSSRes / dblSSTot;
		sSuppOut.vecR2_CV(intFold) = dblR2;
		sSuppOut.vecR2_NonCV(intFold) = sSupp.dblR2;
		
		%% perform prediction when removing predictive dimensions
		if exist('matB','var') && exist('matCov','var')
			%basis in target
			matW_BasisT = orth(matW'); 
			
			%get B-hat
			B_hat = matB * matW_BasisT; %define B-hat as the top predictive dimensions, using B and reduced rank version of V
			matM = B_hat' * matCov; %combine B-hat with covariance matrix
			
			%get orthogonal basis Q for predictive nullspace
			[U,S,V] = svd(matM,0); %singular value decomposition of matrix M
			Q = V(:,(intRankT+1):end); %orthonormal basis for uncorrelated (non-predictive) subspace
			
			% project source activity onto uncorrelated subspace
			X_hat = matTestX * Q; %uncorrelated subspace of X
			
			%ridge regression between X_hat and Y
			B_ridge_hat = (X_hat' * X_hat + dblLambda*eye(size(X_hat,2))) \ (X_hat' * matTestY); %left-divide is same as inverse and multiplication
			Y_pred_rem = X_hat * B_ridge_hat;
			
			% compute R^2
			vecMu = mean(matTestY);
			dblSSRes_rem = sum(sum((matTestY - Y_pred_rem).^2));
			dblSSTot_rem = sum(sum(bsxfun(@minus,matTestY,vecMu).^2));
			dblR2_rem = 1 - dblSSRes_rem / dblSSTot_rem;
			sSuppOut.vecR2_Rem(intFold) = dblR2_rem;
		end
		
		%% save output
		sSuppOut.matW_Train(:,:,intFold) = matW;
		sSuppOut.matMu_Train(:,:,intFold) = sSupp.matMu;
		sSuppOut.matY_pred_CV(:,:,intFold) = matY_pred;
		sSuppOut.matErr_CV(:,:,intFold) = matErr;
		
		%% shuffled
		%get training & test set
		matTrainX = cell2mat(cellFoldsShuffledX(indFolds));
		matTestX = cell2mat(cellFoldsShuffledX(~indFolds));
		matTrainY = cell2mat(cellFoldsShuffledY(indFolds));
		matTestY = cell2mat(cellFoldsShuffledY(~indFolds));
		
	end
	
	%% build output
	%get full-data subspace
	%[matW, dblMSE, intRankT, sSuppFull] = doRdRankReg(matXN, matYN, intRankT);
	[matW, dblMSE, intRankT, sSuppFull] = doRidgeRRR(matXN,matYN,intRankT,dblLambda);
	dblMSE = mean(sSuppFull.matErr(:));
	dblR2_CV = mean(sSuppOut.vecR2_CV);
	dblR2_NonCV = sSuppFull.dblR2;
	sSuppOut = catstruct(sSuppOut,sSuppFull);
	sSuppOut.dblR2_CV = dblR2_CV;
	sSuppOut.dblR2_NonCV = dblR2_NonCV;
end
