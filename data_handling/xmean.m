function vecMean = xmean(matInput,intDim)
	%xstd Fast mean calculation. Speed-up is approximately 95% of original
	%time. Syntax:   
	%   vecMean = xmean(matInput,intDim)
	%
	%	By Dr. Jorrit S. Montijn, 29-11-16 (dd-mm-yy; Universite de Geneve)

	vecMean = sum(matInput,intDim,'default','includenan')./size(matInput,intDim);
end

