%% EM552_2020_06_30_pupil
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
pathParams.Subject = 'EM522';
pathParams.Date = '2020-06-30';
pathParams.Session = 'session_1';

% The approach and protocol. These shouldn't change much
pathParams.Approach = 'OLApproach_TrialSequenceMR';
pathParams.Protocol = 'PupilPhotoLDOG';

% The names of the videos to process
videoNameStems = {...
    'pupil_LightFlux_1-6Hz_RightEyeStim_01',...
    'pupil_RodMel_1-6Hz_RightEyeStim_02',...
    'pupil_LplusS_1-6Hz_RightEyeStim_03',...
    'pupil_LightFlux_1-6Hz_LeftEyeStim_04',...
    'pupil_RodMel_1-6Hz_LeftEyeStim_05',...
    'pupil_LplusS_1-6Hz_LeftEyeStim_06',...
    'pupil_LightFlux_1-6Hz_RightEyeStim_07',...
    'pupil_RodMel_1-6Hz_RightEyeStim_08',...
    'pupil_LplusS_1-6Hz_RightEyeStim_09',...
    'pupil_LightFlux_1-6Hz_LeftEyeStim_10',...
    'pupil_RodMel_1-6Hz_LeftEyeStim_11',...
    'pupil_LplusS_1-6Hz_LeftEyeStim_12'};

% Stimulus properties
sets = {[1 7],[2 8],[3 9],[4 10],[5 11],[6 12]};
labels = {'pupil_LightFlux_1-6Hz_RightEyeStim','pupil_RodMel_1-6Hz_RightEyeStim','pupil_LplusS_1-6Hz_RightEyeStim',...
    'pupil_LightFlux_1-6Hz_LeftEyeStim', 'pupil_RodMel_1-6Hz_LeftEyeStim', 'pupil_LplusS_1-6Hz_LeftEyeStim'};
durations = [504,504,504,504,504,504];
freqs = [1/6,1/6,1/6,1/6,1/6,1/6];

% There is only one audio TTL pulse 
checkCountTRs = 112;

% Mask bounds
glintFrameMaskSet = {[229   281   225   332], ... % Selected frame 1956
    [224   290   234   329], ... % 2519
    [210   290   248   327], ... % 10790
    [175   375   280   242], ... % 6825
    [131   320   326   298], ... % 10790
    [129   318   326   298], ... % 1919
    [174   283   283   334], ... % 971
    [163   303   295   318], ... % 3064
    [157   306   300   315], ... % 253
    [159   432   297   185], ... % 261
    [162   440   294   178], ... % 2470
    [155   440   301   176]}; % 1527
pupilFrameMaskSet = {[179   253   175   275], ...
    [191   259   176   284], ...
    [165   251   179   266], ...
    [107 233 164 188], ...
    [30    161   201   190], ...
    [86   244   252   264], ...
    [103   236   218   263], ...
    [100   230   200   216], ...
    [71   239   218   205], ...
    [98   298   198   141], ...
    [114   350   212   136], ...
    [95   340   223   130]};

pupilCircleThreshSet = [0.0200, 0.0160, 0.0250, 0.0450, 0.0310, 0.0530, 0.0490, 0.0400, 0.0300, 0.0400, 0.0490, 0.0370, 0.0430];
pupilRangeSets = {[39 60], [41 50], [39 70], [47 58], [47 57], [55 67], [58 71], [42 60], [44 57], [63 80], [45 55], [44 54], [45 55]};
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
        'checkCountTRs', checkCountTRs, ...
        'glintFrameMask',glintFrameMask,...
        'glintGammaCorrection',1,...
        'glintThreshold',0.5,...
        'pupilFrameMask',pupilFrameMask,...
        'pupilRange',pupilRange,...
        'pupilCircleThresh',pupilCircleThresh,...
        'glintPatchRadius',50,...
        'candidateThetas',[pi],...
        'ellipseTransparentUB',[640,480,20000,0.5, pi],...
        'cutErrorThreshold',1.5,...
        };

    % Call the pre-processing pipeline
    pupilPipeline(pathParams,videoName,sessionKeyValues);
end

%% Call the frequency fitting pipeline
%fourierFitPipeline(pathParams,videoNameStems,sets,labels,durations,freqs);

