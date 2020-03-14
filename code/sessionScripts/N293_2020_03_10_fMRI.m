%% N293_2020_03_10_fMRI
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
    'LplusS1_AP_01',...
    'LminusS2_PA_02',...
    'RodMelS3_AP_03',...
    'LminusS4_PA_04',...
    'RodMel5_AP_05',...
    'LplusS6_PA_06',...
    'RodMel7_AP_07',...
    'LplusS8_PA_08',...
    'LminusS9_AP_09'};

% There are TTL pulses for each TR
checkCountTRs = 144;


% Mask bounds
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


%% Call the pipeline
pupilPipeline(pathParams,videoNameStems,sessionKeyValues);

