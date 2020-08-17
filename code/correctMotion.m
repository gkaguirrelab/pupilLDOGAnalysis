function correctMotion(videoName, glintFileName, fixedFrame, varargin) 
% Registers all frames to a target frame. Only does a translation (3DOF). 
%
% Syntax:
%  correctMotion(videoName, glintFileName, fixedFrame, outputPath) 
%
% Description:
%  Simple motion correction algorithm for fixing video motion. This script
%  only performs translation (3DOF) and therefore it might not solve more 
%  complicated motion problems stemming from camera angle changes. The 
%  algorithm uses glints to do the registration, therefore the glint should 
%  be visible even in the bad (displaced) frames and must be caught by the 
%  findGlint function previously. If a NaN value is encountered in a frame,
%  that frame is considered a blink and therefore not corrected. 
%  WARNING: In any pupil analysis script, findGLint function should be 
%  called again after this function as some of the frames will be displaced   
%
% Inputs:
%   videoName             - String. Path to the input gray video.
%   glintFileName         - String. Path to the glint file.
%   fixedFrame            - Number. A good frame where the glint is visible
%                           and the pupil is in a good location. Used as 
%                           the fixed image for the registration.
%
% Optional key/value pairs (display and I/O):
%  'verbose'              - Logical. Default false.
%  'displayMode'          - If set to true, a continuously updated video
%                           displays the glint fitting. This is slow but
%                           may be useful while setting analysis params.
%
% Optional key/value pairs (flow control)
%  'nFrames'              - Analyze fewer than the total number of frames.
%  'startFrame'           - First frame from which to start the analysis.
%  'outputPath'           - Used to save the result to somewhere else rather
%                           than the Dropbox directory that contains the 
%                           input video
%
% Outputs:
%   none
%

%% parse input and define variables
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;

% Required
p.addRequired('grayVideoName',@isstr);
p.addRequired('glintFileName',@isstr);
p.addRequired('fixedFrame',@isnumeric);

% Optional display and I/O params
p.addParameter('verbose',false,@islogical);
p.addParameter('displayMode',false,@islogical);

% Optional flow control params
p.addParameter('nFrames',Inf,@isnumeric);
p.addParameter('startFrame',1,@isnumeric);
p.addParameter('outputPath', 'Dropbox' ,@isstr);

% parse
p.parse(videoName, glintFileName, fixedFrame, varargin{:})

%% Prepare input and output video

% Load the video and the glint
rawVideoGray = VideoReader(videoName);
glintFile = load(glintFileName);

% Get the glint location on the selected fixed frame
fixedX = glintFile.glintData.X(fixedFrame);
fixedY = glintFile.glintData.Y(fixedFrame);

% Set some video properties for the new video
frameRate = rawVideoGray.FrameRate;
Quality = 100;

% Construct the output file name 
if strcmp(p.Results.outputPath, 'Dropbox')
    outputPath = [videoName(1:end-4) '_' 'corrected'  '.'  'avi'];
else
    outputPath  = p.Results.outputPath;
end

% Create a video object with these properties and open it
vidfile = VideoWriter(outputPath);
vidfile.FrameRate = frameRate;
vidfile.Quality = Quality;
open(vidfile);

% If nframes is set to infinite, set lastFrame to the video frame number
if p.Results.nFrames == Inf
    endFrame = rawVideoGray.NumFrames;
else
    endFrame = p.Results.startFrame + p.Results.nFrames - 1;
end

%% Loop through each frame and calculate the coordinate difference 

% alert the user
if p.Results.verbose
    tic
    fprintf(['correcting motion ' char(datetime('now')) '\n']);
    fprintf('| 0                      50                   100%% |\n');
    fprintf('.\n');
end

for ii = p.Results.startFrame:endFrame
    
    % increment the progress bar
    if p.Results.verbose && mod(ii,round(p.Results.nFrames/50))==0
        fprintf('\b.\n');
    end
    
    % Load the frame
    frame = read(rawVideoGray, ii);

    % Get the x-y coordinates of the glint at that frame
    x = glintFile.glintData.X(ii);
    y = glintFile.glintData.Y(ii);
 
    % Calculate the difference between the fixed and moving coordinates
    x_diff = fixedX - x;
    y_diff = fixedY - y;
    
    % If the difference is NaN (usually means a blink) set coordinate
    % difference to 0, so no translation occurs 
    if isnan(x_diff) || isnan(y_diff)
        x_diff = 0;
        y_diff = 0;
    end
    
    % So the translation
    frame = imtranslate(frame, [x_diff, y_diff]);
    
    % Write the video
    writeVideo(vidfile, frame)
    
    % Show the written frame on the screen if displayMode is set
    if p.Results.displayMode
        imshow(frame)
        hold on
        plot(fixedX, fixedY, 'r+')
        hold off
        pause(0.001)
    end
end

% Close the new video
close(vidfile);

% report completion of analysis
if p.Results.verbose
    toc
    fprintf('\n');
end
