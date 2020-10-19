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
pathParams.Subject = 'N344';
pathParams.Date = '2020-10-14';
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
durations = [504,504,504,504,504,504];
freqs = [1/6,1/6,1/6,1/6,1/6,1/6];

% There is only one audio TTL pulse 
checkCountTRs = [112 112 112 112 112 112 112 112 112 112 112 112];

% Mask bounds
glintFrameMaskSet = {...
    [193   356   240   242], ... 
    [193   354   247   244], ... 
    [178   353   258   247], ... 
    [80   245   356   356], ... 
    [74   242   359   352], ...
    [69   244   361   348], ...
    [95   205   342   392], ...
    [86   207   345   384], ... 
    [84   213   353   385], ...
    [262   265   177   338] , ...
    [265   262   173   340], ...
    [260   266   178   336]}; 
pupilFrameMaskSet = {...
    [117   199   111   169], ... % 98
    [106   180   116   169], ... % 2141
    [91   182   128   176], ...  % 60
    [31   154   219   235], ... % 10790
    [1   103   197   210], ... % 410
    [1    91   187   203], ... % 7
    [1    66   208   283], ... % 545
    [1    63   203   268], ... % 19
    [1    90   218   283], ... % 1415
    [182   158    47   203], ... % 125
    [183   159    48   210], ... % 927
    [198   177    62   220]}; % 698

pupilCircleThreshSet = [0.057, 0.063, 0.063, 0.08, 0.129, 0.128, 0.095, 0.108, 0.08, 0.075, 0.071, 0.071];

pupilRangeSets = {[65 80], [71 87], [72 88], [63 77], [106 131], [106 131], [93 119], [93 119], [80 98], [68 84], [70 86], [71 86]};
candidateThetas = {[pi],[pi],[pi],[pi/2],[pi/2],[pi],[pi],[pi],[pi],[pi],[pi/2],[pi]};

ellipseEccenLBUB = {[0.2 0.6],[0.2 0.7],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0.2 0.6],[0 0.6]};

glintPatchRadius = [45,45,45,45,45,45,45,45,45,45,45,45];

minRadiusProportion = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

cutErrorThreshold = [2,2,2,1,1,2,2,2,2,2,1,2];

ellipseAreaLB = [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000];
ellipseAreaUP = [90000, 90000, 90000, 90000, 90000, 90000, 90000, 90000, 90000, 90000, 90000, 90000];
glintThreshold = [0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4];

goodGlintFrame = [15, 9, 13, 5, 25, 9, 13, 179, 8, 9, 15, 3];
pupilGammaCorrection = [0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75,0.75];
motionCorrect = [false,false,false,false,false,false,false,false,false,false,false,false];
%% Loop through video name stems get each video and its corresponding masks
vids = [1,2,3,4,5,6,7,8,9,10,11,12];
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

% %% Call the frequency fitting pipeline
% fourierFitPipeline(pathParams,videoNameStems,sets,labels,durations,freqs);

