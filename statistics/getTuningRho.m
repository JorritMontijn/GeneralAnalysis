function [vecRho,vecP] = getTuningRho(vecResp,vecAngles,boolPlot)
	%getTuningRho Calculates the tuning curve smoothness metric rho
	%	[vecRho,vecP] = getTuningRho(vecResp,vecAngles)
	%
	%Inputs:
	% - vecResp; [1 x Trial] response vector
	% - vecAngles; [1 x Trial] stimulus orientation vector  [in radians]
	%
	%Note: you can also supply a matrix of responses [Neuron x Trial]
	%instead of a vector, and the function will return a vector of rho
	%
	%Version History:
	%2019-04-12 Created tuning rho function [by Jorrit Montijn]
	
	
	%% check inputs
	if ~exist('boolPlot','var') || isempty(boolPlot),boolPlot=false;end
	if size(vecResp,2) == 1,vecResp = vecResp';end
	if size(vecAngles,2) == 1,vecAngles = vecAngles';end
	if size(vecResp,2) ~= size(vecAngles,2)
		error([mfilename ':WrongInput'],'Response vector and angle vector are not the same length!');
	end
	if range(vecAngles) > 2*pi || range(vecAngles) <= pi
		error([mfilename ':WrongInput'],'vecAngles is not in radians, or does not cover the unit circle');
	end
	
	%% calculate
	vecResp = bsxfun(@minus,vecResp,min(vecResp,[],2));
	[vecOriIdx,vecUniqueOris] = label2idx(vecAngles);
	intNumN = size(vecResp,1);
	intNumOri = max(vecOriIdx);
	intCombs = (intNumOri*(intNumOri-1))/2;
	matDeltaR = nan(intCombs,intNumN);
	matDeltaF = nan(intCombs,intNumN);
	intComb=0;
	for intOri1=1:intNumOri
		%get resp for ori 1
		vecRespOri1 = vecResp(:,vecOriIdx==intOri1);
		dblR1 = nanmean(vecRespOri1,2);
		dblF1 = vecUniqueOris(intOri1);
		for intOri2=(intOri1+1):intNumOri
			%get resp for ori 1
			vecRespOri2 = vecResp(:,vecOriIdx==intOri2);
			dblR2 = nanmean(vecRespOri2,2);
			dblF2 = vecUniqueOris(intOri2);
			dblDF = abs(circ_dist(dblF1,dblF2));
			dblDR = abs(dblR1 - dblR2);
			
			%calc lambda
			intComb=intComb+1;
			matDeltaR(intComb,:) = dblDR;
			matDeltaF(intComb,:) = dblDF;
		end
	end
	
%% calc rho
vecRho = nan(intNumN,1);
vecP = nan(intNumN,1);

for intN=1:intNumN
	%get delta Fs
	dblMaxDeltaF = max(matDeltaF(:,intN));
	vecDF = matDeltaF(:,intN)/dblMaxDeltaF;
	vecDF = roundi(vecDF,9)*dblMaxDeltaF;
	[vecUnIdx,vecUnique] = label2idx(vecDF);
	intUniques = numel(vecUnique);
	vecMedianR = nan(1,intUniques);
	vecMaxR = nan(1,intUniques);
	for intUnIdx=1:intUniques
		vecUseR = vecUnIdx ==intUnIdx;
		vecMedianR(intUnIdx) = median(matDeltaR(vecUseR,intN));
		vecMaxR(intUnIdx) = max(matDeltaR(vecUseR,intN));
	end
	dblScale = mean(vecMedianR ./ vecMaxR);

	%correlation
	[dblR,dblP] = bcdistcorr2(vecUnique(:),vecMedianR(:));
	dblRho = dblR*dblScale;
	vecRho(intN) = dblRho;
	vecP(intN) = dblP;
		
		%plot
		if boolPlot && intN == 1
			figure
			subplot(2,2,1)
			vecUniqAng = sort(unique(vecAngles),'ascend');
			dblStepA = mean(diff(vecUniqAng));
			vecEdgeA = [vecUniqAng(1)-dblStepA/2 vecUniqAng+dblStepA/2];
			vecEdgeR = [-2:1:(max(vecResp(intN,:))+2)];
			[matCounts] = histcounts2(vecResp(intN,:),vecAngles,vecEdgeR,vecEdgeA);
			matCounts = conv2(matCounts,normpdf(-2:2,0,1)'/sum(normpdf(-2:2,0,1)));
			matCounts = matCounts(5:(end-4),:);
			imagesc(rad2deg(vecUniqAng)/2,0.5:(max(vecResp(intN,:))),matCounts);axis xy;
			colormap(hot);colorbar;
			title('Density (trial count)');
			xlabel('Stimulus orientation (deg)')
			ylabel('Mean spiking rate (Hz)');
			fixfig;
			grid off;
			
			subplot(2,2,2)
			scatter(rad2deg(vecUnique)/2,vecMedianR)
			hold on
			scatter(rad2deg(vecUnique)/2,vecMaxR)
			hold off
			xlabel('Circular distance (deg)')
			ylabel('Response difference (|\deltaHz|)')
			title(sprintf('Dist-r over trial pairs: p=%.3f, r=%.3f, scale=%.3f, %s=%.3f',dblP, dblR,dblScale,'\rho',dblRho));
			fixfig;
			%xlim([0 90])
		end
	end
end