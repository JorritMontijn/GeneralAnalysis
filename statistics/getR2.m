function [dblR2,dblSS_tot,dblSS_res] = getR2(vecY,vecFitY)
	%getR2 Calculates R-squared
	%   [dblR2,dblSS_tot,dblSS_res] = getR2(vecY,vecFitY)
	dblSS_tot = sum((vecY - mean(vecY)).^2);
	dblSS_res = sum((vecY - vecFitY).^2);
	dblR2 = 1 - (dblSS_res / dblSS_tot);	
end

