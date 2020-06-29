function [amplitude, phase, figHandle] = fitFourier(videoPathNameStems, freq, endTime, startTime, highPassCutoff, showPlot)
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
        showPlot = false;
    case 4
        highPassCutoff = 0.01;
        showPlot = false;
    case 5
        showPlot = false;
    case {1, 2, 6}
        % all good
    otherwise
        error('Improper number of inputs');
end

% If videoPathNameStem is a char vector, make it a one element cell array
if ~iscell(videoPathNameStems)
videoPathNameStems{1} = videoPathNameStems;
end

% Loop over the identified videos
nVideos = length(videoPathNameStems);
cellSignal = {};
for vv = 1:nVideos
    timebaseFileName = [videoPathNameStems{vv} '_timebase.mat'];
    pupilFileName = [videoPathNameStems{vv} '_pupil.mat'];
    
    load(timebaseFileName,'timebase');
    load(pupilFileName,'pupilData');
    
    % Determine the sampling frequency of the data in Hz
    tmp = diff(timebase.values);
    fs = 1000./tmp(1);
    
    % Find the start of the stimulus
    [~,startIdx] = min(abs(timebase.values - startTime * 1000));
    
    % Determine the end of the stimulus
    [~,endIdx] = min(abs( timebase.values - endTime * 1000));
    
    % Extract the pupil radius
    pupilRadius = sqrt(pupilData.initial.ellipses.values(startIdx:endIdx,3)./pi);
    
    % Handle nans
    nanIdx = isnan(pupilRadius);
    meanRadius = nanmean(pupilRadius);
    pupilRadius(nanIdx) = meanRadius;
    
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
signal = nanmean(signalMatrix);

% Perform the fit
t = 1:length(signal);
y = signal';
x = 1:length(y);
X = [];
X(:,1) = sin(  x./(fs/freq).*2*pi );
X(:,2) = cos(  x./(fs/freq).*2*pi );
b = X\y;
amplitude = norm(b);
phase = -atan(b(2)/b(1));

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
plot(ts,X*b,'-r');
ylim([-25 25]);
title(videoPathNameStems,'interpreter', 'none');
xlabel('time [secs]');
ylabel('pupil radius [%change]');

end