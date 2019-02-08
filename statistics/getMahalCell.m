function vecMahal=getMahalCell(cellXY,matThisCovInv)
	%UNTITLED8 Summary of this function goes here
	%   Detailed explanation goes here
	
	%get number of trials
	vecMahal = cellfun(@calcMahal,cellXY);
	function dblMahal=calcMahal(vecXY)
		dblMahal = vecXY * matThisCovInv * vecXY';
	end
end
