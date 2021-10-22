function [vecPseudoOri,matWhitePseudoData,matPseudoData] = buildPseudoData(cellLabels,cellData)
	%buildPseudoData Builds pseudo data
	%[vecPseudoOri,matWhitePseudoData,matPseudoData] = buildPseudoData(cellLabels,cellData)
	%
	%Input:
	%-cellLabel{i} is a vector with trial labels (e.g., stim orientation) for recording i\
	%-cellData{i} is a matrix of size [Neurons x Trials], where the number of trials must match the
	%number of elements in cellLabel{i}
	%
	%Output:
	%-vecPseudoOri is a vector with labels (# of trials is stim-types x minimum rep-nr)
	%-matWhitePseudoData is a [Neurons x Trials] matrix of concatenated neurons and trial responses
	%shuffled per neuron within the same stimulus type to remove any correlated responses
	%-matPseudoData is the same as above, but simply concated (non-shuffled) responses
	
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