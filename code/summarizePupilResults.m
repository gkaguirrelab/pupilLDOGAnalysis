% summarizePupilResults
clear
close all

dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');
dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing');
protocol = 'PupilPhotoLDOG';

groups = { ...
    {'N344','N347'},...
    {'Z665','Z663'},...
    {'EM529','EM543','EM522','EM526'},...
    {'2353'} };

groupLabels = {'WT','XLPRA2+','RHOT4R+','RCD1'};

directionLabels = {'LightFlux','LplusS','RodMel'};
eyeLabels = {'Left','Right'};

for gg = 1:length(groupLabels)
    subList = groups{gg};
    figHandle = figure();
    for ss = 1:length(subList)
        subplot(1,4,ss);
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
        
        bar(categorical(directionLabels),Y')
        ylabel('% pupil change');
        title(subList{ss});
        
    end
end