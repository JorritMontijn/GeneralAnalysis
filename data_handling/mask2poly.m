function poly=mask2poly(mask,countourType,sortPointsMethod)
	%% function poly=mask2poly(mask)
	% Finds a polygon enclosing the user defind mask of logicals. Kind of a
	%  reverse/complementary of Matlab poly2mask function.
	%
	%% Syntax
	% poly=mask2poly(mask);
	% poly=mask2poly(mask,countourType);
	% poly=mask2poly(mask,countourType,sortPointsMethod);
	%
	%% Description
	% This functions goal is to find a poligon which enclosures a user supplied mask. It's a
	%  kind of a complementary of Matlab poly2mask function. The difference is that all
	%  contour points are returned- wihout missing points for linearly related points. In
	%  order to get a 100% complementary of poly2mask all points inside straight lines shoud
	%  be ommited. In my case I actually need all those points, as indexs of ROI.
	%  Combinng mask2poly with poly2mask the user can produce a mask from a contour (line with
	%  X and Y coordinates), and vise-versa.
	%
	%% Input arguments:
	% mask- two dimentional matrix of numbers (all numeric types are supported, though mask is
	%  usally a matix of logicals).
	%
	% countourType- {['Inner'],'Outer','Exact'} a string describing the desired contour type.
	%  'Inner' (default) will result in a contour inside the mask- the largest shape included
	%     by the mask.
	%  'Outer' will result in a contour ouside the mask- the smallest shape including by the
	%     mask.
	%  'Exact' option will result in a contour between 'Inner' and 'Outer', and it lies
	%     exactly on the mask margins.
	% Both 'Outer' and 'Inner' results are integers, ready to be used for indexing.
	% so it can be used for indexing, as oposed to 'Exact' results which are doubles, and
	% cannot be used for indexing.
	%
	% sortPointsMethod- two methds are currently implemented:
	%  'CW'- Clock Wise- an efficinet and fast, but can create "saw tooth" shaped contour.
	%  'MINDIST'- minimal siatnce between points- will usally result in a better contour,
	%     without "saw tooth" shaped contour. but the price to pay is ~X20 times slower run
	%     time.
	% other value of sortPointsMethod will skip sorting points.
	%
	%% Output arguments
	% poly- Two dimentional [N,2] matirx with coordinates of all points of the contour. Each
	%  point is described by an appropriate row. X is described by the first column, Y by the
	%  second.
	%
	%% Issues & Comments (None)
	%
	%% Example
	% x = [76    51    82    97   118   167   180   145   113    92  76];
	% y = [41    73   115    80   143   173   120    57    40    33  41];
	% mask = poly2mask(x,y,200,200);
	% figure;
	% imshow(mask);
	% hold on;
	% poly=mask2poly(mask,'Inner','CW');
	% plot(poly(:,1),poly(:,2),'v-g','MarkerSize',9,'LineWidth',4);
	% poly=mask2poly(mask,'Inner','MinDist');
	% plot(poly(:,1),poly(:,2),'s-k','MarkerSize',12,'LineWidth',2);
	% poly=mask2poly(mask,'Outer');
	% plot(poly(:,1),poly(:,2),'*m','MarkerSize',9);
	% poly=mask2poly(mask,'Exact');
	% plot(poly(:,1),poly(:,2),'.r','MarkerSize',18);
	%
	% plot(x,y,'O-b','MarkerSize',12,'LineWidth',3);
	% hold off;
	% legend('mask2poly- Inner- CCW','mask2poly- Inner- MinDist','mask2poly- Outer','mask2poly- Exact','poly2mask');
	% title('mask2poly Vs. poly2mask','FontSize',14);
	%
	%% See also
	% poly2mask;            % Matlab function
	% imrect;               % Matlab function
	% imroi;                % Matlab function
	% sortPoint2ContourCW   % Custom function
	% sortPointMinDist      % Custom function
	%
	%% Revision history
	% First version: Nikolay S. 2011-07-07.
	% Last update:   Nikolay S. 2011-07-25.
	%
	% *List of Changes:*
	%   ------------------2011-07-25-------------------------
	% - Ordering points accourding to rule of "nearest point" (acurate but slow) added.
	%   ------------------2011-07-14-------------------------
	% - An option to reorder the points so it will define a CW contour.
	%   ------------------2011-07-13-------------------------
	% - "Inner" and "Outer" options replaced isIndex option
	% - Diff based edges calculation replaced contour based calculation for "Inner" and
	%  "Outer" options, which resulted in ~x3 shorter run time.
	%
	if nargin<3
		sortPointsMethod='None';
		if nargin<2
			countourType='Inner'; %{'Inner','Outer','Exact'}
		end
	end
	%% Pad mask to deal with edges on contours
	paddedMask=false(2+size(mask));
	paddedMask(1+(1:size(mask,1)),1+(1:size(mask,2)),:)=mask;
	doubleMask=double(paddedMask);
	countourType=upper(countourType);
	switch (countourType)
		case({'INNER','OUTER'})
			%% Caculate via Gradient fast but up-to indesx exact
			maskEdges=abs(doubleMask-circshift(doubleMask,[1,0,0]))+...
				abs(doubleMask-circshift(doubleMask,[0,1,0]))+...
				abs(doubleMask-circshift(doubleMask,[-1,0,0]))+...
				abs(doubleMask-circshift(doubleMask,[0,-1,0]));
			if strcmpi(countourType,'OUTER')
				paddedMask=~paddedMask; % Outer edges mark
			end
			[edgeRows,edgeCols]=find(maskEdges>0 & paddedMask);
			maskContours=cat(2,edgeCols,edgeRows);
			
			switch(upper(sortPointsMethod))
				case('CW')
					[xCW,yCW]=sortPoint2ContourCW(maskContours(:,1),maskContours(:,2));
					maskContours=cat(2,xCW,yCW);
				case('MINDIST')
					[xCW,yCW]=sortPointMinDist(maskContours(:,1),maskContours(:,2));
					maskContours=cat(2,xCW,yCW);
			end % switch(upper(sortPointsMethod))
			
		otherwise
			%% Caculate via contour- slow yet accurate and easy to implement
			contourTresh=0.5*max(doubleMask(:));
			maskContours=contourc(doubleMask,[contourTresh,contourTresh]);
			maskContours=transpose(maskContours); % Convert to standart Pos coordinates system
	end
	%% Fix the inacurities caused by padding
	maskContours=maskContours-1;
	poly=maskContours;
