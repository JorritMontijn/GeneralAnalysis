function [dblR2,dblSS_tot,dblSS_res,dblT,dblP,dblR2_adjusted,dblR2_SE] = getR2(vecY,vecFitY,intK)
	%getR2 Calculates R-squared
	%   [dblR2,dblSS_tot,dblSS_res,dblT,dblP,dblR2_adjusted,dblR2_SE] = getR2(vecY,vecFitY,intK)
	%
	%intK is number of regressors
	
	%for SE: https://stats.stackexchange.com/questions/175026/formula-for-95-confidence-interval-for-r2
	
	vecY = vecY(:);
	vecFitY = vecFitY(:);
	indUseVals = ~isnan(vecY) & ~isnan(vecFitY);
	if sum(indUseVals) ~= numel(vecY)
		warning([mfilename ':NaNsDetected'],'NaNs detected!')
	end
	vecY = vecY(indUseVals);
	vecFitY = vecFitY(indUseVals);
	dblSS_tot = sum((vecY - mean(vecY)).^2);
	dblSS_res = sum((vecY - vecFitY).^2);
	dblR2 = 1 - (dblSS_res / dblSS_tot);	
	
	%p-value
	intN = numel(vecY);
	dblT = [];
	dblP = [];
	dblR2_adjusted = [];
	if exist('intK','var') && ~isempty(intK)
		dblT=sqrt((dblR2*(intN-intK-1))/(1-dblR2) );
		dblP = 2*tcdf(real(dblT),intN-1,'upper');
		dblR2_adjusted = 1 - (((1 - dblR2) * (intN - 1)) / (intN - intK - 1));
		dblR2_SE = sqrt(((4*dblR2*(1-dblR2)^2)*(intN-intK-1)^2) / ((intN^2 - 1) * (intN + 3)));
	end
end

