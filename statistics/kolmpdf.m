function p = kolmpdf(x)
% KOLMPDF Kolmogorov probability distribution function (pdf).
%    P = KOLMPDF(X) computes the Kolmogorov pdf at the values in X.
% 
%    The size of P is the common size of X. A scalar input  
%    functions as a constant matrix of the same size as the other inputs.    
% Author: Sergiy Iglin
% e-mail: iglin@kpi.kharkov.ua
% or: siglin@yandex.ru
% personal page: http://iglin.exponenta.ru
if nargin <  1, 
    error('Requires at least one input argument.');
end
p=zeros(size(x));
num=find(x>0);
xnum=x(num);
pnum=zeros(size(num));
for k=1:1000,
   add=4*(-1)^(k+1)*k^2*exp(-2*k^2*xnum.^2).*xnum;
   pnum=pnum+2*add;
   if norm(add,1)==0,
      break
   end   
end   
p(num)=p(num)+pnum;
