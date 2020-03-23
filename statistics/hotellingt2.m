% HOTELL2                     Hotelling's T-Squared test for two multivariate samples
%
%     [pval,T2] = hotellingt2(x,y)
%
%     Hotelling's T-Squared test for comparing d-dimensional data from two
%     independent samples, assuming normality w/ common covariance matrix.
%
%     INPUTS
%     x    - [n1 x d] matrix
%     y    - [n2 x d] matrix
%
%     OUTPUTS
%     pval - asymptotic p-value
%     T2   - Hotelling T^2 statistic
%
%     REFERENCE
%     Mardia, K, Kent, J, Bibby J (1979) Multivariate Analysis. Section 3.6.1
%
%     SEE ALSO
%     kstest2d, minentest
%     $ Copyright (C) 2014 Brian Lau http://www.subcortex.net/ $
%     The full license and most recent version of the code can be found on GitHub:
%     https://github.com/brian-lau/multdist
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
function [pval,T2] = hotellingt2(x,y)
	
	if exist('y','var')
		[nx,px] = size(x);
		[ny,py] = size(y);
		if px ~= py
			error('# of columns in X and Y must match');
		else
			p = px;
		end
		n = nx + ny;
		mux = mean(x);
		muy = mean(y);
		Sx = cov(x);
		Sy = cov(y);
		% Hotelling T2 statistic, Section 3.6.1 Mardia et al.
		%Su = ((nx-1)*Sx + (ny-1)*Sy) / (n-2);
		Su = (nx*Sx + ny*Sy) / (n-2); % unbiased estimate
		d = mux - muy;
		D2 = d*(Su\d');
		T2 = ((nx*ny)/n)*D2;
		F = T2 * (n-p-1) / ((n-2)*p);
		pval = 1 - fcdf(F,p,n-p-1);
	else
		[n,p] = size(x);
		m=mean(x); %Mean vector from data matrix X.
		S=cov(x);  %Covariance matrix from data matrix X.
		T2=n*m*(S\m'); %Hotelling's T-Squared statistic.
		F=(n-p)/((n-1)*p)*T2;
		v1=p;  %Numerator degrees of freedom.
		v2=n-p;  %Denominator degrees of freedom.
		pval=1-fcdf(F,v1,v2);  %Probability that null Ho: is true.
		
	end
	
	
