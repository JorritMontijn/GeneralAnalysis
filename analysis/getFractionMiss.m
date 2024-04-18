function [fracMissGauss,binsGauss,spikeCountsGauss,gaussCutoff] = getFractionMiss(amplitudes,nBins,makePlot)
% April 2024, RH based on bombcell's bc_percSpikesMissing()
% estimate fraction of missing spikes

amplitudes = double(amplitudes(:)');

%prep
if ~exist('nBins','var') || isempty(nBins)
    nBins = 50; 
end
if ~exist('makePlot','var') || isempty(makePlot)
    makePlot = false;
end

%make amplitude histogram
[spikeCounts,binEdges] = histcounts(amplitudes,nBins);
binSize = mean(diff(binEdges));

%get mode of hist
[~,indMaxAmp] = max(spikeCounts);
modeSeed = binEdges(indMaxAmp);
if numel(modeSeed) > 1
    modeSeed = mean(modeSeed);
end

% %% SYMMETRIC (currently not used)
% %mirror amplitudes
% spikeCountsSmooth = smoothdata(spikeCounts,'movmedian',5);
% [~,indMaxAmpSmooth] = max(spikeCountsSmooth);
% 
% surrogateCounts = [spikeCountsSmooth(end:-1:indMaxAmpSmooth),fliplr(spikeCountsSmooth(end:-1:indMaxAmpSmooth+1))];
% surrogateBins = [fliplr(binEdges(indMaxAmpSmooth)-binSize:-binSize:binEdges(indMaxAmpSmooth)-...
%     binSize*floor(size(surrogateCounts,2)/2)),binEdges(indMaxAmp)];
% 
% %remove bins with amp < 0
% indRem = surrogateBins<0;
% surrogateCounts(indRem) = [];
% % surrogateBins(indRem) = [];
% surrogateArea = sum(surrogateCounts)*binSize;
% 
% %esimate fraction missing
% fracMissSym = (surrogateArea-sum(spikeCounts)*binSize)/surrogateArea;
% if fracMissSym < 0, fracMissSym = 0; end

% fracMissSym = [];

%% GAUSSIAN
binsGauss = binEdges(1:end-1)+binSize/2;
nextLowBin = binsGauss(1)-binSize;
addPoints = 0:binSize:nextLowBin; %so that amp vals start at 0
binsGauss = [addPoints,binsGauss];
spikeCountsGauss = [zeros(size(addPoints,2),1)',spikeCounts];

p0 = [max(spikeCountsGauss),modeSeed,2*std(amplitudes,'omitnan'),prctile(amplitudes,1)]; %seed

f = @(x,xdata)gaussianCut(x, xdata); % get anonymous function handle

options = optimoptions('lsqcurvefit', 'OptimalityTolerance', 1e-32, 'FunctionTolerance', 1e-32, 'Display', 'off');
fitOutput = lsqcurvefit(f,p0,binsGauss,spikeCountsGauss,[],[],options);

%norm area calculated by fit parameters
normArea = normcdf((fitOutput(2) - fitOutput(4))/fitOutput(3)); %ndtr((popt[1] - min_amplitude) /popt[2])
fracMissGauss =  (1-normArea);

if makePlot
    gaussCutoff = gaussCutFromParams(binsGauss,fitOutput(1),fitOutput(2),fitOutput(3),fitOutput(4));

    figure; hold on
    bar(binsGauss,spikeCountsGauss,'EdgeColor','none');
    plot(binsGauss,gaussCutoff,'k');
    grid on
    xlabel('Amplitude (a.u.)');
    ylabel('Spike count');
    title(sprintf('Fraction missing = %2f',fracMissGauss));
    fixfig;
end

%%
    function F = gaussianCut(x, bin_centers)
        F = x(1) * exp(-(bin_centers - x(2)).^2/(2 * x(3).^2));
        F(bin_centers < x(4)) = 0;
    end

    function g = gaussCutFromParams(x, a, x0, sigma, xcut) %for plotting only
        g = a .* exp(-(x - x0) .^ 2 / (2 * sigma .^ 2));
        g(x < xcut) = 0;
    end
end