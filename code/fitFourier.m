function [amplitude, phase, figHandle, ts, y, yFit, semAmplitude, semPhase] = fitFourier(videoPathNameStems, freq, endTime, startTime, highPassCutoff, rmseThresh, showPlot)
% Fit a Fourier basis at a specified frequency to pupil ellipse area
%
% Syntax:
%  [amplitude, phase, figHandle] = fitFourier(videoPathNameStems, freq, endTime, startTime, highPassCutoff, showPlot)
%
% Description:
%   Loads the pupil file associated with a video name stem and fits a
%   Fourier basis to the time series of the pupil area at the specified
%   frequency.
%
% Inputs:
%   videoPathNameStem     - Char vector. The full path to and name of the
%                           video file to process, omitting the '.mov'
%                           suffix.
%   freq                  - Scalar. The frequency in Hz of the stimulus.
%   startTime, endTime    - Scalar. Timing of the stimulus in seconds.
%   highPassCutoff        - Scalar. The highpass cut-off in Hz.
%
% Outputs:
%   none
%

%% Handle incomplete arguments
switch nargin
    case 3
        startTime = 0;
        highPassCutoff = 0.01;
        rmseThresh = 2;
        showPlot = false;
    case 4
        highPassCutoff = 0.01;
        rmseThresh = 2;
        showPlot = false;
    case 5
        rmseThresh = 2;
        showPlot = false;
    case 6
        showPlot = false;
    case {1, 2, 7}
        % all good
    otherwise
        error('Improper number of inputs');
end

% Assign a uniformityThresh
uniformityThresh = 0.5;

% If videoPathNameStem is a char vector, make it a one element cell array
if ~iscell(videoPathNameStems)
videoPathNameStems{1} = videoPathNameStems;
end

% Anonymous function returns the linear non-uniformity of a set of values,
% ranging from 0 when perfectly uniform to 1 when completely non-uniform. I
% define the bins over which the distribution of perimeter angles that will
% be evaluated. 20 bins works pretty well.
nDivisions = 20;
histBins = linspace(-pi,pi,nDivisions);
nonUniformity = @(x) (sum(abs(x/sum(x)-mean(x/sum(x))))/2)/(1-1/length(x));

% Loop over the identified videos
nVideos = length(videoPathNameStems);
cellSignal = {};
for vv = 1:nVideos
    timebaseFileName = [videoPathNameStems{vv} '_timebase.mat'];
    pupilFileName = [videoPathNameStems{vv} '_pupil.mat'];
    perimeterFileName = [videoPathNameStems{vv} '_correctedPerimeter.mat'];
    
    load(timebaseFileName,'timebase');
    load(pupilFileName,'pupilData');
    load(perimeterFileName,'perimeter');
    
    % Determine the sampling frequency of the data in Hz
    tmp = diff(timebase.values);
    fs = 1000./tmp(1);
    
    % Find the start of the stimulus
    [~,startIdx] = min(abs(timebase.values - startTime * 1000));
    
    % Determine the end of the stimulus
    [~,endIdx] = min(abs( timebase.values - endTime * 1000));
    
    % Extract the pupil radius
    pupilRadius = sqrt(pupilData.initial.ellipses.values(startIdx:endIdx,3)./pi);
    rmse = pupilData.initial.ellipses.RMSE(startIdx:endIdx);
    
    % Find the points with a bad rmse
    badRMSE = rmse > rmseThresh;
    
    % Loop over frames and measure linear non-uniformity. Frames which have
    % no perimeter points will be given a distVal of NaN.
    for ii = 1:length(pupilRadius)
        
        % Obtain the center of this fitted ellipse
        centerX = pupilData.initial.ellipses.values(ii,1);
        centerY = pupilData.initial.ellipses.values(ii,2);
        
        % Obtain the set of perimeter points
        Xp = perimeter.data{ii}.Xp;
        Yp = perimeter.data{ii}.Yp;
        
        % Calculate the deviation of the distribution of points from
        % uniform
        linearNonUniformity(ii) = nonUniformity(histcounts(atan2(Yp-centerY,Xp-centerX),histBins));
    end
    
    % Find the points with a bad uniformity
    badUniformity = linearNonUniformity > uniformityThresh;

    % nan the bad time points
    pupilRadius(badUniformity) = nan;
    pupilRadius(badRMSE) = nan;

    % Handle nans
    nanIdx = isnan(pupilRadius);
    meanRadius = nanmean(pupilRadius);
    pupilRadius(nanIdx) = meanRadius;
    
    % Report proportion of nans
    tmp = strsplit(videoPathNameStems{vv},filesep);
    fprintf(sprintf([tmp{end} ' median RMSE: %2.2f, percent bad RMSE: %d, percent bad uniformity: %d \n'],nanmedian(rmse),round(100*sum(badRMSE)/length(nanIdx)),round(100*sum(badUniformity)/length(nanIdx))));
    
    % Filter low-frequencies
    pupilRadiusFiltered = highpass(pupilRadius,highPassCutoff,fs);
    
    % Convert to percent change and save in a cell array
    cellSignal{vv} = 100*(pupilRadiusFiltered./meanRadius);
    
end

% Find the maximum signal length
signalLength = max(cellfun(@(x) size(x,1),cellSignal));
signalMatrix = nan(nVideos,signalLength);
for vv = 1:nVideos
    tmpS = cellSignal{vv};
    signalMatrix(vv,1:length(tmpS))=tmpS;
end

% Determine the number of available combinations with resampling
bootSets = combinator(nVideos,nVideos,'c','r');

% Set up the regression matrix
t = 1:size(signalMatrix,2);
X = [];
X(:,1) = sin(  t./(fs/freq).*2*pi );
X(:,2) = cos(  t./(fs/freq).*2*pi );

% Loop over all available combinations
for bb=1:size(bootSets,1)

    % Get this bootstrapped signal
    signal = nanmean(signalMatrix(bootSets(bb,:),:));
    signal = signal - nanmean(signal);
    signal(isnan(signal)) = 0;

    % Perform the fit
    y = signal';
    b = X\y;
    amplitudeBoot(bb) = norm(b);
    phaseBoot(bb) = -atan(b(2)/b(1));

end

% Derive the vector means and sems across bootstraps
xVals = amplitudeBoot.*cos(phaseBoot);
yVals = amplitudeBoot.*sin(phaseBoot);
amplitude = norm([mean(xVals) mean(yVals)]);
phase = atan2(mean(yVals),mean(xVals));
semAmplitude = std(amplitudeBoot);
semPhase = std(phaseBoot);

% Now just take the average signal
signal = nanmean(signalMatrix);
y = signal';
b = X\y;

% Create a figure
if showPlot
    figHandle = figure('visible','on');
else
    figHandle = figure('visible','off');
end
set(figHandle,'color','w');
ts = t ./ fs;
plot(ts,y,'.','Color',[0.85 0.85 0.85]);
hold on
yFit = highpass(X*b,highPassCutoff,fs);
plot(ts,yFit,'-r');
ylim([-25 25]);
title(videoPathNameStems,'interpreter', 'none');
xlabel('time [secs]');
ylabel('pupil radius [%change]');

end