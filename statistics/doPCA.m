function [U, L, mu] = doPCA(matX)
% Principal component analysis
% Input:
%   matX: m x n data matrix 
% Output:
%   U: m x m Projection matrix
%   L: m x 1 Eigen values
%   mu: m x 1 mean

[m,n] = size(matX);
mu = mean(matX,2);
Xo = bsxfun(@minus,matX,mu);
S = Xo*Xo'/n;
[U,L] = eig(S);
[L,idx] = sort(diag(L),'descend');      
U = U(:,idx(1:m));
L = L(1:m);
