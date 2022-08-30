% summarizePupilResults
clear
close all

dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');
dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing');
protocol = 'PupilPhotoLDOG';

groups = { ...
    {'N344','N349'},...
    {'2350','2353','2356'},...
    {'Z663','Z665','Z666'}};

session = { 1, 1, 1, 1, 2 };

groupLabels = {'WT','RCD1','XLPRA2'};

directionLabels = {'LightFlux','LplusS','RodMel'};
eyeLabels = {'Left','Right'};


figHandle1 = figure();
figHandle2 = figure();

scatterList = struct();

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
        
        data = nanmedian(Y',2);
        
        set(0,'CurrentFigure', figHandle1)
        subplot(length(groupLabels),5,ss+(gg-1)*length(groupLabels));
        bar(categorical(directionLabels),data);
        ylabel('% pupil change');
        ylim([0 10]);
        title(subList{ss});
        
        scatterList.(directionLabels{1}).(['subject_' subList{ss}]) = data(1);
        scatterList.(directionLabels{2}).(['subject_' subList{ss}]) = data(2);
        scatterList.(directionLabels{3}).(['subject_' subList{ss}]) = data(3);        
    end
    
    set(0,'CurrentFigure', figHandle2)
    for dd=1:length(directionLabels)
        subplot(length(groupLabels),length(directionLabels),(gg-1)*length(directionLabels)+dd);
        samps = floor(length(ts)/720);
        yCycle=nan(samps,720);
        yFitCycle=nan(samps,720);
        for ii=1:samps
            yCycle(ii,:)=nanmedian(yAll{dd}(:,(ii-1)*720+1:ii*720));
            yFitCycle(ii,:)=nanmedian(yFitAll{dd}(:,(ii-1)*720+1:ii*720));
        end
        yVals = nanmedian(yCycle);
        yVals = yVals - mean(yVals);        
        plot(0:1/60:12-1/60,yVals,'.','Color',[0.75 0.75 0.75]);
        hold on
        yVals = nanmedian(yFitCycle);
        yVals = yVals - mean(yVals);        
        plot(0:1/60:12-1/60,yVals,'-r','Linewidth',2);
        yFitCycleIQR = iqr(yFitCycle);
        plot(0:1/60:12-1/60,yVals + yFitCycleIQR,'-','Color',[1,0.5,0.5],'Linewidth',1);
        plot(0:1/60:12-1/60,yVals - yFitCycleIQR,'-','Color',[1,0.5,0.5],'Linewidth',1);
        xlim([0 12]);
        ylim([-7.5 7.5]);
        if dd == 1 && gg == 1
        xlabel('time [seconds]')
        ylabel('pupil change [%]')
        end
        if gg == 1
            title(directionLabels{dd})
        end
        if dd == length(directionLabels)
            xlimVals=get(gca,'XLim');
            ylimVals=get(gca,'YLim');
            ht = text(1.15*xlimVals(1)+1.15*xlimVals(2),0*ylimVals(1)+0.5*ylimVals(2),groupLabels{gg},...
                'FontWeight','bold','HorizontalAlignment', 'center');
            set(ht,'Rotation',-90)            
        end
        box off

    end
    foo=1;
    
end

figure
set(gcf, 'Position', [217.8000  477.0000  853.6000  217.6000])
groupColors = {[0.5 0.5 0.5],[0 0 1],[1 0 0]};
for ii = 1:length(directionLabels)
    subplot(1,3,ii)
    title(directionLabels{ii})
    ylim([0 10])
    ylabel('% pupil change')
    hold on
    fn = fieldnames(scatterList.(directionLabels{ii}));
    for pp = 1:length(fn)
        if contains(fn{pp}, 'N')
            scatter(categorical(groupLabels(1)), scatterList.(directionLabels{ii}).(fn{pp}) ,'MarkerEdgeColor','k','MarkerFaceColor',groupColors{1})
        elseif contains(fn{pp}, '23')
            scatter(categorical(groupLabels(2)), scatterList.(directionLabels{ii}).(fn{pp}) ,'MarkerEdgeColor','k','MarkerFaceColor',groupColors{2})            
        elseif contains(fn{pp}, 'Z')
            scatter(categorical(groupLabels(3)), scatterList.(directionLabels{ii}).(fn{pp}) ,'MarkerEdgeColor','k','MarkerFaceColor',groupColors{3})        
        end
    end
    hold off
end
    