%=============================================================================%
%  generate_tube frames:  Given a 3D curve (x,y,z) build a tube as a mesh of  %
%                         polygons (mainly triangles of quadrilateral)        %
%                                                                             %
%                                                                             %
%  USAGE: [pnts,conn] = generate_open_tube(typ,R,nr,xyz) ;                    %
%         [pnts,conn] = generate_open_tube(typ,R,nr,x,y,z) ;                  %
%                                                                             %
%  On input:                                                                  %
%                                                                             %
%       x,y,z     = vectors with N components coordinates of the 3D curves    %
%       xyz       = matrix 3 by N, N points on the 3D curve                   %
%       nr        = number or radial subdivision of the tube                  %
%       R         = Ray of the generated tube                                 %
%       typ       = type of generated mesh                                    %
%                   0 - quadrilateral mesh                                    %
%                   1 - triangular mesh (by split quadrilateral mode 1)       %
%                   2 - triangular mesh (by split quadrilateral mode 2)       %
%                   3 - triangular mesh (alternate mode 1 and mode 2)         %
%                   4 - triangular mesh (alternate mode 2 and mode 1)         %
%                                                                             %
%                          b --- d           b --- d                          %
%                   mode 1 |  /  |    mode 2 |  \  |                          %
%                          a --- c           a --- c                          %
%                                                                             %
%       first and last face of the tube is splitted in triangles for typ > 0  %
%       otherwise is a polygon with nr edges                                  %
%                                                                             %
%  On output:                                                                 %
%                                                                             %
%       pnts      = matrix 3 by Npoints of the points generated               %
%       conn      = cell array with the face connection                       %
%                                                                             %
%=============================================================================%
%                                                                             %
%  Autor: Enrico Bertolazzi                                                   %
%         Department of Industrial Engineering                                %
%         University of Trento                                                %
%         enrico.bertolazzi@unitn.it                                          %
%                                                                             %
%=============================================================================%
function [pnts,conn,line1,line2] = generate_open_tube(typ,R,nr,varargin)
	
	narginchk(4,6) ;
	
	% check input
	if ~ (isreal(typ) && isscalar(typ) && typ >=0 && typ <= 4 )
		error('expected as first argument a scalar in the range [0,4]');
	else
		typ = fix(typ) ;
	end
	%if ~ (isfloat(R) && isscalar(R) && R > 0 )
	%  error('expected as second argument a scalar greater than 0');
	%end
	if ~ (isreal(nr) && isscalar(nr) && nr >= 3 )
		error('expected as third argument a scalar integer >= 3');
	else
		nr = fix(nr) ;
	end
	
	if nargin == 4
		xyz = varargin{1};
		% check data
		if ~isfloat(xyz) || ~ismatrix(xyz) || size(xyz,1) ~= 3
			error('expected as fourth argument a matrix 3 by N');
		end
		% --> to column vector
		x = xyz(1,:).';
		y = xyz(2,:).';
		z = xyz(3,:).';
	elseif nargin == 6
		x = varargin{1}(:);
		y = varargin{2}(:);
		z = varargin{3}(:);
		% check data
		if ~isfloat(x) || ~isvector(x) || ~isfloat(y) || ~isvector(y) || ~isfloat(z) || ~isvector(z)
			error('expected real vector as argument N. 3,4, and 5 ');
		end
		% --> to column vector
	else
		error('expected 4 or 6 arguments');
	end
	
	nt = length(x) ;
	
	% --> speed
	dx = diff(x);
	dy = diff(y);
	dz = diff(z);
	
	dx = [1.5*dx(1)-0.5*dx(2);(dx(1:end-1)+dx(2:end))/2;1.5*dx(end)-0.5*dx(end-1)] ;
	dy = [1.5*dy(1)-0.5*dy(2);(dy(1:end-1)+dy(2:end))/2;1.5*dy(end)-0.5*dy(end-1)] ;
	dz = [1.5*dz(1)-0.5*dz(2);(dz(1:end-1)+dz(2:end))/2;1.5*dz(end)-0.5*dz(end-1)] ;
	
	% TANGENT
	lens   = sqrt(dx.^2+dy.^2+dz.^2) 
	T      = zeros(3,nt) ;
	T(1,:) = dx ./ lens ;
	T(2,:) = dy ./ lens ;
	T(3,:) = dz ./ lens ;
	
	% DERIVATIVE OF TANGENT
	dTx = diff(T(1,:)).'
	dTy = diff(T(2,:)).'
	dTz = diff(T(3,:)).'
	
	dTx = [1.5*dTx(1)-0.5*dTx(2);(dTx(1:end-1)+dTx(2:end))/2;1.5*dTx(end)-0.5*dTx(end-1)] ;
	dTy = [1.5*dTy(1)-0.5*dTy(2);(dTy(1:end-1)+dTy(2:end))/2;1.5*dTy(end)-0.5*dTy(end-1)] ;
	dTz = [1.5*dTz(1)-0.5*dTz(2);(dTz(1:end-1)+dTz(2:end))/2;1.5*dTz(end)-0.5*dTz(end-1)] ;
	
	% NORMAL
	lens   = sqrt(dTx.^2+dTy.^2+dTz.^2) ;
	N      = zeros(3,nt) ;
	N(1,:) = dTx ./ lens ;
	N(2,:) = dTy ./ lens ;
	N(3,:) = dTz ./ lens ;
	
	% BINORMAL
	T
	N
	B = cross(T,N)
	
	[N,B,nstep] = smoothing_frames(T,N,B,nr) ; %error
	
	%
	% list of points
	%
	if typ == 0
		pnts = zeros(3,nt*nr) ;
	else
		pnts = zeros(3,nt*nr+2) ;
	end
	tt = 2*pi*linspace(0,1,nr+1) ;
	ss = cos(tt+pi/4) ;
	rr = sin(tt+pi/4) ;
	kk = 0 ;
	for i=1:nt
		if isscalar(R),dblR=R;else dblR = R(i);end
		P = [x(i);y(i);z(i)] ;
		n = N(:,i) ;
		b = B(:,i) ;
		for k=1:nr
			kk = kk+1 ;
			pnts(:,kk) = P+dblR*ss(k)*b+dblR*rr(k)*n ;
		end
	end
	%
	if typ ~= 0
		pnts(:,kk+1) = pnts(:,1);
		pnts(:,kk+2) = pnts(:,kk);
		for k=2:nr
			pnts(:,kk+1) = pnts(:,kk+1)+pnts(:,k) ;
			pnts(:,kk+2) = pnts(:,kk+2)+pnts(:,kk-k+1) ;
		end
		pnts(:,kk+1) = pnts(:,kk+1)./nr;
		pnts(:,kk+2) = pnts(:,kk+2)./nr ;
	end
	
	conn = generate_conn(typ,nr,nt,nstep) ;
	
	line1 = [ 1:nr:nr*(nt-1) mod(nr-nstep,nr)+1 ] ;
	line2 = [ 1:1:nr 1] ;
