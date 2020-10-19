function UpdateWaitbar(~)
	%UpdateWaitbar Updates waitbar for (parfor) loop
	%
	%put the following before the parfor looping over i=1:n
	%	global intWaitbarTotal;
	%	intWaitbarTotal = n;
	%	ptrProgress = parallel.pool.DataQueue;
	%	afterEach(ptrProgress, @UpdateWaitbar);
	%
	%then put the following within the parfor loop
	%	send(ptrProgress, i);
	%
	%Version History
	%2020-10-16 Created by Jorrit Montijn

	global intWaitbarCounter;
	global intWaitbarTotal;
	global ptrWaitbarHandle;
	if ~exist('ptrWaitbarHandle','var') || isempty(ptrWaitbarHandle)
		ptrWaitbarHandle = waitbar(0, 'Please wait ...');
	end
	if ~exist('intWaitbarCounter','var') || isempty(intWaitbarCounter)
		intWaitbarCounter = 0;
	end
	waitbar(intWaitbarCounter/intWaitbarTotal, ptrWaitbarHandle,sprintf('Please wait ... Finished %d/%d',intWaitbarCounter,intWaitbarTotal));
	intWaitbarCounter = intWaitbarCounter + 1;
	if intWaitbarCounter == intWaitbarTotal
		delete(ptrWaitbarHandle);
	end
end