function [cellFoldsX,cellFoldsY,cellFoldsShuffledX,cellFoldsShuffledY] = getFolds(intFoldK,matX,matY)
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	
	%% general metadata
	intRepetitions = size(matX,1);
	intNeuronsX = size(matX,2);
	intNeuronsY = size(matY,2);
	intTrialsPerFold = floor(min(intRepetitions)/intFoldK); %take lowest number of repetitions for the two classes, and round down when dividing in equal K-folds
	
	%% build folds
	cellFoldsX = cell(intFoldK,1);
	cellFoldsY = cell(intFoldK,1);
	cellFoldsShuffledX = cell(intFoldK,1);
	cellFoldsShuffledY = cell(intFoldK,1);
	intTrialsxFolds = intFoldK*intTrialsPerFold;
	vecTrialFolds = repmat(1:intFoldK,[1 intTrialsPerFold]);
	vecTrialFolds = vecTrialFolds(randperm(intTrialsxFolds));
	for intFold=1:intFoldK
		vecTrials = find(vecTrialFolds==intFold);
		cellFoldsX{intFold} = matX(vecTrials,:);
		cellFoldsY{intFold} = matY(vecTrials,:);
		
		matFoldShuffX = nan(intTrialsPerFold,intNeuronsX);
		matFoldShuffY = nan(intTrialsPerFold,intNeuronsY);
		for intThisNeuronX=1:intNeuronsX
			vecDataX = matX(vecTrials,intThisNeuronX);
			matFoldShuffX(:,intThisNeuronX) = vecDataX(randperm(intTrialsPerFold));
		end
		for intThisNeuronY=1:intNeuronsY
			vecDataY = matY(vecTrials,intThisNeuronY);
			matFoldShuffY(:,intThisNeuronY) = vecDataY(randperm(intTrialsPerFold));
		end
		cellFoldsShuffledX{intFold} = matFoldShuffX;
		cellFoldsShuffledY{intFold} = matFoldShuffY;
	end
end

