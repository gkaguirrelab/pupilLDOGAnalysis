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
    'pupil_LplusS_1-6Hz_LeftEyeStim_12',...
    };

% Stimulus properties
sets = {[1 7],[2 8],[3 9],[4 10],[5 11],[6 12]};
labels = {'pupil_LightFlux_1-6Hz_RightEyeStim','pupil_RodMel_1-6Hz_RightEyeStim','pupil_LplusS_1-6Hz_RightEyeStim',...
    'pupil_LightFlux_1-6Hz_LeftEyeStim', 'pupil_RodMel_1-6Hz_LeftEyeStim', 'pupil_LplusS_1-6Hz_LeftEyeStim'};
durations = [504,504,504,504,504,504];
freqs = [1/6,1/6,1/6,1/6,1/6,1/6];

% There is only one audio TTL pulse 
checkCountTRs = 112;

% Mask bounds
glintFrameMaskSet = {...
    [229   281   225   332], ... % Selected frame 1956
    [224   290   234   329], ... % 2519
    [210   290   248   327], ... % 10790
    [116   198   214   142], ... % 6825
    [131   320   326   298], ... % 10790
    [129   318   326   298], ... % 1919
    [174   283   283   334], ... % 971
    [163   303   295   318], ... % 3064
    [157   306   300   315], ... % 253
    [159   432   297   185], ... % 261
    [162   440   294   178], ... % 2470
    [163   445   301   180], ... % 1527
    }; 
pupilFrameMaskSet = {...
    [179   253   175   275], ...
    [191   259   176   284], ...
    [165   251   179   266], ...
    [117   113   127   206], ...
    [135   256   175   209], ...
    [86    244   252   264], ...
    [103   236   218   263], ...
    [100   230   200   216], ...
    [71    239   218   205], ...
    [80   285   193   131], ...
    [114   350   212   136], ...
    [95    340   223   130], ...
    };

pupilCircleThreshSet = [0.0200, 0.0160, 0.0250, 0.0450, 0.0310, 0.0530, 0.0490, 0.0400, 0.0300, 0.0400, 0.0490, 0.0370, 0.0350];

pupilRangeSets = {[39 60], [41 50], [39 70], [47 58], [47 57], [55 67], [58 71], [42 60], [44 57], [63 80], [50 70], [44 54], [45 60]};

candidateThetas = {[7*pi/4],[5*pi/4],[5*pi/4],[3*pi/2; pi],[3*pi/2],[3*pi/2; pi],[5*pi/4],[5*pi/4],[pi],[3*pi/2; 5*pi/4; pi],[pi; 5*pi/4],[pi; 5*pi/4]};

ellipseEccenLBUB = {[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.35 0.45],[0.4 0.5]};

glintPatchRadius = [40,20,20,20,20,20,20,20,20,20,20,30];

minRadiusProportion = [0, 0, 0, 0.5, 0, 0, 0, 0, 0, 0, 0.5, 0.5];

cutErrorThreshold = [1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 2, 1.5];

ellipseAreaLB = [5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000];
ellipseAreaUP = [15000, 15000, 15000, 15000, 15000, 15000, 15000, 15000, 15000, 50000, 15000, 15000];
%% Loop through video name stems get each video and its corresponding masks
% This is for running videos in different order
vids = [10];
for ii = vids

%numVids = length(videoNameStems);
%for ii = 1:numVids

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
        'glintGammaCorrection',1.3,...
        'glintThreshold',0.5,...
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

