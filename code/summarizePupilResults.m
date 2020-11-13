% summarizePupilResults
clear
close all

dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');
dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing');
protocol = 'PupilPhotoLDOG';

groups = { ...
    {'N344','N347'},...
    {'Z665','Z663'},...
    {'EM529','EM543','EM522'},...
    {'2353'} };

groupLabels = {'WT','XLPRA2+','RHOT4R+','RCD1'};

directionLabels = {'LightFlux','LplusS','RodMel'};
eyeLabels = {'Left','Right'};

    figHandle = figure();

for gg = 1:length(groupLabels)
    subList = groups{gg};
    for ss = 1:length(subList)
        subplot(length(groupLabels),4,ss+(gg-1)*length(groupLabels));
        resultPath = fullfile(dataOutputDirRoot,'Experiments','OLApproach_TrialSequenceMR',protocol,'EyeTracking',subList{ss});
        sessList = dir(fullfile(resultPath,'*-*-*'));
        resultPath = fullfile(sessList(end).folder,sessList(end).name);
        Y = nan(2,length(directionLabels));
        for dd = 1:length(directionLabels)
            for ee = 1:length(eyeLabels)
                fileName = ['pupil_' directionLabels{dd} '_1-6Hz_' eyeLabels{ee} 'EyeStim_fourierFit.mat'];
                if exist(fullfile(resultPath,fileName),'file')
                    load(fullfile(resultPath,fileName),'amplitude');
                    Y(ee,dd) = amplitude;
                elseif exist(fullfile(resultPath,'session_1',fileName),'file')
                    load(fullfile(resultPath,'session_1',fileName),'amplitude');
                    Y(ee,dd) = amplitude;                    
                end
            end
        end
        
        bar(categorical(directionLabels),nanmean(Y',2))
        ylabel('% pupil change');
        ylim([0 3]);
        title(subList{ss});
        
    end
end