function vecV = getGaussMV(vecParams,matGrid)
	%getGaussMV Summary of this function goes here
	%  vecV = getGaussMV(vecParams,matGrid)
	
	
	%transform parameter vector to mu/covar
	intDims = ndims(matGrid);
	[vecMu,matSigma] = getMuSigma(vecParams,intDims);
	
	
	%ensure S is positive definite
	dblMinVal = 10^-10;
	if det(matSigma) < dblMinVal
		[V,D] = eig(matSigma);
		V1 = V(:,1);
		matSigma = matSigma + V1*V1'*(dblMinVal-D(1,1));
	end
	
	%get values
	vecV = mvnpdf(matGrid,vecMu(:)',matSigma);
end

