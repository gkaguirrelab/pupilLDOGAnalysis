clear
close all

dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');
dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing');
protocol = 'PupilPhotoLDOG';

subjects = { ...
    'N344','N349',...
    '2350','2353','2356',...
    'Z663','Z665','Z666'};

groupColors = {[0.5 0.5 0.5],[0 0 1],[1 0 0]};
plotColors = {groupColors{1},groupColors{1}, ...
              groupColors{2},groupColors{2}, groupColors{2} ...
              groupColors{3},groupColors{3}, groupColors{3}};

directionLabels = {'LightFlux','LplusS','RodMel'};

figure()

for ii = 1:length(directionLabels)
    p = {};    
    subplot(1,3,ii)
    for ss = 1:length(subjects)
        resultPath = fullfile(dataOutputDirRoot,'Experiments','OLApproach_TrialSequenceMR',protocol,'EyeTracking',subjects{ss});
        sessList = dir(fullfile(resultPath,'*-*-*'));
        resultPath = fullfile(sessList(end).folder,sessList(1).name);
        fileName = ['pupil_' directionLabels{ii} '_1-6Hz_BothEyes_fourierFit.mat'];
        load(fullfile(resultPath,fileName),'amplitude','phase','semAmplitude','semPhase');
        
        p{ss} = polarplot(phase,amplitude,'o', 'MarkerEdgeColor','k','MarkerFaceColor',plotColors{ss});
        pax = gca;
        pax.RLim = [0 8];
        pax.ThetaLim = [0 90];
        hold on
        polarplot(linspace(phase-semPhase,phase+semPhase,10),repmat(amplitude,1,10),'-k')
        polarplot([phase phase],[amplitude-semAmplitude,amplitude+semAmplitude],'-k')       
    end
    legend([p{1},p{3},p{6}],'WT','RCD1', 'XLRPA2');
    hold off
    title(directionLabels{ii}) 
end

