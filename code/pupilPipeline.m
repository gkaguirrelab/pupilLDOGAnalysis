function pupilPipeline(pathParams,videoNameStems, universalKeyValues, sessionKeyValues)
% Run through transparentTrack stages to perform pupil video pre-processing
%
% Syntax:
%  pupilPipeline(pathParams,videoNameStems, universalKeyValues, sessionKeyValues)
%
% Description:
%   Calls the stages of transparent track to pre-process a set of videos
%   from the LDOG project.
%
%


%% Create the input and output paths
inputBaseDir = fullfile(pathParams.dataSourceDirRoot, ...
    'Experiments',...
    pathParams.Approach,...
    pathParams.Protocol,...
    'Videos',...
    pathParams.Subject,...
    pathParams.Date);

outputBaseDir = fullfile(pathParams.dataOutputDirRoot, ...
    'Experiments',...
    pathParams.Approach,...
    pathParams.Protocol,...
    'EyeTracking',...
    pathParams.Subject,...
    pathParams.Date,...
    pathParams.Session);

% If the outputBaseDir does not exist, make it
if ~exist(outputBaseDir)
    mkdir(outputBaseDir)
end



%% Turn off the warning regarding over-writing the control file
warningState = warning;
warning('off','makeControlFile:overwrittingControlFile');


%% Loop through the videos
for vv = 1:length(videoNameStems)
        
    % The file names
    videoInFileName = fullfile(inputBaseDir,[videoNameStems{vv} '.mov']);
    grayVideoName = fullfile(outputBaseDir,[videoNameStems{vv} '.avi']);
    timebaseFileName = fullfile(outputBaseDir,[videoNameStems{vv} '_timebase.mat']);
    glintFileName = fullfile(outputBaseDir,[videoNameStems{vv} '_glint.mat']);
    perimeterFileName = fullfile(outputBaseDir,[videoNameStems{vv} '_perimeter.mat']);
    correctedPerimeterFileName = fullfile(outputBaseDir,[videoNameStems{vv} '_correctedPerimeter.mat']);
    controlFileName = fullfile(outputBaseDir,[videoNameStems{vv} '_controlFile.csv']);
    pupilFileName = fullfile(outputBaseDir,[videoNameStems{vv} '_pupil.mat']);
    fitVideoName = fullfile(outputBaseDir,[videoNameStems{vv} '_stage6fit.avi']);    
    
    % Deinterlace
    deinterlaceVideo(videoInFileName, grayVideoName, ...
        universalKeyValues{:},sessionKeyValues{:});    
    
    % Timebase
    makeTimebase(videoInFileName, timebaseFileName, ...
        universalKeyValues{:},sessionKeyValues{:});    
    
    % Glint
    findGlint(grayVideoName, glintFileName, ...
        universalKeyValues{:});
    
    % Perimeter
    findPupilPerimeter(grayVideoName, perimeterFileName, ...
        universalKeyValues{:},sessionKeyValues{:});    
    
    % Control
    makeControlFile(controlFileName, perimeterFileName, glintFileName, ...
        universalKeyValues{:},sessionKeyValues{:});    
    
    % Correct
    applyControlFile(perimeterFileName, controlFileName, correctedPerimeterFileName, ...
        universalKeyValues{:},sessionKeyValues{:});    
    
    % Fit
    fitPupilPerimeter(correctedPerimeterFileName, pupilFileName, ...
        universalKeyValues{:},sessionKeyValues{:});    
    
    % Video
    makeFitVideo(grayVideoName, fitVideoName, ...
        'perimeterFileName',correctedPerimeterFileName,...
        'pupilFileName',pupilFileName,...
        'fitLabel', 'initial', ...
        universalKeyValues{:},sessionKeyValues{:});    
    
end


%% Restore the warning state
warning(warningState);


end

