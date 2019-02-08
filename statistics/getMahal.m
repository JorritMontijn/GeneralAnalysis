function vecMahal=getMahal(matThisData,vecMu,matThisCovInv)
	%UNTITLED8 Summary of this function goes here
	%   Detailed explanation goes here
	
	%get number of trials
	intTrials=size(matThisData,1);
	
	
	%loop is faster....
	vecMahal=nan(1,intTrials);
	for intTrial = 1:intTrials %can be used as parfor
		vecXY = (matThisData(intTrial,:)-vecMu);
		vecMahal(intTrial) = vecXY * matThisCovInv * vecXY';
	end
	vecMahal = sqrt(vecMahal);
	
	%{
	%% vectorization is actually slower....
	tic
	matXY=bsxfun(@minus,matThisData,vecMu);
	cellXY=mat2cell(matXY,ones(1,intTrials),size(matXY,2));
	vecMahal = cellfun(@calcMahal,cellXY);
	toc
	function dblMahal=calcMahal(vecXY)
		dblMahal = vecXY * matThisCovInv * vecXY';
	end
	%}
end
