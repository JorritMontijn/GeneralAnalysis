function varargout=tubeplot(curve,r,vecC,intPointsPerRadius,ct)
	% Usage: [x,y,z]=tubeplot(curve,r,vecC,n,ct)
	%
	% Tubeplot constructs a tube, or warped cylinder, along
	% any 3D curve, much like the build in cylinder function.
	% If no output are requested, the tube is plotted.
	% Otherwise, you can plot by using surf(x,y,z);
	%
	% Example of use:
	% t=linspace(0,2*pi,50);
	% tubeplot([cos(t);sin(t);0.2*(t-pi).^2],0.1);
	% daspect([1,1,1]); camlight;
	%
	% Arguments:
	% curve: [3,N] vector of curve data
	% r      the radius of the tube
	% n      number of points to use on circumference. Defaults to 8
	% ct     threshold for collapsing points. Defaults to r/2
	%
	% The algorithms fails if you have bends beyond 90 degrees.
	% Janus H. Wesenberg, july 2004
	%
	% Edited by Jorrit Montijn to allow plotting of non-uniform widths
	
	if nargin<4 || isempty(intPointsPerRadius), intPointsPerRadius=8;
		if nargin<2, error('Give at least curve and radius');
		end;
	end;
	if size(curve,1)~=3
		error('Malformed curve: should be [3,N]');
	end;
	if nargin<5 || isempty(ct)
		ct=0.5*r;
	end
	
	if isscalar(r)
		r = r*ones(1,size(curve,2));
	end
	if isscalar(ct)
		ct = ct*ones(1,size(curve,2));
	end
	if nargin < 3 || isempty(vecC),vecC=1;end
	if isscalar(vecC)
		vecC = vecC*ones(1,size(curve,2));
	end
	
	%Collapse points within 0.5 r of each other [creates errors when creating closed tubes]
	npoints=1;
	for k=2:(size(curve,2)-1)
		if 1;%norm(curve(:,k)-curve(:,npoints))>ct(k);
			npoints=npoints+1;
			curve(:,npoints)=curve(:,k);
			r(npoints)=r(k);
			if ~isempty(vecC),vecC(npoints)=vecC(k);end
			ct(npoints)=ct(k);
		end
	end
	
	
	%Always include endpoint
	if norm(curve(:,end)-curve(:,npoints))>0
		npoints=npoints+1;
		curve(:,npoints)=curve(:,end);
		r(npoints)=r(end);
		if ~isempty(vecC),vecC(npoints)=vecC(end);end
		ct(npoints)=ct(end);
	end
	
	%deltavecs: average for internal points.
	%           first strecth for endpoitns.
	dv=curve(:,[2:end,end])-curve(:,[1,1:end-1]);
	
	%make nvec not parallel to dv(:,1)
	nvec=zeros(3,1);
	[buf,idx]=min(abs(dv(:,1))); nvec(idx)=1;
	
	xyz=repmat([0],[3,intPointsPerRadius+1,npoints+2]);
	c = zeros(1,npoints+2);
	c(2:(npoints+1)) = vecC(1:npoints);
	%precalculate cos and sing factors:
	cfact=repmat(cos(linspace(0,2*pi,intPointsPerRadius+1)),[3,1]);
	sfact=repmat(sin(linspace(0,2*pi,intPointsPerRadius+1)),[3,1]);
	
	%Main loop: propagate the normal (nvec) along the tube
	for k=1:npoints
		convec=cross(nvec,dv(:,k));
		convec=convec./norm(convec);
		nvec=cross(dv(:,k),convec);
		nvec=nvec./norm(nvec);
		%update xyz:
		xyz(:,:,k+1)=repmat(curve(:,k),[1,intPointsPerRadius+1])+...
			cfact.*repmat(r(k)*nvec,[1,intPointsPerRadius+1])...
			+sfact.*repmat(r(k)*convec,[1,intPointsPerRadius+1]);
	end;
	
	%finally, cap the ends:
	xyz(:,:,1)=repmat(curve(:,1),[1,intPointsPerRadius+1]);
	xyz(:,:,end)=repmat(curve(:,end),[1,intPointsPerRadius+1]);
	c(1) = vecC(1);
	c(end) = vecC(npoints);
	
	%,extract results:
	x=squeeze(xyz(1,:,:));
	y=squeeze(xyz(2,:,:));
	z=squeeze(xyz(3,:,:));
	if isempty(vecC)
		c = [];
	end
	c = repmat(c,[intPointsPerRadius+1 1]);
	
	%... and plot:
	if nargout == 0
		surf(x,y,z);
	elseif nargout == 1
		if isempty(c)
			varargout{1} = surf(x,y,z);
		else
			varargout{1} = surf(x,y,z,c);
		end
	elseif nargout == 3
		varargout{1} = x;
		varargout{2} = y;
		varargout{3} = z;
	elseif nargout > 3
		if isempty(c)
			varargout{1} = surf(x,y,z);
		else
			varargout{1} = surf(x,y,z,c);
		end
		varargout{2} = x;
		varargout{3} = y;
		varargout{4} = z;
		varargout{5} = c;
	end
end