function [matW, dblMSE, intRankT, sSuppOut] = doRdRankReg(matX, matY, intRank)
	%doRdRankReg Performed reduced rank multivariate regression.
	%   [matW, dblMSE, intRankT, sSuppOut] = doRdRankReg(matX, matY, intRank)
	%   Finds the reduced rank regression using a full rank assumption. X
	%   is a n-by-r matrix, and Y is a n-by-s matrix. The rank, t, is
	%   defined as t = min(r, s). The structure sSuppOut supplies
	%   additional outputs as fields
	
	%error('Use doRidgeRRR instead');
	
	%% initialize
	% Make sure matrices are the same length
	assert(size(matX,1)==size(matY,1), 'X and Y must have the same number of observations.')
	
	% Define constants.
	intR_of_X = size(matX, 2); %source population size
	intS_of_Y = size(matY, 2); %target population size
	intN = size(matX, 1); %samples (trials)
	
	% Handle the optimal arguments
	if ~exist('intRank','var')
		intRankT = min(intR_of_X, intS_of_Y);
	else
		intRankT = intRank;
	end
	if intRankT > min(intR_of_X, intS_of_Y)
		error([mfilename ':ReqRankOutOfBounds'],sprintf('Requested rank (%d) is too large',intRankT))
	end
	
	%% compute RRR
	%split covariance matrix into four quadrants;			 %Izenman (1975), eq 2.2
	full_covariance = cov([matX matY]);% + dblLambda*eye(intR_of_X+intS_of_Y);
	matSSXX = full_covariance(1:intR_of_X, 1:intR_of_X);
	matSSYX = full_covariance((intR_of_X+1):end, 1:intR_of_X);
	matSSXY = full_covariance(1:intR_of_X, (intR_of_X+1):end);
	matSSYY = full_covariance((intR_of_X+1):end, (intR_of_X+1):end);
	
	% Define the weighting matrix
	matGamma = inv(matSSYY);
	
	% Define the matrix of eigen-values
	if intRankT < 20
		[matV_rr,vecD_rr]=eig(((sqrtm(matGamma)*matSSYX)/matSSXX)*matSSXY*sqrtm(matGamma),'vector');
		[vecD_rr,vecReorder] = sort(vecD_rr,'descend');
		matD_rr = diag(vecD_rr(1:intRankT));
		matV_rr = matV_rr(:,vecReorder);
		matV_rr = matV_rr(:,1:intRankT);
	else
		warning('off','MATLAB:eigs:TooManyRequestedEigsForComplexNonsym');
		[matV_rr, matD_rr] = eigs(((sqrtm(matGamma)*matSSYX)/matSSXX)*matSSXY*sqrtm(matGamma),intRankT);
		warning('on','MATLAB:eigs:TooManyRequestedEigsForComplexNonsym');
	end
	
	% Define the decomposition and mean matrices
	matA = sqrtm(inv(matGamma))*matV_rr;					%Izenman (1975), eq 2.5
	matB = (matV_rr'*sqrtm(matGamma)*matSSYX)/matSSXX;	%Izenman (1975), eq 2.6
	matW = (matA*matB)';
	matMu = mean(matY)' - (matW)'*(mean(matX)');			%Izenman (1975), eq 2.7
	
	%% get prediction
	matY_pred = repmat(matMu',[intN 1]) + matX*matW;
	
	%% compute MSE
	matErr = (matY - matY_pred).^2;
	dblMSE = mean(matErr(:));
	
	%% set additional outputs
	if nargout > 3
		sSuppOut.matV_rr = matV_rr;
		sSuppOut.matD_rr = matD_rr;
		sSuppOut.matA = matA;
		sSuppOut.matB = matB;
		sSuppOut.matMu = matMu;
		sSuppOut.matY_pred = matY_pred;
		sSuppOut.matErr = matErr;
		
		%get R^2
		vecMu = mean(matY);
		dblSSRes = sum(sum(matErr));
		dblSSTot = sum(sum(bsxfun(@minus,matY,vecMu).^2));
		dblR2 = 1 - dblSSRes / dblSSTot;
		
		sSuppOut.dblSSRes = dblSSRes;
		sSuppOut.dblSSTot = dblSSTot;
		sSuppOut.dblR2 = dblR2;
		
	end
end
