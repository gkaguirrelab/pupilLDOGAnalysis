%% N293_2020_03_10_pupil
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
pathParams.Subject = 'N293';
pathParams.Date = '2020-03-10';
pathParams.Session = 'session_3';

% The approach and protocol. These shouldn't change much
pathParams.Approach = 'OLApproach_TrialSequenceMR';
pathParams.Protocol = 'MRFlickerLDOG';

% The names of the videos to process
videoNameStems = {...
    'pupil_L+S_01',...
    'pupil_LightFlux_02',...
    'pupil_RodMel_03',...
    'pupil_LightFlux_04',...
    'pupil_RodMel_05',...
    'pupil_L+S_06'};

% Stimulus properties
sets = {[1 6],[2 4],[3 5]};
labels = {'pupil_L+S','pupil_LightFlux','pupil_RodMel'};
durations = [504,504,504];
freqs = [1/6,1/12,1/12];

% There is only one audio TTL pulse 
checkCountTRs = 1;

% Mask bounds
% To pick good numbers here, use the utility:
%{
    defineCropMask
%}
glintFrameMask = [120   384   285   163];
pupilFrameMask = [33   256   123    63];


%% Analysis parameters
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
    'pupilRange',[67 82],...
    'pupilCircleThresh',0.053,...
    'glintPatchRadius',50,...
    'candidateThetas',[pi],...
    'ellipseTransparentUB',[640,480,20000,0.5, pi],...
    'cutErrorThreshold',1.5,...
    };


%% Call the pre-processing pipeline
pupilPipeline(pathParams,videoNameStems,sessionKeyValues);


%% Call the frequency fitting pipeline
fourierFitPipeline(pathParams,videoNameStems,sets,labels,durations,freqs);

