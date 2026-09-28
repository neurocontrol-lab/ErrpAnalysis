function [] = showSpectrumComparisonRHLH(lpsd, labels, channelindex, ChannelLabels)

%%Captures distinct labels of trials
UniqueLabels = unique (labels);
MoveEvent = setdiff (UniqueLabels,3)

%%Previous attempt with unique labels
if (ismember (1, UniqueLabels))
    motlabel = 1;
else 
    motlabel = 2; 
end

Data_rh = squeeze(lpsd(labels== motlabel,channelindex,:));
Data_lh = squeeze(lpsd(labels== motlabel,channelindex,:));
Mrh = mean(Data_rh,1);
Mlh = mean(Data_lh,1);
Srh = std(Data_rh,1);
Slh = std(Data_lh,1);
figure();
h1 = shadedErrorBar(1:23,Mrh,Srh,'r',1);
hold on;
h2 = shadedErrorBar(1:23,Mlh,Slh,'b',1);
xlabel('Frequency band (Hz)');
ylabel('Log-PSD');
set(gca,'XTick',[1:1:23]);
set(gca,'XTickLabel',[4:2:48],'FontSize',20);
legend([h1.mainLine h2.mainLine],{'Right-hand Motor Attempt','Left-hand Motor Attempt'},'FontSize',20);
hold off;
title(['Channel ' ChannelLabels{channelindex}]);


