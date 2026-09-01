function [gapsd_motorAttempt, gapsd_Rest] = showGrandAverages(lpsd, labels, ChannelLabels, freqs)

%%Captures distinct labels of trials
UniqueLabels = unique (labels);
MoveEvent = setdiff (UniqueLabels,3)

%%Previous attempt with unique labels
if (ismember (1, UniqueLabels))
    motlabel = 1;
else 
    motlabel = 2; 
end

for pch=1:size(lpsd,2)
   gapsd_motorAttempt(pch,:) = mean( squeeze(lpsd(find(labels==motlabel),pch,:)), 1);
    gapsd_Rest(pch,:) = mean( squeeze(lpsd(find(labels==3),pch,:)), 1);
end
figure();
%% 
%% 
subplot(2,1,1);plot(freqs,gapsd_motorAttempt);xlabel('Frequency (Hz)');ylabel('logPSD');legend(ChannelLabels);
subplot(2,1,2);plot(freqs,gapsd_Rest);xlabel('Frequency (Hz)');ylabel('logPSD');