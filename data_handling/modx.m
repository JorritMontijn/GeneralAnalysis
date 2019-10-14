function b = modx(a,m)
	%modx Modulo, where mod(n*m,m) gives m instead of 0
	%   See mod()
	b = mod(a,m);
	if b==0,b=m;end
end

