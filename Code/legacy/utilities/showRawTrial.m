function [] = showRawTrial(trials, ChannelLabels, channelindex, trialindex)

figure();
plot(trials(trialindex,:,channelindex));
title(['Raw data channel ' ChannelLabels{channelindex}...
    ', trial ' num2str(trialindex)]);