end
%
%
%
function conn = generate_conn(typ,nr,nt,nstep)
	kk    = 0 ;
	ttyp  = typ ;
	if typ > 3
		ttyp1 = 2 ;
		ttyp2 = 1 ;
	else
		ttyp1 = 1 ;
		ttyp2 = 2 ;
	end
	if typ == 0
		nface = nr*(nt-1)+2 ;
	else
		nface = nr*(nt-1)+2*nr ;
	end
	conn = cell(nface,1) ;
	for i=1:nt-1
		bb = (i-1)*nr ;
		ii = (i-1)*nr+[1:nr 1] ;
		jj = ii+nr ;
		for k=1:nr
			ia = ii(k)   ;
			ic = ii(k+1) ;
			ib = jj(k)   ;
			id = jj(k+1) ;
			if typ > 2
				if mod(i+k,2) == 0
					ttyp = ttyp1 ;
				else
					ttyp = ttyp2 ;
				end
			end
			
			switch ttyp
				case 0
					kk = kk+1 ;
					% b --- d
					% |     |
					% a --- c
					conn{kk} = [ia,ic,id,ib] ;
				case 1
					% b --- d
					% |  /  |
					% a --- c
					conn{kk+1} = [ia,id,ic] ;
					conn{kk+2} = [ia,ib,id] ;
					kk = kk+2 ;
				case 2
					% b --- d
					% |  \  |
					% a --- c
					conn{kk+1} = [ia,ib,ic] ;
					conn{kk+2} = [ib,id,ic] ;
					kk = kk+2 ;
			end
		end
	end
	if typ == 0
		conn{kk+1} = [1:nr] ;
		conn{kk+2} = [nr:-1:1]+nr*(nt-1) ;
	else
		IDX1 = [1:nr 1] ;
		IDX2 = [nr:-1:1 nr]+nr*(nt-1) ;
		id   = nr*nt+1 ;
		for k=1:nr
			conn{kk+1} = [id   IDX1(k) IDX1(k+1)] ;
			conn{kk+2} = [id+1 IDX2(k) IDX2(k+1)] ;
			kk = kk+2 ;
		end
	end
