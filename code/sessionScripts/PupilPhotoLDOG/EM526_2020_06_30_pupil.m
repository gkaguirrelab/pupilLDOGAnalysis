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
    'pupil_LightFlux_1-6Hz_RightEyeStim_01',...
    'pupil_RodMel_1-6Hz_RightEyeStim_02',...
    'pupil_LplusS_1-6Hz_RightEyeStim_03',...
    'pupil_LightFlux_1-6Hz_LeftEyeStim_04',...
    };

% Stimulus properties
sets = {[1],[2],[3],[4]};
labels = {'pupil_LightFlux_1-6Hz_RightEyeStim','pupil_RodMel_1-6Hz_RightEyeStim_02',...
    'pupil_LplusS_1-6Hz_RightEyeStim_03', 'pupil_LightFlux_1-6Hz_LeftEyeStim_04'};
durations = [504,504,504,504];
freqs = [1/6,1/6,1/6,1/6];

% There is only one audio TTL pulse 
checkCountTRs = 112;

% Mask bounds
glintFrameMaskSet = {...
    [106   412   311   166], ... 
    [84   177   305   297], ... 
    [90   238   300   261], ... 
    [141   279   222   207], ... 
    }; 
pupilFrameMaskSet = {...
    [1     178  175     1], ... % 268
    [1     24   158   175], ... %194
    [1     5   107   102], ... %1371
    [90   147   150   173], ... % 202 94 start
    };

pupilCircleThreshSet = [0.0200, 0.0160, 0.0250, 0.0450, 0.0310, 0.0530, 0.0490, 0.0400, 0.0300, 0.0400, 0.0490, 0.0370, 0.0350];

pupilRangeSets = {[39 60], [41 50], [39 70], [47 60], [47 57], [55 67], [58 71], [42 60], [44 57], [63 80], [50 70], [44 54], [45 60]};

candidateThetas = {[7*pi/4; pi/2],[5*pi/4],[5*pi/4],[3*pi/2; pi],[3*pi/2],[3*pi/2; pi],[5*pi/4],[5*pi/4],[pi],[3*pi/2; 5*pi/4; pi],[pi; 5*pi/4],[pi; 5*pi/4; 3*pi/2]};

ellipseEccenLBUB = {[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.3 0.5],[0.35 0.45],[0.4 0.5]};

glintPatchRadius = [30,20,20,20,20,20,20,20,20,20,20,30];

minRadiusProportion = [0, 0, 0, 0.5, 0, 0, 0, 0, 0, 0, 0.5, 0.5];

cutErrorThreshold = [1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 1.5, 2, 1.5];

ellipseAreaLB = [1000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000];
ellipseAreaUP = [15000, 15000, 15000, 50000, 15000, 15000, 15000, 15000, 15000, 50000, 15000, 50000];
glintThreshold = [0.3, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.3];
%% Loop through video name stems get each video and its corresponding masks
% This is for running videos in different order
vids = [12];
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

