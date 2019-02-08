function boolEnter = CheckEnter()
	%CheckEnter Checks if escape button is pressed
	%   boolEnter=any(strcmpi(KbName(keyCode),'escape'));
	KbName('UnifyKeyNames');
	[keyIsDown, secs, keyCode] = KbCheck();
	boolEnter=any(strcmpi(KbName(keyCode),'return'));
end

