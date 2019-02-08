function boolEsc = CheckEsc()
	%CheckEsc Checks if escape button is pressed
	%   boolEsc=any(strcmpi(KbName(keyCode),'escape'));
	KbName('UnifyKeyNames');
	[keyIsDown, secs, keyCode] = KbCheck();
	boolEsc=any(strcmpi(KbName(keyCode),'escape'));
end

