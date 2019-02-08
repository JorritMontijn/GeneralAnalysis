function [matC, dblMSE, intRankT, sSuppOut] = doRdRankReg(matX, matY, varargin)
	%doRdRankReg Performed reduced rank multivariate regression.
	%   [matC, dblMSE, intRankT, sSuppOut] = doRdRankReg(matX, matY)
	%   Finds the reduced rank regression using a full rank assumption. X
	%   is a n-by-r matrix, and Y is a n-by-s matrix. The rank, t, is
	%   defined as t = min(r, s). The structure sSuppOut supplies
	%   additional outputs as fields
	%
	%   doRdRankReg(X, Y, 'PARAM1', VALUE1, 'PARAM2', VALUE2) specifies additional
	%   parameter name/value pairs chosen from the following:
	%       'rank'      Specifies how to compute the apprporiate rank. Follow
	%                   with an integer greater than or equal to 1 to specify
	%                   the rank of the matrix directly. Follow with a floating
	%                   point number less than 1 to specify a significance
	%                   value to compute the rank by linear correlation between
	%                   rows in Y.  A vector of two integer [N, K] defined a
	%                   K-folds cross-validation pattern that subsamples N data
	%                   points from X and Y. The appropriate rank is then
	%                   estimated via minimum square error of the k-folds
	%                   testing set.
	%       'weighting' Define a positive-definite s-by-s weighting matrix.
	%                   Default value is inv(cov(Y)).
	%
	%
	
	% Make sure matrices are the same length
	assert(size(matX,1)==size(matY,1), 'X and Y must have the same number of observations.')
	
	% Make sure the arguments are in the right format
	for i=1:2:length(varargin)
		assert(isstr(varargin{i}), 'Additional arguments must specify a parameter string first.');
	end
	
	% Define prima facie constants.
	intR_of_X = size(matX, 2); %source population size
	intS_of_Y = size(matY, 2); %target population size
	intN = size(matX, 1); %samples (trials)
	
	% Handle the optimal arguments
	intRankT = min(intR_of_X, intS_of_Y);
	matGamma = 0;
	if nargin > 2
		for i=3:2:nargin
			if strcmp(varargin{i-2}, 'weighting')
				G = varargin{i-1};
				assert((size(G,1)==intS_of_Y && size(G,2)==intS_of_Y), 'The weighting matrix must be square and have dimension equal to the number of dependent variables.');
				[~, posdef] = chol(G); assert((posdef==0), 'The weighting matrix must be positive definite.');
			end
		end
		
		for i=3:2:nargin
			if strcmp(varargin{i-2}, 'rank')
				if length(varargin{i-1}) == 2
					% Extract constants
					intCrossValN = varargin{i-1}(1);
					intFoldK = varargin{i-1}(2);
					assert((intN >= intCrossValN), sprintf('The data contains only %d samples, but you specified a subsample of %d for cross-fold validation.', intN, intCrossValN));
					assert((intFoldK <= intCrossValN), 'The number of folds for cross-validation must be less than or equal to the sub-sample.');
					assert((intCrossValN/intFoldK == round(intCrossValN/intFoldK)), 'Please specify a subsample number that is an integer multiple of the number of folds.');
					
					% Initialize vectors
					mse_k = zeros(1,intFoldK);
					mse_t = zeros(1,intS_of_Y);
					
					% Make folds
					sCV = [];
					options = randsample(intN, intCrossValN);
					fold_size = intCrossValN/intFoldK;
					for ii=1:1:intFoldK
						temp = options;
						test_slice = ((ii-1)*fold_size+1):1:(ii*fold_size);
						sCV(ii).test = temp(test_slice);
						temp(test_slice) = [];
						sCV(ii).train = temp;
					end
					
					% Test folds
					for j=1:1:intS_of_Y
						for k=1:1:intFoldK
							bb = compute_rrr(matX(sCV(k).train, :), matY(sCV(k).train, :), j, G);
							mse_k(k) = compute_mse(bb, matX(sCV(k).test, :), matY(sCV(k).test, :));
						end
						mse_t(j) = mean(mse_k);
					end
					
					% Find the best value for t
					intRankT = find(mse_t == min(mse_t));
					
				elseif varargin{i-1} >= 1
					% Just define t and run with it
					intRankT = varargin{i-1};
					assert((round(intRankT)==intRankT), sprintf('The specified rank must be an integer value (you used t = %.2f).', intRankT));
					
				elseif varargin{i-1} < 1
					% Find rank t based on correlation analysis
					assert((varargin{i-1} > 0), sprintf('The specified confidence value must be greater than 0 (you used rho = %.2f)', varargin{i-1}));
					p_crit = varargin{i-1};
					
					while true
						[~, p] = corr(matY);
						score = sum(min(p) < p_crit);
						if score == 0
							break;
						end
						idx = find(min(p) == min(min(p)));
						matY(:,idx(1)) = [];
					end
					
					intRankT = size(matY, 2);
				end
			end
		end
	end
	
	%% compute RRR
	% Define constants
	intR_of_X = size(matX, 2);
	
	%split covariance matrix into four quadrants;			 %Izenman (1975), eq 2.2
	full_covariance = cov([matX matY]);
	matSSXX = full_covariance(1:intR_of_X, 1:intR_of_X);
	matSSYX = full_covariance((intR_of_X+1):end, 1:intR_of_X);
	matSSXY = full_covariance(1:intR_of_X, (intR_of_X+1):end);
	matSSYY = full_covariance((intR_of_X+1):end, (intR_of_X+1):end);
	
	% Define the weighting matrix
	if length(matGamma) == 1
		matGamma = inv(matSSYY);
	end
	
	% Define the matrix of eigen-values
	warning('off','MATLAB:eigs:TooManyRequestedEigsForComplexNonsym');
	[matV_rr, matD_rr] = eigs(((sqrtm(matGamma)*matSSYX)/matSSXX)*matSSXY*sqrtm(matGamma),intRankT);
	warning('on','MATLAB:eigs:TooManyRequestedEigsForComplexNonsym');
	
	% Define the decomposition and mean matrices
	matA = sqrtm(inv(matGamma))*matV_rr;					%Izenman (1975), eq 2.5
	matB = (matV_rr'*sqrtm(matGamma)*matSSYX)/matSSXX;	%Izenman (1975), eq 2.6
	matMu = mean(matY)' - matA*matB*(mean(matX)');			%Izenman (1975), eq 2.7
	matC = (matA*matB)';
	% get prediction1
	matY_pred = repmat(matMu',[intN 1]) + matX*matC;
	% compute MSE1
	matErr = (matY - matY_pred).^2;
	dblMSE = mean(matErr(:));
	
	%{
	% Define the decomposition and mean matrices
	matA2 = sqrtm(inv(matGamma))*matV_rr;					%Izenman (1975), eq 2.5
	matB2 = (matV_rr'*sqrtm(matGamma)*matSSYX)/matSSXX;	%Izenman (1975), eq 2.6
	matMu2 = mean(matY)' - matA2*matB2*(mean(matX2)');			%Izenman (1975), eq 2.7
	matC2 = (matA2*matB2)';
	% get prediction2
	matY_pred2 = repmat(matMu2',[intN 1]) + matX2*matC2;
	% compute MSE1
	matErr2 = (matY - matY_pred2).^2;
	dblMSE2 = mean(matErr(:));
	%}
	
	
	
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
