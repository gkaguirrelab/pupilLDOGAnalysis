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
    'pupil_LplusS_1-6Hz_LeftEyeStim_12'};

% Stimulus properties
sets = {[1 7],[2 8],[3 9],[4 10],[5 11],[6 12]};
labels = {'pupil_LightFlux_1-6Hz_RightEyeStim','pupil_RodMel_1-6Hz_RightEyeStim','pupil_LplusS_1-6Hz_RightEyeStim',...
    'pupil_LightFlux_1-6Hz_LeftEyeStim', 'pupil_RodMel_1-6Hz_LeftEyeStim', 'pupil_LplusS_1-6Hz_LeftEyeStim'};
durations = [504,504,504,504,504,504];
freqs = [1/6,1/6,1/6,1/6,1/6,1/6];

% There is only one audio TTL pulse 
checkCountTRs = 112;

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


%% Call the pre-processing pipeline
pupilPipeline(pathParams,videoNameStems,sessionKeyValues);


%% Call the frequency fitting pipeline
%fourierFitPipeline(pathParams,videoNameStems,sets,labels,durations,freqs);

