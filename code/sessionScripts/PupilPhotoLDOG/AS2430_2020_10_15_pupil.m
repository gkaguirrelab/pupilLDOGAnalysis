%% N344_2020_10_15_pupil
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
pathParams.Subject = 'AS2-430';
pathParams.Date = '2020-10-15';
pathParams.Session = '';

% The approach and protocol. These shouldn't change much
pathParams.Approach = 'OLApproach_TrialSequenceMR';
pathParams.Protocol = 'PupilPhotoLDOG';

% The names of the videos to process
videoNameStems = {...
    'pupil_LightFlux_1-6Hz_RightEyeStim_01',... 
    'pupil_LightFlux_1-6Hz_LeftEyeStim_04',... 
    'pupil_LightFlux_1-6Hz_RightEyeStim_07',... 
    'pupil_LightFlux_1-6Hz_LeftEyeStim_10',...
    'pupil_LightFlux_1-6Hz_RightEyeStim_13',...
    'pupil_LightFlux_1-6Hz_LeftEyeStim_16',...
    };

% Stimulus properties
sets = {[1 2 3], [4 5 6]};
labels = {'pupil_LightFlux_1-6Hz_RightEyeStim','pupil_LightFlux_1-6Hz_LeftEyeStim'};
durations = [360,360];
freqs = [1/6,1/6];

% There is only one audio TTL pulse 
checkCountTRs = [112 112 112 112 112 112];

% Mask bounds
glintFrameMaskSet = {...
    [185   277   239   303], ... 
    [196   250   242   348], ... 
    [179   297   257   295], ... 
    [188   240   250   352], ... 
    [171   304   263   289], ...
    [170   230   253   356]}; 
pupilFrameMaskSet = {...
    [103   137   120   236], ... % 
    [142   176   100   220], ... % 
    [88   160   157   226], ...  % 
    [140   168   112   222], ... % 
    [83   155   146   210], ... % 
    [122   141   112   215]}; % 

pupilCircleThreshSet = [0.038, 0.038, 0.038, 0.038, 0.04, 0.038];

pupilRangeSets = {[59 72], [59 72], [59 72], [59 72], [59 72], [59 72]};
candidateThetas = {[pi],[pi],[pi],[pi],[pi],[pi]};

ellipseEccenLBUB = {[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6]};

glintPatchRadius = [40,40,40,40,40,40];

minRadiusProportion = [0, 0, 0, 0, 0, 0];

cutErrorThreshold = [2,2,2,2,2,2];

ellipseAreaLB = [1000, 1000, 1000, 1000, 1000, 1000];
ellipseAreaUP = [90000, 90000, 90000, 90000, 90000, 90000];
glintThreshold = [0.4, 0.4, 0.4, 0.4, 0.4, 0.4];

goodGlintFrame = [15, 9, 13, 5, 25, 9];
pupilGammaCorrection = [0.75,0.75,0.75,0.75,0.75,0.75];
motionCorrect = [false,false,false,false,false,false];
%% Loop through video name stems get each video and its corresponding masks
vids = [1,2,3,4,5,6];
for ii = vids
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
        'motionCorrect', motionCorrect(ii), ...
        'goodGlintFrame', goodGlintFrame(ii), ...
        'pupilGammaCorrection', pupilGammaCorrection(ii), ...
        'startFrame',1, ...
        'nFrames', Inf, ...
        'checkCountTRs',checkCountTRs(ii), ...
        'glintFrameMask',glintFrameMask,...
        'glintGammaCorrection',0.75,...
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

%% Call the frequency fitting pipeline
fourierFitPipeline(pathParams,videoNameStems,sets,labels,durations,freqs);

