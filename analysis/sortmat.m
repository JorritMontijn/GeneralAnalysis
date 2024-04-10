function vecReorder = sortmat(matIn,intMaxIter)
	%sortmat Sort [n x p] matIn matrix
	%   vecReorder = sortmat(matIn,[intMaxIter=100])
	%
	%matIn must be [n x p] and contain more observations (n) than predictors (p)
	%uses 2nd PC as initial global ordering, then refines by swapping entries to maximize
	%inter-neighbor correlations 
	%
	%Reordering ceases when no more swaps can be made, or the maximum number of iterations is
	%reached (default 100)
	
	%check input
	if size(matIn,1) < size(matIn,2)
		error([mfilename ':InsufficientObservations'],'matIn must be [n x p] and contain more observations (n) than predictors (p)');
	end
	if ~exist('intMaxIter','var') || isempty(intMaxIter)
		intMaxIter = 100;
	else
		assert(isnumeric(intMaxIter) && intMaxIter > 0 && ~isinf(intMaxIter),'intMaxIter is not a valid number');
	end
	
	%start with 2nd PC as global ordering, then go through all quadruplets to swap the inner 2 that
	%decreases neighbor-distances
	coeff = pca(matIn);
	[dummy,vecNewOrder] = sort(coeff(:,2));
	intNumN = size(coeff,1);
	matIn = matIn(:,vecNewOrder);
	vecNewerOrder = 1:numel(vecNewOrder);
	boolSwapped = true;
	intCounter=0;
	while boolSwapped
		intCounter = intCounter + 1;
		boolSwapped = false;
		intOffset = modx(intCounter,3);
		for i=intOffset:3:(intNumN-3)
			matCorr = corr(matIn(:,vecNewerOrder(i:(i+3))));
			%(corr of 2 with 1) - (corr of 2 with 4 )
			dblDiffCorr2 = matCorr(1,2) - matCorr(4,2);

			%(corr of 3 with 1) - (corr of 3 with 4 )
			dblDiffCorr3 = matCorr(1,3) - matCorr(4,3);

			if dblDiffCorr3 > dblDiffCorr2
				%swap
				boolSwapped = true;
				vecNewerOrder([i+1 i+2]) = vecNewerOrder([i+2 i+1]);
			end
		end
		if intCounter > intMaxIter %continue until no more swaps occur, or a max of 100 iterations
			boolSwapped=false;
		end
	end
	%swap
	vecReorder = vecNewOrder(vecNewerOrder);
end

