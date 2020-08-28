function boolEsc = CheckEsc()
	%CheckEsc Checks if escape button is pressed
	%   boolEsc=any(strcmpi(KbName(keyCode),'escape'));
	
	%check if psychtoolbox is installed
	if exist('KbName','file')
		KbName('UnifyKeyNames');
		[keyIsDown, secs, keyCode] = KbCheck();
		boolEsc=any(strcmpi(KbName(keyCode),'escape'));
	else
		%otherwise use Mario Koddenbrock's way
		boolEsc = getAsyncKeyState(VirtualKeyCode.VK_ESCAPE);
	end
end

