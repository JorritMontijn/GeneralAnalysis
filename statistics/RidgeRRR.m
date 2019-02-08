function weights = RidgeRRR(X,Y,lambda,rank)
% Y = X*weights subject to Ridge regularisation

Sig = (X'*X + lambda*eye(size(X,2)));
MAT = X'*Y*Y'*X/Sig;
[U, D] = eig(MAT);
[sortedD,permutation]=sort(diag(D));
U = U(:,permutation);
U = U(:,1:rank);
P = orth(U);
P = P';

W = P*X'*Y/(P*Sig*P');

weights = P'*W;
end