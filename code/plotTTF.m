


%% Create a TTF figure
%stimSets = {[1 4],[2 5],[3 6]};
stimSets = {[2 4],[1 6],[3 5]};
stimLabels = {'lightFlux [c = 95%]','L+S [c = 35%]','RodMel [ c = 50% ]'};
stimColors = {'k','r','c'};

if showPlots
    figure
        set(gcf,'color','w');
end

for ss = 1:length(stimSets)
    A = amplitudes(stimSets{ss}(1),:);
    B = amplitudes(stimSets{ss}(2),:);
    delta = phases(stimSets{ss}(1),:)-phases(stimSets{ss}(2),:);
    y = sqrt(A.^2+B.^2 + (2.*A.*B.*cos(delta)))./2;
    
    h(ss) = plot([1 2 3],y,'o','Color',stimColors{ss});
    hold on
    plot([1 2 3],y,'-','Color',stimColors{ss});
end
xlim([0 4])
xticks([1 2 3])
xticklabels({'1/24','1/12','1/6'})
xlabel('stimulus freq [Hz]');
ylabel('pupil response [% change]');
legend(h,stimLabels);
title('Pupil response for N292');