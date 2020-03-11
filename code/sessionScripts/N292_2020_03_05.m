%% N292 2020-03-05
%
% The pupil analysis pre-processing pipeline for an LDOG session.
%


%% Set up these parameters for the session

% Subject and session params.
pathParams.Subject = 'N292';
pathParams.Date = '2020-03-05';
pathParams.Session = 'session_3';

% The approach and protocol. These shouldn't change much
pathParams.Approach = 'OLApproach_TrialSequenceMR';
pathParams.Protocol = 'MRFlickerLDOG';

% The names of the videos to process
videoNameStems = {'pupil_LightFLux','pupil_L+S','pupil_RodMel','pupil_LightFLux02','pupil_L+S02','pupil_RodMel02'};

% Define mask bounds. To do so, run the routine:
%{
	glintFrameMask = defineCropMask('','startFrame',10)
	pupilFrameMask = defineCropMask('','startFrame',10)
%}
% and select one of the videos when the file picker GUI appears. For the
% glint, put a tight box around the glint. For the pupil, define a mask
% area that safely contains the pupil at its most dilated. Enter the values
% here:
glintFrameMask = [222   215   170   330];
pupilFrameMask = [186   124    69   239];






%% Analysis parameters
% To adjust these parameters for a given session, use the utility:
%{
    estimatePipelineParamsGUI('','TOME')
%}
% And select one of the raw data .mov files.

sessionKeyValues = {...
    'glintFrameMask',glintFrameMask,...
    'glintGammaCorrection',1,...
    'glintThreshold',0.5,...
    'pupilFrameMask',pupilFrameMask,...
    'pupilRange',[42 51],...
    'pupilCircleThresh',0.0180,...
    'glintPatchRadius',40,...
    'candidateThetas',[pi],...
    'ellipseTransparentUB',[640,480,20000,0.5, pi],...
    'cutErrorThreshold',1.5,...
    };


%% Call the pipeline
pupilPipeline(pathParams,videoNameStems,sessionKeyValues);

