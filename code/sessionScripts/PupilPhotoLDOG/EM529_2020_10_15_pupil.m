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
pathParams.Subject = 'EM529';
pathParams.Date = '2020-10-15';
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
    [215   339   218   254], ... 
    [210   327   215   261], ... 
    [209   313   223   276], ... 
    [148   321   274   254], ... 
    [129   321   270   246], ...
    [137   326   284   258], ...
    [143   221   290   370], ...
    [128   221   297   369], ... 
    [119   202   305   385], ...
    [175   334   246   251] , ...
    [165   334   258   250], ...
    [156   333   270   255]}; 
pupilFrameMaskSet = {...
    [152   213   131   211], ... % 252
    [138   203   122   211], ... % 333
    [136   185   138   232], ...  % 429
    [79   248   126    95], ... % 23
    [44   218   138    81], ... % 39
    [76   251   130   102], ... % 9926
    [82   107   165   305], ... % 58
    [73    98   176   292], ... % 45
    [62    84   188   311], ... %  105
    [103   259    99    90], ... % 244
    [91   252   117    98], ... % 86
    [102   285   144   118]}; % 60

pupilCircleThreshSet = [0.035, 0.052, 0.038, 0.071, 0.08, 0.067, 0.051, 0.056, 0.06, 0.078, 0.084, 0.084];

pupilRangeSets = {[55 67], [63 77], [60 74], [81 99], [89 109], [83 101], [67 82], [69 84], [72 88], [83 101], [87 106], []};
candidateThetas = {[pi/2; pi],[3*pi/2; pi/2; pi],[pi],[pi; 4*pi/6],[pi; 4*pi/6],[pi/2],[3*pi/2],[3*pi/2],[5*pi/4],[5*pi/4],[pi/2; pi],[pi/2; pi]};

ellipseEccenLBUB = {[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6],[0.1 0.6]};

glintPatchRadius = [40,40,40,40,40,40,40,40,40,40,40,40];

minRadiusProportion = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

cutErrorThreshold = [1,1,1,1,1,1,1,1,1,1,1,1];

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
