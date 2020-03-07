%% SCRIPT_deriveResponse
%
% Calls the pupil analysis pre-processing pipeline for LDOG sesson data. It
% is useful to define mask boxes for the glint and pupil. Use this code to
% do so:
%{
	maskBounds = defineCropMask(grayVideoName,'startFrame',10);
%}


%% Universal parameters
% Get the DropBox base directory
dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');

% Define the analysis directory
outputBaseDir = fullfile(pathParams.dataOutputDirRoot, ...
    'Experiments',...
    pathParams.Approach,...
    pathParams.Protocol,...
    'EyeTracking',...
    pathParams.Subject,...
    pathParams.Date,...
    pathParams.Session);

% set common path params
pathParams.dataSourceDirRoot = fullfile(dropboxBaseDir,'LDOG_data');
pathParams.dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing');
pathParams.Approach = 'OLApproach_TrialSequenceMR';
pathParams.Protocol = 'MRFlickerLDOG';

showPlots = true;

%% Session parameters

% Params
pathParams.Subject = 'N292';
pathParams.Date = '2020-03-05';
pathParams.Session = 'session_3';

% The analysis base dir
analysisBaseDir = fullfile(pathParams.dataOutputDirRoot, ...
    'Experiments',...
    pathParams.Approach,...
    pathParams.Protocol,...
    'EyeTracking',...
    pathParams.Subject,...
    pathParams.Date,...
    pathParams.Session);

% The names of the videos to process
videoNameStems = {'pupil_LightFLux','pupil_L+S','pupil_RodMel','pupil_LightFLux02','pupil_L+S02','pupil_RodMel02'};

% Loop through the videos
amplitudes = [];
for vv = 1:length(videoNameStems)
    timebaseFileName = fullfile(outputBaseDir,[videoNameStems{vv} '_timebase.mat']);
    pupilFileName = fullfile(outputBaseDir,[videoNameStems{vv} '_pupil.mat']);
    
    load(timebaseFileName,'timebase');
    load(pupilFileName,'pupilData');
    
    % Determine the sampling frequency of the data in Hz
    tmp = diff(timebase.values);
    fs = 1000./tmp(1);
    
    % Find the start of the stimulus
    [~,startIdx] = min(abs(timebase.values));
    
    % Extract the pupil radius
    pupilRadius = sqrt(pupilData.initial.ellipses.values(startIdx:end,3)./pi);
    
    % Handle nans
    nanIdx = isnan(pupilRadius);
    meanRadius = nanmean(pupilRadius);
    pupilRadius(nanIdx) = meanRadius;
    
    % Filter low-frequencies
    pupilRadiusFiltered = highpass(pupilRadius,0.01,fs);
    
    % Convert to percent change
    pupilRadiusFiltered = 100*(pupilRadiusFiltered./meanRadius);
    
    % Define the segments for fitting
    starts = [1, round(6*24*fs)+1, round(6*24*fs)+round(5*24*fs)+1 ];
    stops  = [round(6*24*fs)-1, round(6*24*fs)+round(5*24*fs)-1, length(pupilRadiusFiltered) ];
    freqs = [1/24, 1/12, 1/6];
    
    if showPlots
        figure
        set(gcf,'color','w');
    end
    
    % Loop through the fitting segments
    for ss = 1:length(freqs)
        t = starts(ss):stops(ss);
        y = pupilRadiusFiltered(t);
        x = 1:length(y);
        X = [];
        X(:,1) = sin(  x./(fs/freqs(ss)).*2*pi );
        X(:,2) = cos(  x./(fs/freqs(ss)).*2*pi );
        b = X\y;
        amplitudes(vv,ss) = norm(b);
        phases(vv,ss) = -atan(b(2)/b(1));
        if showPlots
            ts = t ./ 60;
            plot(ts,y,'.','Color',[0.85 0.85 0.85]);
            hold on
            plot(ts,X*b,'-r');
            plot([ts(end) ts(end)],[-20 20],'-k','LineWidth',1.5)
        end
    end
    
    if showPlots
        xlim([0 6*60]);
        ylim([-25 25]);
        title(videoNameStems{vv},'interpreter', 'none');
        xlabel('time [secs]');
        ylabel('pupil radius [%change]');
    end
    
end


%% Create a TTF figure
stimSets = {[1 4],[2 5],[3 6]};
stimLabels = {'lightFlux [c = 95%]','L+S [c = 35%]','RodMel [ c = 50% ]'};
stimColors = {'k','r','c'};

if showPlots
    figure
        set(gcf,'color','w');
end

for ss = 1:length(stimSets)
    A = amplitudes(stimSets{ss}(1),:);
    B = amplitudes(stimSets{ss}(2),:);
    delta = phases(stimSets{ss}(1),:)-phases(stimSets{ss}(2),:);
    y = sqrt(A.^2+B.^2 + (2.*A.*B.*cos(delta)))./2;
    
    h(ss) = plot([1 2 3],y,'o','Color',stimColors{ss});
    hold on
    plot([1 2 3],y,'-','Color',stimColors{ss});
end
xlim([0 4])
xticks([1 2 3])
xticklabels({'1/24','1/12','1/6'})
xlabel('stimulus freq [Hz]');
ylabel('pupil response [% change]');
legend(h,stimLabels);
title('Pupil response for N292');