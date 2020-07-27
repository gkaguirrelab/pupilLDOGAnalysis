%% N334_2020_06_25_pupil
%
% The video analysis pre-processing pipeline for an LDOG session.
%
% To define mask bounds, use:
%{
	glintFrameMask = defineCropMask('pupil_L+S_01.mov','startFrame',10)
	pupilFrameMask = defineCropMask('pupil_L+S_01.mov','startFrame',10)
%}
% For the glint, put a tight box around the glint. For the pupil, define a
% mask area that safely contains the pupil at its most dilated.



%% Session parameters

% Subject and session params.
pathParams.Subject = 'N334';
pathParams.Date = '2020-06-25';
pathParams.Session = 'session_1';

% The approach and protocol. These shouldn't change much
pathParams.Approach = 'OLApproach_TrialSequenceMR';
pathParams.Protocol = 'PupilScotoLDOG';

% The names of the videos to process
videoNameStems = {...
    'pupil_LightFlux_1-24Hz_01',...
    'pupil_LightFlux_1-12Hz_02',...
    'pupil_LightFlux_1-6Hz_03',...
    'pupil_LightFlux_1-24Hz_04',...
    'pupil_LightFlux_1-12Hz_05',...
    'pupil_LightFlux_1-6Hz_06'};

% Stimulus properties
sets = {[1 4], [2 5], [3 6]};
labels = {'pupil_LightFlux_1-24Hz', 'pupil_LightFlux_1-12Hz_02', 'pupil_LightFlux_1-6Hz_03'};
durations = [504,504,504,504,504,504];
freqs = [1/24,1/12,1/6];

% There is only one audio TTL pulse 
checkCountTRs = 1;

% Mask bounds
glintFrameMaskSet = {
    [171   299   269   303], ...
    [152   297   288   303], ...
    [147   303   289   297], ... 
    [126   306   314   291], ... 
    [119   308   317   287], ... 
    [117   316   322   283]};
pupilFrameMaskSet = {
    [63   126   103   158], ... % 9000
    [25   134   123   150], ... % 4400
    [11   119   120   140], ... % 3331
    [1   128   143   136], ... % 6640
    [1   138   149   129], ... %4331
    [1   137   149   128]}; %1971

pupilCircleThreshSet = [0.1990, 0.1950, 0.1950, 0.193, 0.196, 0.198];
pupilRangeSets = {[122 149], [124 152], [131 160], [136 166], [136 167], [133 162]};

candidateThetas = {[pi/2], [pi/2], [pi/2; pi], [pi/2], [pi/2], [pi/2]};

ellipseEccenLBUB = {[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6]};

glintPatchRadius = [25,25,25,25,25,25];

%% Loop through video name stems get each video and its corresponding masks
numVids = length(videoNameStems);
for ii = 1:numVids

    pupilCircleThresh = pupilCircleThreshSet(ii);
    pupilRange = pupilRangeSets{ii};
    videoName = {videoNameStems{ii}};
    glintFrameMask = glintFrameMaskSet{ii};
    pupilFrameMask = pupilFrameMaskSet{ii};
    % Analysis parameters
    % To adjust these parameters for a given session, use the utility:
    %{
        estimatePipelineParamsGUI('','TOME')
    %}
    % And select one of the raw data .mov files.

    sessionKeyValues = {...
        'startFrame',1, ...
        'nFrames', Inf, ...
        'checkCountTRs',checkCountTRs, ...
        'glintFrameMask',glintFrameMask,...
        'glintGammaCorrection',0.75,...
        'glintThreshold',0.5,...
        'pupilFrameMask',pupilFrameMask,...
        'pupilRange',pupilRange,...
        'pupilCircleThresh',pupilCircleThresh,...
        'glintPatchRadius',glintPatchRadius(ii),...
        'candidateThetas',candidateThetas{ii},...
        'cutErrorThreshold',1.5,...
        'radiusDivisions',50,...
        'ellipseTransparentLB',[0,0,1000, ellipseEccenLBUB{ii}(1), 0],...
        'ellipseTransparentUB',[1280,720,90000,ellipseEccenLBUB{ii}(2), pi],...
        };


    % Call the pre-processing pipeline
    pupilPipeline(pathParams,videoName,sessionKeyValues);
    
end

% %% Call the frequency fitting pipeline
% fourierFitPipeline(pathParams,videoNameStems,sets,labels,durations,freqs);
