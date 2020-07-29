%% N335_2020_06_26_session1_ND40_pupil
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
pathParams.Subject = 'N335';
pathParams.Date = '2020-06-26';
pathParams.Session = 'session_1_ND40';

% The approach and protocol. These shouldn't change much
pathParams.Approach = 'OLApproach_TrialSequenceMR';
pathParams.Protocol = 'PupilScotoLDOG';

% The names of the videos to process
videoNameStems = {...
    'pupil_LightFlux_1-6Hz_01',...
    'pupil_LightFlux_1-6Hz_02',...
    'pupil_RodMel_1-6Hz_04',...
    'pupil_Rodmel_1-24Hz_05',...
    'pupil_RodMel_1-12Hz_06',...
    'pupil_LplusS_1-6Hz_07',...
    'pupil_LplusS_1-6Hz_08',...
    'pupil_LplusS_1-6Hz_09',...
    };

% Stimulus properties
sets = {[1 2] [3 4 5] [6 7 8]]};
labels = {'pupil_LightFlux_1-6Hz', 'pupil_RodMel_1-6Hz', 'pupil_LplusS_1-6Hz'};
durations = [504,504,504,504,504,504];
freqs = [1/6, 1/6, 1,6];

% There is only one audio TTL pulse 
checkCountTRs = 112;

% Mask bounds
glintFrameMaskSet = {
    [107   215   343   393], ...
    [74    204   325   354], ...
    [131   361   317   247], ... 
    [68    372   324   178], ... 
    [113   174   225   309], ... 
    [143   403   246   145],...
    [137   379   232   149], ... 
    [141   424   257   136]};
pupilFrameMaskSet = {
    [1    63   223   247], ... % 8305
    [1    72   226   226], ... % 581
    [1   208   204   112], ... % 1559
    [1   265   239    62], ... % 5446
    [13    78   144   218], ... % 7585
    [1   247   132     1], ... % 7978
    [13   226   118    17], ... % 1975
    [2   265   132     9]}; % 1537

pupilCircleThreshSet = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1];
pupilRangeSets = {[114 150], [114 150], [114 150], [114 150], [114 150], [114 150], [114 150], [114 150]};

candidateThetas = {[pi/2; pi], [pi/2; pi], [pi/2; pi], [pi/2; pi], [pi/2; pi], [pi/2; pi], [pi/2; pi], [pi/2; pi]};

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
        'glintGammaCorrection',0.8,...
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
