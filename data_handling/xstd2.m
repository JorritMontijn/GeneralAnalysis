function vecSD = xstd2(matInput)
	%xstd2 Fast standard deviation calculation over second dimension of 2D
	%matrix. Calculation time is approximately 75% of original std().
	%   vecSD = xstd2(matInput)
	
	intP = size(matInput,2);
	vecSD = sqrt(sum(bsxfun(@minus,matInput,sum(matInput,2)./intP).^2,2)*(1/(intP-1)));
end

