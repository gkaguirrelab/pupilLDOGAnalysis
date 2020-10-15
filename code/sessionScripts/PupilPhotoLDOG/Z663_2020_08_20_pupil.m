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
pathParams.Subject = 'Z663';
pathParams.Date = '2020-08-20';
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
sets = {[1 7],[8 8],[3 9],[4 4],[5 11], [6, 12]};
labels = {'pupil_LightFlux_1-6Hz_RightEyeStim','pupil_RodMel_1-6Hz_RightEyeStim',...
    'pupil_LplusS_1-6Hz_RightEyeStim', 'pupil_LightFlux_1-6Hz_LeftEyeStim',...
    'pupil_RodMel_1-6Hz_LeftEyeStim', 'pupil_LplusS_1-6Hz_LeftEyeStim'};
durations = [504,504,504,504,504,504,504];
freqs = [1/6,1/6,1/6,1/6,1/6,1/6];

% There is only one audio TTL pulse 
checkCountTRs = [112 112 112 112 112 112 112 112 112 112 112 112];


% Mask bounds
glintFrameMaskSet = {...
    [62   106   227   353], ... %10812
    [76   122   134   179], ... 
    [34   163   237   252], ... 
    [218   330    70   130], ... 
    [255   223   120   248], ...
    [195    40   138   326], ...
    [64   182   234   229], ...
    [71   183   225   247], ... %3041
    [128   104   208   359], ...
    [24   126   125   213] , ...
    [66    46    88   172], ...
    [136   261   218   198]}; 
pupilFrameMaskSet = {...
    [38    96   198   313], ...
    [56    83   122   176], ... 
    [35   150   217   230], ... 
    [204   300    53   104], ...
    [239   233    46   201], ...
    [186    98    65   299], ...
    [32   200   194   180], ...
    [49   164   205   242], ...
    [104    66   167   346], ...
    [11    65    40    87], ...
    [29     0   106   235], ...
    [2    59   135   220]};


pupilCircleThreshSet = [0.062, 0.062, 0.062, 0.062, 0.062, 0.05, 0.062, 0.062, 0.062, 0.2, 0.2, 0.1];

pupilRangeSets = {[50 78], [50 78], [50 78], [50 78], [50 78], [50 78], [50 78], [50 78], [50 78], [80 130], [90 140], [90 140]};
candidateThetas = {[pi/2; pi],[3*pi/2; pi/2; pi],[pi],[pi; 4*pi/6],[pi; 4*pi/6],[pi/2],[3*pi/2],[3*pi/2],[5*pi/4],[5*pi/4],[pi/2; pi],[pi/2; pi]};

ellipseEccenLBUB = {[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6]};

glintPatchRadius = [20,35,20,35,35,35,35,20,20,60,60,60];

minRadiusProportion = [0, 0, 0, 0, 0, -0.8, 0, 0, 0, 0, 0, 0];

cutErrorThreshold = [1,1,1,1,1,1,1,1,1,1,1,1];

ellipseAreaLB = [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000];
ellipseAreaUP = [90000, 50000, 50000, 50000, 50000, 50000, 50000, 50000, 50000, 90000, 90000, 90000];
glintThreshold = [0.4, 0.4, 0.36, 0.36, 0.36, 0.36, 0.4, 0.36, 0.36, 0.4, 0.4, 0.4];

goodGlintFrame = [15, 9, 13, 5, 25, 9, 13, 179, 8, 9, 15, 3];
pupilGammaCorrection = [0.75,0.75,0.75,0.75,0.75,0.95,0.75,0.75,0.75,0.75,0.75,0.75];
motionCorrect = [true,false,true,true,true,true,true,true,true,true,true,true];
%% Loop through video name stems get each video and its corresponding masks
% vids = [2];
% for ii = vids
%     pupilCircleThresh = pupilCircleThreshSet(ii);
%     pupilRange = pupilRangeSets{ii};
%     videoName = {videoNameStems{ii}};
%     glintFrameMask = glintFrameMaskSet{ii};
%     pupilFrameMask = pupilFrameMaskSet{ii};
%     % Analysis parameters
%     % To adjust these parameters for a given session, use the utility:
%     %{
%         estimatePipelineParamsGUI('','TOME')
%     %}
%     % And select one of the raw data .mov files.
% 
%     sessionKeyValues = {...
%         'motionCorrect', motionCorrect(ii), ...
%         'goodGlintFrame', goodGlintFrame(ii), ...
%         'pupilGammaCorrection', pupilGammaCorrection(ii), ...
%         'startFrame',1, ...
%         'nFrames', Inf, ...
%         'checkCountTRs',checkCountTRs(ii), ...
%         'glintFrameMask',glintFrameMask,...
%         'glintGammaCorrection',0.75,...
%         'glintThreshold',glintThreshold(ii),...
%         'pupilFrameMask',pupilFrameMask,...
%         'pupilRange',pupilRange,...
%         'pupilCircleThresh',pupilCircleThresh,...
%         'glintPatchRadius',glintPatchRadius(ii),...
%         'candidateThetas',candidateThetas{ii},...
%         'cutErrorThreshold',cutErrorThreshold(ii),...
%         'radiusDivisions',50,...
%         'ellipseTransparentLB',[0,0,ellipseAreaLB(ii), ellipseEccenLBUB{ii}(1), 0],...
%         'ellipseTransparentUB',[1280,720,ellipseAreaUP(ii),ellipseEccenLBUB{ii}(2), pi],...
%         'minRadiusProportion', minRadiusProportion(ii),...
%         };
% 
%     % Call the pre-processing pipeline
%     pupilPipeline(pathParams,videoName,sessionKeyValues);
%     
% end

%% Call the frequency fitting pipeline
fourierFitPipeline(pathParams,videoNameStems,sets,labels,durations,freqs);

