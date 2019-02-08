function [matW, dblMSE, intRank, sSuppOut] = doRidgeRRR(matX,matY,intRank,dblLambda)
	% Y = X*matW subject to Ridge regularisation
	
	%% initialize
	% Make sure matrices are the same length
	assert(size(matX,1)==size(matY,1), 'X and Y must have the same number of observations.')
	
	% Define prima facie constants.
	intR_of_X = size(matX, 2); %source population size
	intS_of_Y = size(matY, 2); %target population size
	intN = size(matX, 1); %samples (trials)
	
	%set default parameters
	if ~exist('intRank','var') || isempty(intRank)
		intRank = min(intR_of_X, intS_of_Y);
	end
	if ~exist('dblLambda','var') || isempty(dblLambda)
		dblLambda = 0;
	end
	
	%% rex's code; constrain projection matrix P to N first eigenvectors
	Sig = (matX'*matX + dblLambda*eye(size(matX,2)));
    matXTY = matX'*matY;
    MAT = Sig\(matXTY*matXTY');
	[matV, D] = eig(MAT);
	[sortedD,permutation]=sort(real(diag(D)),'descend');
	matV = matV(:,permutation);
	matV = matV(:,1:intRank);
	P = orth(matV);
	
	U = (P'*Sig*P)\P'*matXTY;
	
	%get the weights
	matW = real(P*U);
	
	%get bias
	matMu = mean(matY)' - (matW')*(mean(matX)');
	
	%% get prediction
	matY_pred = repmat(matMu',[intN 1]) + matX*matW;
	
	%% compute MSE
	matErr = (matY - matY_pred).^2;
	dblMSE = mean(matErr(:));
	
	%% set additional outputs
	if nargout > 3
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
