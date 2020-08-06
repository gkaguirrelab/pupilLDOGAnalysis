%% EM526_2020_06_30_pupil
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
pathParams.Subject = 'EM526';
pathParams.Date = '2020-06-30';
pathParams.Session = 'session_1';

% The approach and protocol. These shouldn't change much
pathParams.Approach = 'OLApproach_TrialSequenceMR';
pathParams.Protocol = 'PupilPhotoLDOG';

% The names of the videos to process
videoNameStems = {...
    'pupil_LightFlux_1-6Hz_RightEyeStim_01',... % TR num 112
    'pupil_RodMel_1-6Hz_RightEyeStim_02',... % TR num 109
    'pupil_LplusS_1-6Hz_RightEyeStim_03',... % TR num 112
    'pupil_LightFlux_1-6Hz_LeftEyeStim_04',... % TR num 112
    };

% Stimulus properties
sets = {[1],[2],[3],[4]};
labels = {'pupil_LightFlux_1-6Hz_RightEyeStim','pupil_RodMel_1-6Hz_RightEyeStim_02',...
    'pupil_LplusS_1-6Hz_RightEyeStim_03', 'pupil_LightFlux_1-6Hz_LeftEyeStim_04'};
durations = [504,504,504,504];
freqs = [1/6,1/6,1/6,1/6];

% There is only one audio TTL pulse 
checkCountTRs = [112 109 112 112];

% Mask bounds
glintFrameMaskSet = {...
    [1    82   218    69], ... 
    [8   127   256   298], ... 
    [1    55   116   177], ... 
    [58   116   125   149], ... 
    }; 
pupilFrameMaskSet = {...
    [29   258   236   184], ... % 268
    [1   102   262   284], ... %194
    [1   204   274   223], ... %1371
    [89   266   163   145], ... % 202 94 start
    };

pupilCircleThreshSet = [0.01, 0.01, 0.01, 0.01, 0.01];

pupilRangeSets = {[39 70], [39 70], [39 70], [39 70]};
candidateThetas = {[pi],[pi],[pi],[pi]};

ellipseEccenLBUB = {[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6]};

glintPatchRadius = [20,20,20,20];

minRadiusProportion = [0, 0, 0, 0];

cutErrorThreshold = [1.5, 1.5, 1.5, 1.5];

ellipseAreaLB = [5000, 5000, 5000, 5000];
ellipseAreaUP = [50000, 50000, 50000, 50000];
glintThreshold = [0.5, 0.5, 0.5, 0.5];

goodGlintFrame = [10, 10, 10, 100];
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
        'motionCorrect', true, ...
        'goodGlintFrame', goodGlintFrame(ii), ...
        'startFrame',1, ...
        'nFrames', Inf, ...
        'checkCountTRs',checkCountTRs(ii), ...
        'glintFrameMask',glintFrameMask,...
        'glintGammaCorrection',1.3,...
        'glintThreshold',glintThreshold(ii),...
        'pupilFrameMask',pupilFrameMask,...
        'pupilRange',pupilRange,...
        'pupilCircleThresh',pupilCircleThresh,...
        'glintPatchRadius',glintPatchRadius(ii),...
        'candidateThetas',candidateThetas{ii},...
        'cutErrorThreshold',cutErrorThreshold(ii),...
        'radiusDivisions',50,...
        'ellipseTransparentLB',[0,0,ellipseAreaLB(ii), ellipseEccenLBUB{ii}(1), 0],...
        'ellipseTransparentUB',[1280,720,ellipseAreaUP(ii),ellipseEccenLBUB{ii}(2), pi],...
        'minRadiusProportion', minRadiusProportion(ii),...
        };

    % Call the pre-processing pipeline
    pupilPipeline(pathParams,videoName,sessionKeyValues);
    
end

% %% Call the frequency fitting pipeline
% fourierFitPipeline(pathParams,videoNameStems,sets,labels,durations,freqs);

