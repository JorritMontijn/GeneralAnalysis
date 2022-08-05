function ptrWaitbarHandleLocal = UpdateWaitbar(~)
	%UpdateWaitbar Updates waitbar for (parfor) loop once per second
	%   ptrWaitbarHandle = UpdateWaitbar(~)
	%
	%for a parfor looping over i=1:n, put the following before the loop:
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
	global ptrWaitbarTic;
	global intWaitbarTotal;
	global ptrWaitbarHandle;
	
	if ~exist('ptrWaitbarHandle','var') || isempty(ptrWaitbarHandle) || ~isvalid(ptrWaitbarHandle)
		ptrWaitbarHandle = waitbar(0, 'Please wait ...');
		intWaitbarCounter = 0;
	end
	if ~exist('intWaitbarCounter','var') || isempty(intWaitbarCounter)
		intWaitbarCounter = 0;
	end
	if isempty(ptrWaitbarTic) || toc(ptrWaitbarTic) > 1
		ptrWaitbarTic = tic;
		waitbar(intWaitbarCounter/intWaitbarTotal, ptrWaitbarHandle,sprintf('Please wait ... Finished %d/%d',intWaitbarCounter,intWaitbarTotal));
	end
	intWaitbarCounter = intWaitbarCounter + 1;
	if intWaitbarCounter == intWaitbarTotal
		delete(ptrWaitbarHandle);
		intWaitbarCounter = 0;
	end
	ptrWaitbarHandleLocal = ptrWaitbarHandle;
end