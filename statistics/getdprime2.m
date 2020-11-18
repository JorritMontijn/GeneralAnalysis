function dPrime = getdprime2(vecIn1,vecIn2)
	dPrime = (mean(vecIn1) - mean(vecIn2))/sqrt(0.5*(var(vecIn1)+var(vecIn2)));
end