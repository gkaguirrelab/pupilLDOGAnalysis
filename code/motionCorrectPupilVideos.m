function motionCorrectPupilVideos(grayVideo, glintFileName, fixedFrame, outputPath, startFrame, nFrames) 
%
% Using the glint location in a good frame as the reference this function 
% registers all frames to that good frame. Only does a translation (3DOF). 
%
% Syntax:
%  motionCorrectPupilVideos(grayVideo, glintFileName, goodGlintFrame, outputPath) 
%
% Description:
%   Simple motion correction for video drifting. Does not perform a perfect 
%  motion correction as it only uses 3 DOF. Helps with setting up a good
%  frame mask.
% 
%
% Inputs:
%   grayVideo             - String. Path to the input gray video.
%   glintFileName         - String. Path to the glint file.
%   fixedFrame            - Number. A good frame where the glint is visible
%                           and the pupil is in a good location. Used as 
%                           the fixed image for the registration.
%   outputPath            - String. Path to the output folder and filename.
%
% Outputs:
%   none
%

% Load the video and the glint
rawVideoGray = VideoReader(grayVideo);

% Video properties
frameRate = rawVideoGray.FrameRate;
Duration = rawVideoGray.Duration;
frameCount = rawVideoGray.Numframes;
Height = rawVideoGray.Height;
Width = rawVideoGray.Width;
Quality = 100;

glintFile = load(glintFileName);

% Get the glint location on the selected good frame
fixedY = glintFile.glintData.Y(fixedFrame);
fixedX = glintFile.glintData.X(fixedFrame);

% Create the video object and open it
vidfile = VideoWriter(outputPath);
vidfile.FrameRate = frameRate;
% vidfile.Height = Height;
% vidfile.Width = Width;
vidfile.Quality = Quality;
open(vidfile);

% If nframes is infinite, set it to the video frame number
if nFrames == Inf
    lastFrame = rawVideoGray.NumFrames;
else
    lastFrame = startFrame + nFrames - 1;
end

%% Loop through each frame and calculate the coordinate difference 
fprintf('Correcting motion')
for ii = startFrame:lastFrame
    % Load the frame
    frame = read(rawVideoGray, ii);

    % Get the row and column
    y = glintFile.glintData.Y(ii);
    x = glintFile.glintData.X(ii);
    
    % Calculate the difference between the coordinates
    x_diff = fixedX - x;
    y_diff = fixedY - y;
    
    % If the difference is NaN (usually means a blink) set coordinate
    % difference to 0
    if isnan(x_diff) || isnan(y_diff)
        x_diff = 0;
        y_diff = 0;
    end
    % Translation
    frame = imtranslate(frame, [x_diff, y_diff]);
    % Write the video and show it on the screen
    writeVideo(vidfile, frame)
%     imshow(frame)
%     hold on
%     plot(fixedX, fixedY, 'r+')
%     hold off
%     pause(0.001)
end

% Close the video
close(vidfile);
