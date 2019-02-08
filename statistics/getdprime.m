function dblDprime = getdprime(dblHitFrac,dblFalseAlarmFrac)
	%getdprime Returns d' for hit/FA rates
	%   dblDprime = getdprime(dblHitFrac,dblFalseAlarmFrac)
	
	dblDprime = norminv(dblHitFrac,0,1) - norminv(dblFalseAlarmFrac,0,1);
end

