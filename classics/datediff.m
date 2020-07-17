function dblDateDiff = datediff(strDate1,strDate2)
	%datediff Calculates difference in days between two dates. Syntax:
	%dblDateDiff = datediff(strDate1,strDate2)
	%
	%dblDateDiff = etime(datevec(strDate1),datevec(strDate2))/(60*60*24);
	dblDateDiff = etime(datevec(strDate1),datevec(strDate2))/(60*60*24);
end

