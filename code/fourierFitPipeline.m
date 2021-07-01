function fourierFitPipeline(pathParams,videoNameStems,sets,labels,durations,freqs)



%% Add the DropBox information to the pathParams
% Get the DropBox base directory
dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');

% set common path params
pathParams.dataSourceDirRoot = fullfile(dropboxBaseDir,'LDOG_data');
pathParams.dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing');

% Define the outputBaseDir
outputBaseDir = fullfile(pathParams.dataOutputDirRoot, ...
    'Experiments',...
    pathParams.Approach,...
    pathParams.Protocol,...
    'EyeTracking',...
    pathParams.Subject,...
    pathParams.Date,...
    pathParams.Session);

% If the outputBaseDir does not exist, make it
if ~exist(outputBaseDir)
    error('This directory should already exist and contain the pre-processed videos');
end


% Loop through the sets
for ss = 1:length(sets)
    freq = freqs(ss);
    videoPathNameStems = cellfun(@(x) fullfile(outputBaseDir,x),videoNameStems(sets{ss}),'UniformOutput',false);
    [amplitude,phase,figHandle,ts,y,yFit]=fitFourier(videoPathNameStems,freq,durations(ss),0,freqs(ss)/4);
    
    % Save the result
    resultFile = fullfile(outputBaseDir,[labels{ss} '_fourierFit.mat']);
    save(resultFile,'freq','amplitude','phase','ts','y','yFit');
    
    % Save the plot
    plotFile = fullfile(outputBaseDir,[labels{ss} '_fourierFit.pdf']);
    saveas(figHandle,plotFile);
    close(figHandle);
    
end

end