end
function [smoothN,smoothB,nstep] = smoothing_frames(T,N,B,ndivangle)

  [theta,nstep] = smoothing_frame_by_projection(T,N,B,ndivangle) ;

  m            = size(N,2) ;
  smoothN      = zeros(3,m);
  smoothN(1,:) = N(1,:).*cos(theta) + B(1,:).*sin(theta) ;
  smoothN(2,:) = N(2,:).*cos(theta) + B(2,:).*sin(theta) ;
  smoothN(3,:) = N(3,:).*cos(theta) + B(3,:).*sin(theta) ;

  smoothB      = zeros(3,m);
  smoothB(1,:) = N(1,:).*cos(theta+pi/2) + B(1,:).*sin(theta+pi/2) ;
  smoothB(2,:) = N(2,:).*cos(theta+pi/2) + B(2,:).*sin(theta+pi/2) ;
  smoothB(3,:) = N(3,:).*cos(theta+pi/2) + B(3,:).*sin(theta+pi/2) ;

end
%
%
%
function [theta,nstep] = smoothing_frame_by_projection(T,N,B,ndivangle)
  m     = size(N,2) ;
  theta = zeros(1,m) ;
  % opt   = optimset( 'Display', 'off', 'TolX', 1e-5 ) ;

  %%%
  for k=1:m-1
    T1 = T(:,k) ;
    T2 = T(:,k+1) ;
    % rotate frame (T1,N1) by the previous computed angle theta(k)
    N1 = N(:,k).*cos(theta(k)) + B(:,k).*sin(theta(k)) ;
    th_min    = 0 ;
    min_angle = 1e6 ;
    % compute rotation of frame (T2,N2) in such a way the angle between
    % two consecutive frames is minimized
    FUN = @(th) abs(frame_angle( T1, N1, T2, N(:,k+1).*cos(th) + B(:,k+1).*sin(th) )) ;
    %[theta(k+1),val] = fminbnd( FUN, theta(k)-pi, theta(k)+pi ) ;
    theta(k+1) = fminsearch( FUN, theta(k)) ;
  end

  dangle = 2*pi/ndivangle ; % quantized angle for final frame

  %%% find angle dangle*nstep more close to theta(end)
  nstep  = round( theta(end)/dangle ) ;
  dth    = nstep*dangle - theta(end) ;
  
  %%% move rotation angles to match final angle = nstep*dangle 
  theta = theta+[0:m-1]*(dth/(m-1)) ;

end
%
% compute the angle between the frame (T1,N1) projected to the frame (T2,N2)
%
function angle = frame_angle( T1, N1, T2, N2 )
  % Rotate frame (T1,N1) in such a way rotated(T1) = T2

  V = cross( T1, T2 ) ;
  S = norm( V, 2 ) ;
  C = dot( T1, T2 ) ;

  Vmat = [    0   -V(3)   V(2) ; ...
            V(3)     0   -V(1) ; ...
           -V(2)   V(1)     0 ] ;

  % rotation matrix
  R = eye(3) + Vmat + Vmat^2*(1-C)/S^2 ;

  % rotate first frame
  T1 = R*T1 ;
  N1 = R*N1 ;

  % compute rotation along T2 suche that rotated(N1) = N2
  V = cross( N1, N2 ) ;
  S = dot( V,  T1 ) ;
  C = dot( N1, N2 ) ;

  % return the angle in the range [-pi,pi]
  angle = atan2( S, C ) ;

end
