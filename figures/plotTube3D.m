function [handle,matX_final,matY_final,matZ_final,matC] = plotTube3D(vecX,vecY,vecZ,vecR,vecC,intPointsPerRadius,boolConnectEnds)
	%plotTube3D Plots 3D tube with specified color-range and width
	%Syntax: handle = plotTube3D(vecX,vecY,vecZ,vecR,vecC,intPointsPerRadius)
	
	%plot 3D tube
	%{
	vecX = [-1 -0.8 -0.3 -0.1 0.05 0.2 0.4 0.7 0.9 1.0];
	vecY = [-0.9 -0.85 -0.2 -0.15 0.1 0.1 0.4 0.7 0.9 1.0];
	vecZ = [-1 -0.8 -0.3 -0.1 0.05 0.2 0.4 0.7 0.9 1.0];
	vecR = [0.1 0.2 0.1 0.3 0.1 0.2 0.2 0.2 0.1 0.3];
	vecC = [0 0.01 0.05 0.1 0.2 0.4 0.5 0.8 0.9 0.95];
	%}
	
	%check optional inputs
	intPoints = length(vecX);
	if nargin < 4 || isempty(vecR)
		vecR = 1;
	end
	if nargin < 6 || isempty(intPointsPerRadius)
		intPointsPerRadius = 27;
	end
	if nargin < 7 || isempty(boolConnectEnds)
		boolConnectEnds = false;
	end
	
	
	intPointsPerRadius = intPointsPerRadius + 1;
	if isscalar(vecR)
		vecR = ones(size(vecX))*vecR;
	end
	if isscalar(vecC)
		vecC = ones(size(vecX))*vecC;
	end
	
	%pre-allocate plotting matrix
	matX_final = nan(intPointsPerRadius,intPoints);
	matY_final = nan(intPointsPerRadius,intPoints);
	matZ_final = nan(intPointsPerRadius,intPoints);
	
	%loop through points
	for intP = 1:(intPoints-1)
		r = vecR(intP);
		P1 = [vecX(intP) vecY(intP) vecZ(intP)];
		P2 = [vecX(intP+1) vecY(intP+1) vecZ(intP+1)];
		u = P2-P1;
		t = r*null(u)';
		v = t(1,:);
		w = t(2,:);
		[S,T] = meshgrid(linspace(0,1,2),linspace(0,2*pi,intPointsPerRadius));
		S = S(:); T = T(:);
		P = repmat(P1,2*intPointsPerRadius,1) + S*u + cos(T)*v + sin(T)*w;
		X = reshape(P(:,1),intPointsPerRadius,2);
		Y = reshape(P(:,2),intPointsPerRadius,2);
		Z = reshape(P(:,3),intPointsPerRadius,2);
		
		matX_final(:,intP) = X(:,1);
		matY_final(:,intP) = Y(:,1);
		matZ_final(:,intP) = Z(:,1);
	end
	%add last point
	
	r = vecR(end);
	if boolConnectEnds
		P1 = [vecX(end) vecY(end) vecZ(end)];
		P2 = [vecX(1) vecY(1) vecZ(1)];
		
		u = P2-P1;
		t = r*null(u)';
		v = t(1,:);
		w = t(2,:);
		[S,T] = meshgrid(linspace(0,1,2),linspace(0,2*pi,intPointsPerRadius));
		S = S(:); T = T(:);
		P = repmat(P1,2*intPointsPerRadius,1) + S*u + cos(T)*v + sin(T)*w;
		X = reshape(P(:,1),intPointsPerRadius,2);
		Y = reshape(P(:,2),intPointsPerRadius,2);
		Z = reshape(P(:,3),intPointsPerRadius,2);
		
		matX_final(:,end) = X(:,2);
		matY_final(:,end) = Y(:,2);
		matZ_final(:,end) = Z(:,2);
	else
		P1 = [vecX(end-1) vecY(end-1) vecZ(end-1)];
		P2 = [vecX(end) vecY(end) vecZ(end)];
		
		u = P2-P1;
		t = r*null(u)';
		v = t(1,:);
		w = t(2,:);
		[S,T] = meshgrid(linspace(0,1,2),linspace(0,2*pi,intPointsPerRadius));
		S = S(:); T = T(:);
		P = repmat(P1,2*intPointsPerRadius,1) + S*u + cos(T)*v + sin(T)*w;
		X = reshape(P(:,1),intPointsPerRadius,2);
		Y = reshape(P(:,2),intPointsPerRadius,2);
		Z = reshape(P(:,3),intPointsPerRadius,2);
		
		matX_final(:,end) = X(:,2);
		matY_final(:,end) = Y(:,2);
		matZ_final(:,end) = Z(:,2);
	end

	%plot
	if isempty(vecC)
		matC = [];
		handle = surf(matX_final,matY_final,matZ_final);
	else
		matC = repmat(vecC,[intPointsPerRadius 1]);
		handle = surf(matX_final,matY_final,matZ_final,matC);
	end
	
	%lighting
	view(3)
	axis tight
	shading interp
	camlight; lighting gouraud
end