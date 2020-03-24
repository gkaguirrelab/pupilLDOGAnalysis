%% Define project
projectName = 'LDOG_data';
protocol = 'MRScotoLDOG';
subjectId = 'EM426';
scanDate = '2020-03-12';

% What to plot
validationNumber = 'median';
whatToPlot = 'noSPD';

[~, userID] = system('whoami');
userID = strtrim(userID);

if ismac 
    homeFolder = '/Users';
    dropboxFolderName = 'Dropbox\ \(Aguirre-Brainard\ Lab\)';
elseif isunix 
    homeFolder = '/home';
    dropboxFolderName = 'Dropbox (Aguirre-Brainard Lab)';
else
    error('Your operating system is not supported')
end

directionObj = fullfile(homeFolder, userID, dropboxFolderName , projectName,...
    'Experiments','OLApproach_TrialSequenceMR',protocol, 'DirectionObjects',...
    subjectId, scanDate, 'directionObject.mat');

results = visulizeValidation(directionObj, validationNumber, whatToPlot);
