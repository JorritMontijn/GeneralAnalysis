function [vecPseudoOri,matWhitePseudoData,matPseudoData] = buildPseudoData(cellLabels,cellData)
	%buildPseudoData Builds pseudo data
	%[vecPseudoOri,matWhitePseudoData,matPseudoData] = buildPseudoData(cellLabels,cellData)
	
	%calculate min rep
	intMinRep = inf;
	for intRec=1:numel(cellLabels)
		[varDataOut,vecUnique,vecCounts,cellSelect,vecRepetition] = label2idx(cellLabels{intRec});
		intMinRep = min([intMinRep; vecCounts]);
	end
	
	%build pseudo
	vecPseudoOri = repmat(vecUnique(:),[intMinRep 1]);
	[vecPseudoStimIdx,vecPseudoUnique,vecPseudoCounts,cellPseudoSelect,vecPseudoRepetition] = label2idx(vecPseudoOri);
	intStimNum = numel(vecUnique);
	matPseudoData = nan(0,numel(vecPseudoOri));
	for intRec=1:numel(cellLabels)
		[varDataOut,vecUnique,vecCounts,cellSelect,vecRepetition] = label2idx(cellLabels{intRec});
		matTemp = nan(size(cellData{intRec},1),intMinRep*numel(vecUnique));
		for intRep=1:intMinRep
			vecUseTrials = find(vecRepetition==intRep);
			[dummy,vecReorder] = sort(cellLabels{intRec}(vecUseTrials));
			matTemp(:,(1:intStimNum)+intStimNum*(intRep-1)) = cellData{intRec}(:,vecUseTrials(vecReorder));
		end
		matPseudoData((end+1):(end+size(matTemp,1)),:) = matTemp;
	end
	matPseudoData(range(matPseudoData,2)==0,:) = [];
	
	%randomize repetition per neuron
	matWhitePseudoData = matPseudoData;
	for intNeuron=1:size(matPseudoData,1)
		for intStimType=1:intStimNum
			vecTrialTemp = find(vecPseudoStimIdx==intStimType);
			vecAssignRandIdx = vecTrialTemp(randperm(numel(vecTrialTemp)));
			matWhitePseudoData(intNeuron,vecTrialTemp) = matPseudoData(intNeuron,vecAssignRandIdx);
		end
	end
end