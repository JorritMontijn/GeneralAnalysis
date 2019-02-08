function parWaitbar(intWorker,intWorkers,intFrac)
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	
	global ptrWaitbar
	if isempty(ptrWaitbar)
		ptrWaitbar = figure;
		set(ptrWaitbar,'Visible','off');
		boolFirst=true;
		fracPrev = 0;
	else
		figure(ptrWaitbar);
		fracPrev=get(ptrWaitbar,'UserData');
		boolFirst=false;
	end

	%update mat
	fracNow = round(intFrac * 100);
	
	%save mat
	set(ptrWaitbar,'UserData',fracNow);
	
	if fracPrev ~= fracNow || boolFirst
		tStamp = fix(clock);
		strPlace = [sprintf('Worker %d/%d: Processing... Now at %d%%',intWorker,intWorkers,fracNow) sprintf(' [%02d:%02d:%02d]', tStamp(4),tStamp(5),tStamp(6))];
		disp(strPlace);
		drawnow;
	end
end

