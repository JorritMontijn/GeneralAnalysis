function dblDeltaPrime = getDeltaPrime(vecResp,vecAngles,boolBiasCorrection)
	%getDeltaPrime Calculates the orientation selectivity metric \(delta)'
	%	dblDeltaPrime = getDeltaPrime(varResp,vecOri)
	%
	%Inputs:
	% - vecResp; [1 x Trial] response vector
	% - vecAngles; [1 x Trial] stimulus orientation vector  [in radians]
	% - boolBiasCorrection; [boolean] logical switch to use bias-correction
	%
	%Note: you can also supply a matrix of responses [Neuron x Trial]
	%instead of a vector, and the function will return a vector of delta'
	%
	%Version History:
	%2019-03-12 Created delta-prime function [by Jorrit Montijn]
	%2019-08-20 Updated version [by JM]
	
	%% check inputs
	status = warning('on');
	%if range(vecAngles) > 2*pi,warning([mfilename 'W:Degs'],'Angles are >2pi, are you sure they are radians?');end
	warning(status);
	if size(vecResp,2) == 1,vecResp = vecResp';end
	if size(vecAngles,2) == 1,vecAngles = vecAngles';end
	if size(vecResp,2) ~= size(vecAngles,2)
		error([mfilename ':WrongInput'],'Response vector and angle vector are not the same length!');
	end
	if ~exist('boolBiasCorrection','var') || isempty(boolBiasCorrection)
		boolBiasCorrection = false;
	end
	
	%% calculate
	[vecOriIdx,vecUniqueOris] = val2idx(vecAngles);
	intReps = numel(vecOriIdx)/numel(vecUniqueOris);
	intNumOri = max(vecOriIdx);
	matDelta2 = nan(intNumOri,intNumOri,size(vecResp,1));
	for intOri1=1:intNumOri
		%get resp for ori 1
		vecRespOri1 = vecResp(:,vecOriIdx==intOri1);
		dblMu1 = nanmean(vecRespOri1,2);
		dblVar1 = nanvar(vecRespOri1,[],2);
		for intOri2=(intOri1+1):intNumOri
			%get resp for ori 1
			vecRespOri2 = vecResp(:,vecOriIdx==intOri2);
			dblMu2 = nanmean(vecRespOri2,2);
			dblVar2 = nanvar(vecRespOri2,[],2);
			
			%calc constituents
			dblDeltaMuNorm = abs(dblMu2 - dblMu1);
			dblVarAvg = ((dblVar1 + dblVar2) / 2);
			
			%calc delta^2
			dblDelta2 = (dblDeltaMuNorm.^2) ./ dblVarAvg;
			matDelta2(intOri1,intOri2,:) = dblDelta2;
			matDelta2(intOri2,intOri1,:) = dblDelta2;
		end
	end
	
	%% transform to d'-like values
	dblDelta2Prime = flat(nanmean(nanmean(matDelta2,1),2));
	if boolBiasCorrection
		%with bias-correction
		dblDelta2Prime = dblDelta2Prime  - (log2(intNumOri))/(intReps^1.5);
		
		%correction for radians
		dblDeltaPrime = sqrt(dblDelta2Prime);
		dblDeltaPrime = (real(dblDeltaPrime) - imag(dblDeltaPrime)) * (pi/2);
	else
		%no bias-correction, correction for radians
		dblDeltaPrime = sqrt(dblDelta2Prime) * (pi/2);
	end
	dblDeltaPrime(isinf(dblDeltaPrime))=nan;
	
end

