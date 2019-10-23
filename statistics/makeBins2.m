function [matCounts,matValMeans,matValSDs,cellVals,cellIDs] = makeBins2(vecValsX,vecValsY,vecValsZ,vecEdgesX,vecEdgesY)
	%makeBins2 Builds 2D binned matrix of vector Z by edges in vectors X and Y
	%   syntax: [matCounts,matValMeans,matValSDs,cellVals,cellIDs] = ...
	%				makeBins2(vecValsX,vecValsY,vecValsZ,vecEdgesX,vecEdgesY)
	%	This function bins values in Z on the x&y axes (the values in
	%	vecValsX/vecValsY) and returns the number (matCounts), mean
	%	(matValMeans) and standard deviation (matValSDs) of the values per
	%	bin based on their corresponding values in vecY. If you simply want
	%	to count the number of values inside a certain bin based on two
	%	binning vectors, you can use the Matlab function histcounts2() 
	%	input:
	%	- vecValsX: [1 x O] vector containing data on the first binning-axis
	%	- vecValsY: [1 x O] vector containing data on the second binning-axis
	%	- vecValsZ: [1 x O] vector containing the values to be binned
	%	- vecEdgesX: [1 x N] vector containing binning edges for first axis
	%	- vecEdgesY: [1 x P] vector containing binning edges for second axis
	%	output:
	%	- matCounts: [N-1 x P-1] matrix, number of Z values per bin
	%	- matValMeans: [N-1 x P-1] matrix, mean of Z values per bin
	%	- matValSDs: [N-1 x P-1] matrix, standard deviation of Z values per bin
	%	- cellVals: [N-1 x P-1] cell-array with vector of values per bin
	%	- cellIDs: [N-1 x P-1] cell-array with selection vector per bin
	%
	%	Version history:
	%	1.0 - July 12 2019
	%	Created by Jorrit Montijn, based on makeBins()
	
	%% pre-alloc
	intValNumX = (numel(vecEdgesX)-1);
	intValNumY = (numel(vecEdgesY)-1);
	matCounts = zeros(intValNumY,intValNumX);
	matValMeans = zeros(intValNumY,intValNumX);
	matValSDs = zeros(intValNumY,intValNumX);
	cellVals = cell(intValNumY,intValNumX);
	cellIDs = cell(intValNumY,intValNumX);
	ptrTic = tic;
	%% run
	for intEdgeX=1:intValNumX
		dblStartEdgeX = vecEdgesX(intEdgeX);
		dblStopEdgeX = vecEdgesX(intEdgeX+1);
		%pre-select X bin
		indTheseValsX = vecValsX > dblStartEdgeX & vecValsX < dblStopEdgeX;
		vecTheseX = vecValsX(indTheseValsX);
		vecTheseY = vecValsY(indTheseValsX);
		vecTheseZ = vecValsZ(indTheseValsX);
		
		for intEdgeY=1:intValNumY
			dblStartEdgeY = vecEdgesY(intEdgeY);
			dblStopEdgeY = vecEdgesY(intEdgeY+1);
			
			%get values for bin
			indTheseValsXY = vecTheseY > dblStartEdgeY & vecTheseY < dblStopEdgeY;
			vecTheseZValsXY = vecTheseZ(indTheseValsXY);
			
			%assign
			matCounts(intEdgeY,intEdgeX) = sum(indTheseValsXY);
			matValMeans(intEdgeY,intEdgeX) = mean(vecTheseZValsXY);
			if nargout > 2,matValSDs(intEdgeY,intEdgeX) = std(vecTheseZValsXY);end
			if nargout > 3,cellVals{intEdgeY,intEdgeX} = vecTheseZValsXY;end
			if nargout > 4,cellIDs{intEdgeY,intEdgeX} =  find(vecValsX > dblStartEdgeX & vecValsX < dblStopEdgeX & vecValsY > dblStartEdgeY & vecValsY < dblStopEdgeY);end
			
			%msg
			if toc(ptrTic) > 5
				fprintf('Binning... Now at bin X=%d/%d, Y=%d/%d [%s]\n',intEdgeX,intValNumX,intEdgeY,intValNumY,getTime);
				ptrTic = tic;
			end
		end
	end
end