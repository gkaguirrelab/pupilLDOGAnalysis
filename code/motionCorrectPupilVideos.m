function motionCorrectPupilVideos(grayVideo, glintFileName, fixedFrame, outputPath) 
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
glintFile = load(glintFileName);

% Get the glint location on the selected good frame
row_val = glintFile.glintData.Y(fixedFrame);
col_val = glintFile.glintData.X(fixedFrame);

% Create the video object and open it
vidfile = VideoWriter(outputPath,'MPEG-4');
open(vidfile);

%% Loop through each frame and calculate the coordinate difference 
for ii = 1:rawVideoGray.NumFrames
    frame = read(rawVideoGray, ii);
    r = glintFile.glintData.Y(ii);
    c = glintFile.glintData.X(ii);
    if isnan(r)
        row_val_diff = 0;
        col_val_diff = 0;
    else
        row_val_diff = row_val - r ;
        col_val_diff = col_val - c;        
    end 
    % Translation
    frame = imtranslate(frame, [row_val_diff, col_val_diff]);
    % Write the video and show it on the screen
    writeVideo(vidfile, frame)
    imshow(frame)
end

% Close the video
close(vidfile);
