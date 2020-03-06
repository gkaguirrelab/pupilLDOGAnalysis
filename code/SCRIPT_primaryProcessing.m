

% Turn off the warning regarding over-writing the control file, as we are
% not hand-editing this file in this project
warningState = warning;
warning('off','makeControlFile:overwrittingControlFile');


% Get the DropBox base directory
dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');

% set common path params
pathParams.dataSourceDirRoot = fullfile(dropboxBaseDir,'LDOG_data');
pathParams.dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing');
pathParams.Approach = 'OLApproach_TrialSequenceMR';
pathParams.Protocol = 'MRFlickerLDOG';
pathParams.Subject = 'N292';
pathParams.Date = '2020-03-05';
pathParams.Session = 'session_3';

% Set parameters common to all analyses from this project
universalKeyValues = {'intrinsicCameraMatrix',[2627.0 0 338.1; 0 2628.1 246.2; 0 0 1],...
    'radialDistortionVector',[-0.3517 3.5353],...
    'eyeLaterality','left',...
    'spectralDomain','nir', ...
    'verbose',true};

% Create the input and output paths
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



%% The set of videos to process
videoNameStems = {'pupil_LightFLux','pupil_L+S','pupil_RodMel','pupil_LightFLux02','pupil_L+S02','pupil_RodMel02'};

% The file names
videoInFileName = fullfile(inputBaseDir,[videoNameStems{1} '.mov']);
grayVideoName = fullfile(outputBaseDir,[videoNameStems{1} '.avi']);
timebaseFileName = fullfile(outputBaseDir,[videoNameStems{1} '_timebase.mat']);
glintFileName = fullfile(outputBaseDir,[videoNameStems{1} '_glint.mat']);
perimeterFileName = fullfile(outputBaseDir,[videoNameStems{1} '_perimeter.mat']);
correctedPerimeterFileName = fullfile(outputBaseDir,[videoNameStems{1} '_correctedPerimeter.mat']);
controlFileName = fullfile(outputBaseDir,[videoNameStems{1} '_controlFile.csv']);


%% Deinterlace
deinterlaceVideo(videoInFileName, grayVideoName, ...
    universalKeyValues{:});


%% Timebase
makeTimebase(videoInFileName, timebaseFileName, ...
    'audioTrackSync', true, ...
    'checkCountTRs', 1, ...
    'makePlots', true, ...
    universalKeyValues{:});


%% Glint
% Code to use a GUI to define a crop mask
%{
	maskBounds = defineCropMask(grayVideoName,'startFrame',10);
%}
maskBounds = [222   215   170   330];
findGlint(grayVideoName, glintFileName, ...
    'glintFrameMask',maskBounds,...
    'glintGammaCorrection',1,...
    'glintThreshold',0.5,...
    universalKeyValues{:});

% Perimeter
maskBounds = [186   124    69   239];
findPupilPerimeter(grayVideoName, perimeterFileName, ...
    'pupilFrameMask',maskBounds,...
    'pupilRange',[42 51],...
    'pupilCircleThresh',0.0180,...
    universalKeyValues{:});

% Control
makeControlFile(controlFileName, perimeterFileName, glintFileName, ...
    'glintPatchRadius',30,...
    'candidateThetas',[pi],...
    'useParallel',true,...
    'nWorkers',2,...
    'ellipseTransparentUB',[640,480,20000,0.5, pi],...
    'cutErrorThreshold',1.5,...
    universalKeyValues{:});


% Restore the warning state
warning(warningState);

