% summarizePupilResults
clear
close all

dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');
dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing');
protocol = 'PupilPhotoLDOG';

groups = { ...
    {'N344','N347','N349'},...
    {'Z663','Z665','Z666'},...
    {'2350','2353','2356'},...
    {'EM529','EM543','EM522'},...
    {'EM529','EM543'} };

session = { 1, 1, 1, 1, 2 };

groupLabels = {'WT','XLPRA2+','RCD1','RHOT4R+ PreInjury','RHOT4R+ PostInjury'};

directionLabels = {'LightFlux','LplusS','RodMel'};
yLimSet = {[-6 6],[-2 2],[-1 1]};
eyeLabels = {'Left','Right'};


figHandle1 = figure();
figHandle2 = figure();

for gg = 1:length(groupLabels)
    subList = groups{gg};
    
    % Loop through first and find the maximum length timeseries per group
    tsMaxLength = [];
    for ss = 1:length(subList)
        resultPath = fullfile(dataOutputDirRoot,'Experiments','OLApproach_TrialSequenceMR',protocol,'EyeTracking',subList{ss});
        sessList = dir(fullfile(resultPath,'*-*-*'));
        resultPath = fullfile(sessList(end).folder,sessList(session{gg}).name);
        for dd = 1:length(directionLabels)
            for ee = 1:length(eyeLabels)
                fileName = ['pupil_' directionLabels{dd} '_1-6Hz_' eyeLabels{ee} 'EyeStim_fourierFit.mat'];
                if exist(fullfile(resultPath,fileName),'file')
                    load(fullfile(resultPath,fileName),'ts');
                    if length(ts)>length(tsMaxLength)
                        tsMaxLength = ts;
                    end
                elseif exist(fullfile(resultPath,'session_1',fileName),'file')
                    load(fullfile(resultPath,'session_1',fileName),'ts');
                    if length(ts)>length(tsMaxLength)
                        tsMaxLength = ts;
                    end
                end
            end
        end
    end
    
    tsMat = nan(length(subList)*length(eyeLabels),length(ts));
    yAll = {tsMat,tsMat,tsMat};
    yFitAll = {tsMat,tsMat,tsMat};
    
    for ss = 1:length(subList)
        
        resultPath = fullfile(dataOutputDirRoot,'Experiments','OLApproach_TrialSequenceMR',protocol,'EyeTracking',subList{ss});
        sessList = dir(fullfile(resultPath,'*-*-*'));
        resultPath = fullfile(sessList(end).folder,sessList(session{gg}).name);
        Y = nan(length(eyeLabels),length(directionLabels));
        
        for dd = 1:length(directionLabels)
            for ee = 1:length(eyeLabels)
                fileName = ['pupil_' directionLabels{dd} '_1-6Hz_' eyeLabels{ee} 'EyeStim_fourierFit.mat'];
                if exist(fullfile(resultPath,fileName),'file')
                    load(fullfile(resultPath,fileName),'amplitude','y','yFit');
                    Y(ee,dd) = amplitude;
                    yAll{dd}((ss-1)*2+ee,1:length(y))=y;
                    yFitAll{dd}((ss-1)*2+ee,1:length(yFit))=yFit;
                elseif exist(fullfile(resultPath,'session_1',fileName),'file')
                    load(fullfile(resultPath,'session_1',fileName),'amplitude','ts','yFit');
                    Y(ee,dd) = amplitude;
                    yAll{dd}((ss-1)*2+ee,1:length(y))=y;
                    yFitAll{dd}((ss-1)*2+ee,1:length(yFit))=yFit;
                end
            end
        end
        
        data = nanmean(Y',2);
        
        set(0,'CurrentFigure', figHandle1)
        subplot(length(groupLabels),5,ss+(gg-1)*length(groupLabels));
        bar(categorical(directionLabels),data);
        ylabel('% pupil change');
        ylim([0 10]);
        title(subList{ss});
    end
    
    set(0,'CurrentFigure', figHandle2)
    for dd=1:length(directionLabels)
        subplot(length(groupLabels),length(directionLabels),(gg-1)*length(directionLabels)+dd);
        samps = floor(length(ts)/720);
        yCycle=nan(samps,720);
        yFitCycle=nan(samps,720);
        for ii=1:samps
            yCycle(ii,:)=nanmean(yAll{dd}(:,(ii-1)*720+1:ii*720));
            yFitCycle(ii,:)=nanmean(yFitAll{dd}(:,(ii-1)*720+1:ii*720));
        end
        plot(0:1/60:12-1/60,nanmean(yCycle),'.','Color',[0.75 0.75 0.75]);
        hold on
        plot(0:1/60:12-1/60,nanmean(yFitCycle),'-r','Linewidth',2);
        xlim([0 12]);
        xlabel('time [seconds]')
        ylim([-5 5]);
        ylabel('pupil change [%]')
        box off

    end
    foo=1;
    
end