end
function [xCW,yCW]=sortPoint2ContourCW(x,y)
	%% function [xCW,yCW]=sortPoint2ContourCW(x,y)
	% Sorts arbitrary points into a Clock Wise direction contour.
	%
	%% Syntax
	% [xCW,yCW]=sortPoint2ContourCW(x,y)
	%
	%% Description
	% This functions goal is to order points in a clockwise order efficintly. While this
	% problem can be hard to solve, and even sometimes considered unsolvable, it is solved
	% here basing on the assumption that "nearest point in Clock Wise direction" is the point
	% found after sorting by X values, and finding nearest point in Y. This results in a
	% solution of O(N^2) complexity, but im most cases it will be of significantly lower
	% complexity.
	%
	%% Input arguments:
	% x- x coordinates of the points
	%
	% y- x coordinates of the points
	%
	%% Output arguments
	% xCW- sorted points (so a CW contour will be created) x coordinates.
	%
	% yCW- sorted points (so a CW contour will be created) y coordinates.
	%
	%% Issues & Comments (None)
	% The resulting shape will have points connected,accordung to a predfined metric, so it
	% will not always result in a shape user wished for. Add additonal points to fix this
	% issue, when needed.
	% To avoid "saw toothe coming from neighbouring poinst, comment out the while loop lines
	% 77-86. This will also improve run time, but will be less accurate.
	%
	%% Example
	% N=11;
	% x=10*rand(1,N);
	% y=10*rand(1,N);
	% [xCW,yCW]=sortPoint2ContourCW(x,y);
	% figure;
	% plot(x,y,'.-b');
	% hold on;
	% plot(xCW,yCW,'.-r','LineWidth',2);
	% hold off;
	% title('Sorting arbitrary Points into Clock Wise Contour','FontSize',14);
	% legend('Unsorted points contour', 'Sorted points contour');
	%
	%% See also
	% poly2mask;	% Matlab function
	% convhull;    % Matlab function
	% mask2poly;   % Custom function
	%
	%% Revision history
	% First version: Nikolay S. 2011-07-14.
	% Last update:   Nikolay S. 2011-07-17.
	%
	% *List of Changes:*
	% - Sort is performed only if x is unsorted.
	%% convert to column vectors and sort
	x=x(:);
	y=y(:);
	if ~issorted(x)
		[x,ix]=sort(x);
		y=y(ix);
	end
	% as we have sorted inputs for ascending X values, so we will work on Y in order to achive
	% Clock Wise contour
	%% Initial points attribution
	diffY=diff(cat(1,y(1),y));
	isIncY=diffY>1;         % find points where Y values Increase by more than 1
	isNeigh=abs(diffY)<=1;  % find points where Y values change by 1/0- neighbouring points
	isDecY=diffY<-1;        % find points where Y values Decrease by more than 1
	isUndeterminedY=~(isIncY|isDecY); % find poits not set to be Increasing or Decreasing
	%% Determine each point to be either Increasing or Decreasing
	while sum(double(isUndeterminedY))>2
		% a point is Increasing if it is a neigbour of an Increasing point
		isIncreasingNeig=isNeigh&circshift(isIncY,+1);
		isIncY=isIncY|isIncreasingNeig;
		% a point is Decreasing if it is a neigbour of an Decreasing point
		isDecNeig=isNeigh&circshift(isDecY,+1);
		isDecY=isDecY|isDecNeig;
		isUndeterminedY=~(isIncY|isDecY);
	end
	xCW=cat(1,x(isIncY),flipud(x(isDecY)));
	yCW=cat(1,y(isIncY),flipud(y(isDecY)));
