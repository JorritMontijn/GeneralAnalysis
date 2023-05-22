function [vecZscore,vecAvgFiltered,vecStdFiltered] = detectpeaks(y,lag,threshold,influence,intSwitchOldNew)
	%https://stackoverflow.com/questions/22583391/peak-signal-detection-in-realtime-timeseries-data/22640362#22640362
	
	if ~exist('intSwitchOldNew','var')
		intSwitchOldNew = 1;
	end
	
	%check orientation
	assert(isvector(y),[mfilename ':InputNotVector'],'Time-series input is not a one-dimensional vector');
	assert(mod(lag,2)==1,[mfilename ':InputNotOdd'],'Lag parameter is not an odd integer');
	if size(y,1) < size(y,2),y=y';end
	
	if intSwitchOldNew == 1
		%% new algorithm: faster and time-symmetric
		%calc avg
		intCenter = ceil(lag/2);
		vecFilt = ones(lag,1);
		vecFilt(intCenter) = 0;
		vecFilt=vecFilt./sum(vecFilt);
		vecSmoothed = imfilt(y,vecFilt);
		
		%influence
		dblMu = mean(vecSmoothed);
		vecFiltInf(:) = (1-influence)/(lag-1);
		vecFiltInf(intCenter) = influence;
		vecAvgFiltered = dblMu*(1-influence) + influence*imfilt(vecSmoothed,vecFiltInf);
		
		%std
		vecDev = bsxfun(@minus,y,vecAvgFiltered);
		vecDev2 = vecDev.^2;
		dblSd = sqrt(sum(vecDev2)./(numel(vecDev2)-1));
		vecStdFiltered = dblSd*(1-influence) + influence*(sqrt(imfilt(vecDev2,ones(lag,1))./(lag-1)));
		
		%z
		vecZscore = vecDev./vecStdFiltered;
	else
		%% old algorithm
		% Initialise signal results
		signals = zeros(length(y),1);
		% Initialise filtered series
		filteredY = y(1:lag+1);
		% Initialise filters
		vecAvgFiltered = 0;
		vecStdFiltered = 0;
		vecAvgFiltered(lag+1,1) = mean(y(1:lag+1));
		vecStdFiltered(lag+1,1) = std(y(1:lag+1));
		% Loop over all datapoints y(lag+2),...,y(t)
		for i=lag+2:length(y)
			% If new value is a specified number of deviations away
			if abs(y(i)-vecAvgFiltered(i-1)) > threshold*vecStdFiltered(i-1)
				if y(i) > vecAvgFiltered(i-1)
					% Positive signal
					signals(i) = 1;
				else
					% Negative signal
					signals(i) = -1;
				end
				% Make influence lower
				filteredY(i) = influence*y(i)+(1-influence)*filteredY(i-1);
			else
				% No signal
				signals(i) = 0;
				filteredY(i) = y(i);
			end
			% Adjust the filters
			vecAvgFiltered(i) = mean(filteredY(i-lag:i));
			vecStdFiltered(i) = std(filteredY(i-lag:i));
		end
		% Done, now return results
		vecZscore = (y-vecAvgFiltered)./vecStdFiltered;
		vecZscore(isinf(vecZscore))=0;
	end
end