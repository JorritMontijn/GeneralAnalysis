function vecSD = xstd(matInput,intDim)
	%xstd Fast standard deviation calculation. Speed-up is approximately
	%50% of original computation time. Syntax: 
	%   vecSD = xstd(matInput,intDim)
	%
	%	By Dr. Jorrit S. Montijn, 29-11-16 (dd-mm-yy; Universite de Geneve)

	intP = size(matInput,intDim);
	vecSD = sqrt(sum(bsxfun(@minus,matInput,sum(matInput,intDim,'default','includenan')./intP).^2,intDim)*(1/(intP-1)));
end

