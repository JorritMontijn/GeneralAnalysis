
%% set options
sOptions = struct;
sOptions.Solver='lsqcurvefit';
sOptions.MaxIterations = 1000;

%% no gauss
vecY = vecActivity;
cellCoeffs01 = {0,0,0,0,0,0};
[cellCoeffs1,matOutX,cellBasisFunctions,vecLinCoeffs,vecLinCoeffFunctions] = gnmfit(matX,vecY,cellCoeffs01,sOptions);
vecPredY1 = gnmval(cellCoeffs1,matOutX,cellBasisFunctions);
figure
scatter(vecY,vecPredY1)
title(sprintf('GLM, Corr is %.3f',corr(vecY,vecPredY1)))

%% with gauss
cellCoeffs02 = {0,0,0,[0,0,1],0,0};
[cellCoeffs2,matOutX,cellBasisFunctions,vecLinCoeffs,vecLinCoeffFunctions] = gnmfit(matX,vecY,cellCoeffs02,'gnmgauss',4,sOptions);
vecPredY2 = gnmval(cellCoeffs2,matOutX,cellBasisFunctions);
figure
scatter(vecY,vecPredY2)
title(sprintf('GNM, Corr is %.3f',corr(vecY,vecPredY2)))


