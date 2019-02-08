function matD = getCohensD(mat1,mat2,intDim)
	%getCohensD Calculates Cohen's d measure of effect size
	%   matD = getCohensD(mat1,mat2,intDim)
	
	%check input format
	matD = nan;
	if isempty(mat1) || isempty(mat2),warning([mfilename ':InputEmpty'],'Input empty; returning NaN');return; %if empty
	elseif ndims(mat1) == 2 && min(size(mat1)) == 1 %if vector, then size is not important
	elseif any(size(mat1)~=size(mat2)),warning([mfilename ':SamplesMismatched'],'Inputs 1 and 2 have different sizes');
	end
	
	%check over which dimension to perform
	if ~exist('intDim','var')
		if ndims(mat1) == 2 && size(mat1,1) == 1
			intDim = 2;
		else
			intDim = 1;
		end
	end
	
	%calculate Cohen's D
	matD = (mean(mat1,intDim) - mean(mat2,intDim)) ./ getSigmaP(mat1,mat2,intDim);
end
function matSigmaP = getSigmaP(mat1,mat2,intDim)
	matVar1 = nanvar(mat1,[],intDim);
	matVar2 = nanvar(mat2,[],intDim);
	matN1 = sum(~isnan(mat1),intDim);
	matN2 = sum(~isnan(mat2),intDim);
	matSigmaP = sqrt(((matN1 - 1).*matVar1 + (matN2 - 1).*matVar2) ./ (matN1 + matN2 - 2));
end
