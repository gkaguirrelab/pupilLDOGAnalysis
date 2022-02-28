%% 2356_2020_12_11_pupil
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

reprocessFlag = false;


%% Session parameters

% Subject and session params.
pathParams.Subject = '2356';
pathParams.Date = '2020-12-11';
pathParams.Session = '';

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
    'pupil_LplusS_1-6Hz_LeftEyeStim_12',...
    };

% Stimulus properties
sets = {[1 7],[2 8],[3 9],[4 10],[5 11], [6, 12]};
labels = {'pupil_LightFlux_1-6Hz_RightEyeStim','pupil_RodMel_1-6Hz_RightEyeStim',...
    'pupil_LplusS_1-6Hz_RightEyeStim', 'pupil_LightFlux_1-6Hz_LeftEyeStim',...
    'pupil_RodMel_1-6Hz_LeftEyeStim', 'pupil_LplusS_1-6Hz_LeftEyeStim'};
durations = [360,360,360,360,360,360];
freqs = [1/6,1/6,1/6,1/6,1/6,1/6];

% There is only one audio TTL pulse
checkCountTRs = [112 112 112 112 112 112 112 112 112 112 112 112];

% Mask bounds
glintFrameMaskSet = {...
    [208   189   230   412], ...
    [210   188   229   411], ...
    [207   189   233   417], ...
    [104   217   327   381], ...
    [94    208   340   390], ...
    [93    207   342   391], ...
    [243   375   191   217], ...
    [248   369   181   220], ...
    [221   210   201   369], ...
    [171   321   265   274] , ...
    [177   317   254   276], ...
    [180   318   255   279]};
pupilFrameMaskSet = {...
    [130    36   146   357], ... %
    [128    43   123   351], ... %
    [132    20   112   370], ...  %
    [22    157   235   233], ... %
    [9     141   258   261], ... %
    [5     126   233   247], ... %
    [198   253    42   137], ... %
    [201   241    38   127], ... %
    [219   245    31   144], ... %
    [97    216   151   173], ... %
    [95    213   142   168], ... %
    [100   210   147   168]}; %

pupilCircleThreshSet = [0.057, 0.055, 0.050, 0.050, 0.050, 0.050, 0.050, 0.050, 0.050, 0.050, 0.050, 0.050];

pupilRangeSets = {[50 80], [65 90], [65 90], [55 90], [55 90], [55 90], [55 90], [55 90], [55 90], [55 90], [55 90], [55 90]};
candidateThetas = {[pi],[pi],[pi],[pi],[pi],[pi/2],[pi],[pi],[pi],[pi],[pi],[pi]};

ellipseEccenLBUB = {[0.2 0.6],[0.2 0.7],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0 0.6]};

glintPatchRadius = [60,45,50,45,45,55,45,45,55,45,45,45];

minRadiusProportion = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

cutErrorThreshold = [3,2,2,2,2,2,2,2,2,2,2,2];

ellipseAreaLB = [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000];
ellipseAreaUP = [90000, 90000, 90000, 90000, 90000, 90000, 90000, 90000, 90000, 90000, 90000, 90000];
glintThreshold = [0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4];

goodGlintFrame = [15, 9, 13, 5, 25, 9, 13, 179, 8, 9, 15, 3];
pupilGammaCorrection = [0.45,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75];
motionCorrect = [false,false,false,false,false,false,false,false,false,false,false,false];
%% Loop through video name stems get each video and its corresponding masks
vids = [1,2,3,4,5,6,7,8,9,10,11,12];

if reprocessFlag
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
            'nFrames',Inf, ...
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
end

%% Call the frequency fitting pipeline
fourierFitPipeline(pathParams,videoNameStems,sets,labels,durations,freqs);

