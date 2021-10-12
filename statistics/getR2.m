function [dblR2,dblSS_tot,dblSS_res,dblT,dblP,dblR2_adjusted] = getR2(vecY,vecFitY,intK)
	%getR2 Calculates R-squared
	%   [dblR2,dblSS_tot,dblSS_res,dblT,dblP,dblR2_adjusted] = getR2(vecY,vecFitY,intK)
	%
	%intK is number of regressors
	
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
	end
end