end
function [xDistSort,yDistSort]=sortPointMinDist(x,y)
	%% function [xDistSort,yDistSort]=sortPointMinDist(x,y)
	% Sorts arbitrary points into a Clock Wise contour.
	%
	%% Syntax
	% [xDistSort,yDistSort]=sortPointMinDist(x,y)
	%
	%% Description
	% This functions goal is to order points efficintly to allow plotting a contoure with
	% them. While this problem can be hard to solve, and even sometimes considered unsolvable,
	% it is solved here basing on the assumption that "nearest point" is the nect point. This
	% results in a solution of O(N^2) complexity (calculating all distamnces between points),
	% but im most cases it will be of significantly lower complexity.
	%
	%% Input arguments:
	% x- x coordinates of the points
	%
	% y- x coordinates of the points
	%
	%% Output arguments
	% xDistSort- sorted points x coordinates.
	%
	% yDistSort- sorted points y coordinates.
	%
	%% Issues & Comments (None)
	% The resulting shape will have points connected,accordung to a predfined metric, so it
	% will not always result in a shape user wished for. Add additonal points to fix this
	% issue, when needed.
	% The funciton is pretty damandig computationally (~20 slower than sortPoint2ContourCW),
	% so should be used not too frequently.
	%
	%% Example
	% N=11;
	% x=10*rand(1,N);
	% y=10*rand(1,N);
	% [xCW,yCW]=sortPointMinDist(x,y);
	% figure;
	% plot(x,y,'.-b');
	% hold on;
	% plot(xCW,yCW,'.-r','LineWidth',2);
	% hold off;
	% axis equal;
	% title('Sorting arbitrary Points to form a Contour','FontSize',14);
	% legend('Unsorted points contour', 'Sorted points contour');
	%
	%% See also
	% sortPoint2ContourCW;  % Custom function
	% mask2poly;            % Custom function
	% poly2mask;            % Matlab function
	%
	%% Revision history
	% First version: Nikolay S. 2011-07-24.
	% Last update:   Nikolay S. 2011-07-25.
	%
	% *List of Changes:*
	%
	%% convert to column vectors and sort
	nPoints=length(x);
	iDistSort=zeros(1,nPoints);
	distMat=Inf(nPoints,nPoints); % col index- distance from, row index- distance to
	for iDistRow=1:nPoints
		ind2=(iDistRow+1):nPoints;
		distMat(iDistRow, ind2)=sqrt((x(ind2)-x(iDistRow)).^2+(y(ind2)-y(iDistRow)).^2);
		% distance between a->b eqauls distance between b->a
		distMat(ind2, iDistRow)=transpose(distMat(iDistRow, ind2));
	end
	% find pair of closest points- first and second points
	[~,pointLinInd] = min(distMat(:));
	[iDistSort(1),nextPoint] = ind2sub(size(distMat), pointLinInd);
	for iPoint=1:nPoints-1
		currPoint=nextPoint;
		[minDist,nextPoint] = min(distMat(currPoint, :)); % find next point- closest to current
		distMat(currPoint,:)=Inf; % delete distances from current point
		distMat(:,currPoint)=Inf; % delete distances to   current point
		iDistSort(iPoint+1)=nextPoint; % store sorted points indexes
		
		if isinf(minDist) % this will b true in case of an error
			break;
		end
	end
	xDistSort=x(iDistSort);
	yDistSort=y(iDistSort);
end