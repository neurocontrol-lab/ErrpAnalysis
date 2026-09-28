clear all;close all;clc;

%% Add biosig toolbox for loading data
%addpath(genpath('/home/ido/New DOC Literature/DOCpipeline/Code/biosig/'));
%addpath(genpath('/home/ido/New DOC Literature/DOCpipeline/Code/code/utilities/'));
addpath(genpath('/home/simis/Git/ErrpAnalysis/biosig/'));
addpath(genpath('/home/simis/Git/ErrpAnalysis/utilities/'));

%% Useful init
load('chanlocs8.mat');
NChEEG = 8;
ChannelLabels = {'P3','PO3', 'PO7','CP5','CP1','CZ', 'FCZ', 'FC1'};

% SubID = {'ara13', 'bal08', 'bpe06', 'bro19', 'cna07', 'cve01', 'den12', 'eab31', 'emo24', 'fbo09', ...
%          'gba12', 'gcr27', 'lbo12', 'ldu23', 'med17', 'mka24', 'mle01', 'nfu22', 'nsh23', 'rle13', ...
%          'sga12', 'spe30', 'sto20', 'yle21'};

%SubID = {'mle01', 'spe30'};
SubID = {'mle01'};
%SubID = {'spe30'};

 % SubID = {'yle21'};'vco27'

%% Load Laplacian matrix for
lap = load('laplacian16.mat');
lap16 = lap.lap; clear lap;

%% Find all BDF data
%SavePath = '/home/ido/New DOC Literature/DOCpipeline/Code/code/cleanErrPotData/';
SavePath = '/home/simis/Git/ErrpAnalysis/cleanErrPotData/';


%loop over entire db represented as Subject list
for sub=1:length(SubID)
    FileNames = {};
    
    %find only .easy files
    RunDir = dir([SavePath '/' SubID{sub}]);
    RunDir = RunDir(3:end-1);
    FileNames = {RunDir.name};
    
    matfiles = dir([SavePath '/' SubID{sub} '/*mat']);
    matfiles = {matfiles.name};

    %% Load data, extract trials and labels
    CleanTrials = [];
    UnCleanTrials = [];
    Labels = [];
    Pos = [];
    Typ = [];
    InRejectTrial = [];

    for f=1:length(matfiles)

        %load mat file into variable data
        %h_val_bonferroniA(sub,ch,:) =
        %p_ta(sub,ch,:)<pthreshold_bonferroni;@

        load([SavePath SubID{sub} '/' matfiles{f}(1:end-4) '.mat']);
                        
        SamplingRate =RunResults.freq;
        
        CleanTrials = [CleanTrials ; RunResults.CleanTrials]; %RunResults.cleanTrials
        UnCleanTrials = [UnCleanTrials; RunResults.Trials]; %RunResults.contrials
        Labels = [Labels; RunResults.Labels];
        Pos = [Pos; RunResults.pos];
        Typ = [Typ; RunResults.typ];
     
    end
    saveFileName = sprintf('/home/simis/Git/ErrpAnalysis/CleanTrials.mat', SavePath, SubID{sub});
    save(saveFileName, 'CleanTrials', '-v7.3');
    saveFileName = sprintf('/home/simis/Git/ErrpAnalysis/Labels.mat', SavePath, SubID{sub});
    save(saveFileName, 'Labels', '-v7.3');

    %% Pre-processing (per trial)
    for tr=1:size(CleanTrials,1)
        
        %% Artifact removal (FORCe from Lab 2 do it at home as it takes long and this data is not particularly noisy)
        
        %% Spatial filtering
        %% CAR -- DOES IT HELP?
        %Trials(tr,:,:) = car(squeeze(Trials(tr,:,:)));
     
         %% Laplacian -- DOES IT HELP?
         %Trials(tr,:,:) = laplacianSP(squeeze(Trials(tr,:,:)),lap16);
        
        
        %% Spectral filtering
        
        % Apply band-pass filter in [1, 10] Hz
        % Trials(tr,:,:) = filtfilt(b,a,squeeze(Trials(tr,:,:)));
    
        %% Baseline
        % DC removal -- IS IT NECESSARY GIVEN the 0-baselining?
        CleanTrials(tr,:,:) = removeDC(squeeze(CleanTrials(tr,:,:)));
        
        %% DeTrend
        % Trials(tr,:,:) = detrend(squeeze(Trials(tr,:,:)));
        
        %% Baseline, remove potential at t=0
        CleanTrials(tr,:,:) = squeeze(CleanTrials(tr,:,:)) - repmat(squeeze(CleanTrials(tr,1,:))',size(CleanTrials,2),1);

                
    end
    disp('a');

    InRejectTrial = find(max((max(CleanTrials,[],3)),[],2)>100);
    disp(InRejectTrial);
    % CleanTrials(InRejectTrial, :, :) = [];

    %% check for amplitude greater than 100, and reject them
    %since err potentials can't be greater than 10uv by Literature
    for tr=1:size(CleanTrials,1)
        if(max(CleanTrials(tr,:))>100)
            InRejectTrial(tr) = 1;
        else
            InRejectTrial(tr) = 0;
        end
    end

    %remove trials of high indices and normalise length of labels with same
    CleanTrials(find(InRejectTrial==1), :, :) = []; 
    Labels(find(InRejectTrial==1)) = [];


    %% perfom t-test on Correct and Errorneous vs correct trials with Bonferroni correction
   
    pthreshold_bonferroni = 0.05/size(CleanTrials,2)*1000; % Because we used 1000 sample at the end
    for ch=1:size(CleanTrials,3)
        for tm=1:size(CleanTrials,2)
            [h_t(sub,ch,tm), p_t(sub,ch,tm)] = ttest2(CleanTrials(Labels==1,tm,ch), CleanTrials(Labels==2,tm,ch));
        end 
        try
            h_val_bonferroni(sub,ch,:) = p_t(sub,ch,:)<pthreshold_bonferroni;
        catch
            disp("passing2")
        end
    end

    disp(pthreshold_bonferroni) % added by me


    % WinGA = size(CleanTrials,2);
    % WinGA = WinGA/2:WinGA/2+SamplingRate;
   

    %% Grand averages for each channel
    for ch=1:NChEEG
        try
            GACorrect(sub,ch,:) = mean(CleanTrials(Labels==1,:,ch),1);
            GAError(sub,ch,:) = mean(CleanTrials(Labels==2,:,ch),1);
        catch
            disp('passing')
            continue;
        end
        
        for tm=1:size(GACorrect,3)
            [h_ta(sub,ch,tm), p_ta(sub,ch,tm)] = ttest2(GACorrect(sub,ch,tm), GAError(sub,ch,tm));
        end 
        h_val_bonferroniA(sub,ch,:) = p_ta(sub,ch,:)<pthreshold_bonferroni;
        
        
        subplot(4,2,ch);plot([1:size(CleanTrials,2)]/SamplingRate,squeeze(GACorrect(sub,ch,:)),'b');
        hold on;
        subplot(4,2,ch);plot([1:size(CleanTrials,2)]/SamplingRate,squeeze(GAError(sub,ch,:)),'r');
        subplot(4,2,ch);plot([1:size(CleanTrials,2)]/SamplingRate,squeeze(GAError(sub,ch,:)-GACorrect(sub,ch,:)),'k');

        for j=1:size(h_val_bonferroni,3)
           if(h_val_bonferroni(sub,ch,j)==1)
               subplot(4,2,ch); plot(j/SamplingRate,GAError(sub,ch,j), '*r', 'MarkerSize', 4, 'LineWidth',5);
           end    
        end

        for k=1:size(h_val_bonferroniA,3)
           if(h_val_bonferroniA(sub,ch,k)==1)
               subplot(4,2,ch); plot(k/SamplingRate,GAError(sub,ch,k), '*b', 'MarkerSize', 4, 'LineWidth',5);
           end    
        end
        hold off;
        legend({'Correct','Error','Difference'});
        title(ChannelLabels{ch});
        xlabel('Time [s]', 'FontSize', 20);
        ylabel('Potential [uV]', 'FontSize', 20);
             

    end
        
     %pause(1); %pause for one second. so that we don't save same fig for new subject
     %mysavefig(['/home/ido/New DOC Literature/DOCpipeline/Code/code/ErrPotJpeg/' 'figure1' SubID{sub} '.png'])
     %mysavefig(['/home/simis/Git/ErrpAnalysis/' 'figure1' SubID{sub} '.png'])
     %pause(1);

     close all;
 

end
%% Extend result to confusion matrix (i.e., analytically find the type of errors
%% committed by the classifier)

%% GA plot second version (my version)
% Grand averages and significance plotting


%% Adjusting the time vector
% Assuming the original time vector is in seconds and spans from 0 to 4 seconds
% with t=2 being the current point of interest (onset of the movement)
originalTimeVector = (0:(size(CleanTrials, 2)-1)) / SamplingRate; % Replace with your actual time vector
adjustedTimeVector = originalTimeVector - 2; % Adjusting so t=0 corresponds to the onset of the movement

%% Narrowing down to [-1, +1] seconds around the movement onset
plotRange = (adjustedTimeVector >= -1) & (adjustedTimeVector < 1);

%% Subject-wise GA plots with adjustments
GACorrectRange = GACorrect(:,:,plotRange);
GAErrorRange = GAError(:,:,plotRange);
GADifferenceRange = GACorrectRange - GAErrorRange;
adjustedTimeVectorRange = adjustedTimeVector(plotRange);
h_val_bonferroniRange = h_val_bonferroni(:,:,plotRange);
displayRange = [-1, 1]; % Set the range from -1 to 1 seconds around the new t=0


figure(1);
[ha, ~] = tight_subplot(4, 2, [0.06 0.02], [0.1 0.1], [0.1 0.1]);

for ch = 1:NChEEG
    axes(ha(ch));
    
    % Only plotting the narrowed down range
    plot(adjustedTimeVectorRange, squeeze(GACorrectRange(sub, ch, :)), 'b', 'LineWidth', 3);
    hold on;
    plot(adjustedTimeVectorRange, squeeze(GAErrorRange(sub, ch, :)), 'r', 'LineWidth', 3);
    plot(adjustedTimeVectorRange, squeeze(GADifferenceRange(sub, ch, :)), 'k', 'LineWidth', 3);
    
    % Adding vertical lines at t=0 and t=0.0 seconds
    xline(0, '--', 'LineWidth', 3, 'Color', 'magenta'); 
    xline(0.50, '--', 'LineWidth', 3, 'Color', 'green'); 
    
    % Adding Bonferroni significance markers
    for j = 1:size(h_val_bonferroniRange, 3)
        if h_val_bonferroniRange(sub, ch, j) == 1 
    
            plot(adjustedTimeVectorRange(j), squeeze(GADifferenceRange(sub, ch, j)), 'oy', 'MarkerSize', 4, 'LineWidth', 1);
            
        end
    end


    %ylabel('Potential (uV)', 'FontSize', 17);
%     hold off;
%     xlim([-1, 1]); % Narrowing down the x-axis to [-1, +1] seconds
%     set(gca, 'FontSize', 14, 'FontWeight', 'bold');
%     title(ChannelLabels{ch}];
      hold off;
      xlim(displayRange);
      set(gca, 'FontSize', 14, 'FontWeight', 'bold');
      title(ChannelLabels{ch}, 'FontSize', 14);
end



%% Provided by Simis
% clear all;close all;clc;
% addpath(genpath('C:\Users\seraf\Git\mmbci\utilities\'))
% %load S1extractedData.mat
% load S2extractedData.mat
% for ch=1:8
% [myMax(ch) myMaxInd(ch)] = max(extractedData(ch).GADifference);
% [myMin(ch) myMinInd(ch)] = min(extractedData(ch).GADifference);
% end
% [totMax, totMaxInd] = max(myMax);
% [totMin, totMinInd] = min(myMin);
% maxtimeind = myMaxInd(totMaxInd);
% mintimeind = myMinInd(totMinInd);
% extractedData(1).timeVector(mintimeind)
% extractedData(1).timeVector(maxtimeind)
% for ch=1:8
% showMax(ch) = extractedData(ch).GADifference(maxtimeind);
% showMin(ch) = extractedData(ch).GADifference(mintimeind);
% end
% chanlocs8tdcs = load('chanlocs8tdcs.mat');
% chanlocs64 = load('chanlocs64.mat');
% max64values = zeros(1,64);
% max64values(ismember({chanlocs64.chanlocs.labels},{chanlocs8tdcs.chanlocs.labels})) = showMax;
% min64values = zeros(1,64);
% min64values(ismember({chanlocs64.chanlocs.labels},{chanlocs8tdcs.chanlocs.labels})) = showMin;
% figure(1);
% topoplot(max64values, chanlocs64.chanlocs, 'maplimits', [totMin totMax], 'electrodes', 'labels');colorbar
% figure(2);
% topoplot(min64values, chanlocs64.chanlocs, 'maplimits', [totMin totMax], 'electrodes', 'labels');colorbar

load('chanlocs8.mat');
% Now immediately use 'chanlocs8' for your topoplot calls
[maxVal, maxInd] = max(squeeze(GAError(1,8,:)) - squeeze(GACorrect(1,8,:)));
[minVal, minInd] = min(squeeze(GAError(1,8,:)) - squeeze(GACorrect(1,8,:)));

figure(2);
subplot(2,1,1);
topoplot(squeeze(GAError(1,:,minInd)) - squeeze(GACorrect(1,:,minInd)), chanlocs8, 'maplimits', [-4 3]);
cb = colorbar;
set(cb, 'FontSize', 20, 'FontWeight', 'bold'); % Adjust font size and weight
t = title('Min Diff');
t.FontSize = 20; 

subplot(2,1,2);
topoplot(squeeze(GAError(1,:,maxInd)) - squeeze(GACorrect(1,:,maxInd)), chanlocs8, 'maplimits', [-4 3]);
cb = colorbar;
set(cb, 'FontSize', 20, 'FontWeight', 'bold'); % Adjust font size and weight
t = title('Max Diff');
t.FontSize = 20; 
%%
%secind way to show top-plots
figure(3);
% already loaded GACorrect, GAError, chanlocs8, and defined SamplingRate and CleanTrials
% Define the variables for the time points want to create topoplots
newZeroPoint = 2; % Movement onset is at t=2 seconds
samplingRateInSeconds = 1 / SamplingRate;
timeVector = ((1:size(CleanTrials, 2)) / SamplingRate) - newZeroPoint;
displayRange = [-1, 1]; % Set the range from -1 to 1 seconds around the new t=0
timePointsForTopoplots = [0, 0.05]; % Example: t=0 and t=0.05 seconds
for tp = 1:length(timePointsForTopoplots)
    % Find the index corresponding to the time point
    [~, timePointIndex] = min(abs(timeVector - timePointsForTopoplots(tp)));

    % Extract the data for all channels at this time point
    dataForTopoplot = squeeze(GAError(1, :, timePointIndex) - GACorrect(1, :, timePointIndex));

    % Create a figure for each topoplot
    figure;
    topoplot(dataForTopoplot, chanlocs8, 'maplimits', 'absmax', 'electrodes', 'labels');
    colorbar;
    title(sprintf('Topoplot for t=%.2f s', timePointsForTopoplots(tp)));
end

% need to fix this part as it is not working as expected.
% Find the maximum difference across all channels and time points within the range
% diffMatrix = squeeze(GAError(1, :, :) - GACorrect(1, :, :));
% [~, maxDiffIndices] = max(abs(diffMatrix(:, timeVector >= displayRange(1) & timeVector <= displayRange(2))), [], 2);
% maxDiffTimePoints = timeVector(maxDiffIndices);
% 
% % Generate topoplots for maximum differences at each channel
% for ch = 1:NChEEG
%     % Extract data at the time point of maximum difference for this channel
%     dataForTopoplot = squeeze(GAError(1, ch, maxDiffIndices(ch)) - GACorrect(1, ch, maxDiffIndices(ch)));
% 
%     % Create a figure for the topoplot
%     figure;
%     topoplot(dataForTopoplot, chanlocs8, 'maplimits', 'absmax', 'electrodes', 'labels');
%     colorbar;
%     title(sprintf('Topoplot for channel %s at t=%.2f s (max diff)', ChannelLabels{ch}, maxDiffTimePoints(ch)));
% end



%% Downsample all trials, check if the ErrP shape is captured adequately
for tr=1:size(CleanTrials)
    DTrials(tr,:,:) = downsample(CleanTrials(tr,:,:),64);
end


%% Feature selection    
% Feature ranking with Fisher Score
% FS = fisherscore(reshape(CleanTrials,[size(CleanTrials,1) ...
%     size(CleanTrials,2)*size(CleanTrials,3)]),Labels); 
% FSMat = reshape(FS,size(CleanTrials,2),size(CleanTrials,3))'; 

% Feature ranking with R2
R2 = rsquared(reshape(CleanTrials,[size(CleanTrials,1) ...
    size(CleanTrials,2)*size(CleanTrials,3)]),Labels); 
R2Mat = reshape(R2,size(CleanTrials,2),size(CleanTrials,3))'; 

% Feature ranking with CVA -- Use onle on downsampled data, takes too long
% CVA = cva(reshape(DTrials,[size(DTrials,1) ...
%     size(DTrials,2)*size(DTrials,3)]),Labels); 
% CVAMat = reshape(CVA,size(DTrials,2),size(DTrials,3))'; 


% figure(3);
% subplot(2,1,1);imagesc(FSMat);colorbar;
% set(gca,'XTick',[1 128 256 384 512]);
% set(gca,'XTicklabel',[0 0.25 0.5 0.75 1]);
% set(gca,'YTick',[1:NChEEG]);
% set(gca,'YTicklabel',ChannelLabels);
% subplot(2,1,2);imagesc(R2Mat);colorbar;
% set(gca,'XTick',[1 128 256 384 512]);
% set(gca,'XTicklabel',[0 0.25 0.5 0.75 1]);
% set(gca,'YTick',[1:NChEEG]);
% set(gca,'YTicklabel',ChannelLabels);

% 
%% Remove Fz as it is susceptible to artifacts
DTrials(:,:,1) = [];

% Leave-one-out (LOO) cross-validation 
% Calculate class weights based on frequencies
classLabels = unique(Labels);
classWeights = sum(Labels == classLabels') ./ numel(Labels); % Calculate class frequencies
classWeights = 1 ./ classWeights; % Inverse to make less frequent class have higher weight
classWeights = classWeights / sum(classWeights); % Normalize so that sum of weights is 1
% Leave-one-out (LOO) cross-validation 
NFeatures = 4;
LDAPrediction = zeros(size(Labels)); % Initialize prediction vector
for tr=1:size(DTrials,1) 
    IndTrain = setdiff([1:size(DTrials,1)],tr);
    
    %% Feature selection + classification
    % Perform feature selection and train classifier on training samples (trials)
    R2 = rsquared(reshape(DTrials(IndTrain,:),[length(IndTrain) ...
    size(DTrials,2)*size(DTrials,3)]), Labels(IndTrain)); 
    R2(isnan(R2)) = 0;
    [~, sortind] = sort(R2,'descend');
    
    TrainSet = DTrials(IndTrain,:);
    TrainSet = TrainSet(:,sortind(1:NFeatures));
    
    TestSample = DTrials(tr,:);
    TestSample = TestSample(sortind(1:NFeatures));
    LDAModel = fitcdiscr(TrainSet, Labels(IndTrain), 'DiscrimType', 'quadratic', ...
                         'Prior', classWeights);
    %LDAModel = fitcdiscr(TrainSet,Labels(IndTrain),'DiscrimType','quadratic');
    
    LDAPrediction(tr) = predict(LDAModel,TestSample);
    
%     SVMModel = fitcsvm(TrainSet,Labels(IndTrain),'Standardize',true,'KernelFunction','RBF',...
%     'KernelScale','auto');
%     SVMPrediction(tr) = predict(SVMModel,TestSample);
    
    %% Dimensionality reduction + classification
%     TrainSet = DTrials(IndTrain,:);
%     MeanTrainSet = mean(TrainSet); % I will need this since PCA centers the data
%     [PCs,TrainSetPCA,EigenValues] = pca(TrainSet);
%     
%     %% Just confirming that TrainSetPCA is simply: Centered TrainSet x PCs (which it is, indeed)
%     %MyTrainSetPCA = (TrainSet - repmat(MeanTrainSet,size(TrainSet,1),1))*PCs;
%     % Center TestSet (TestSaple in this case) and project it with PCA
%     PCATestSample = (DTrials(tr,:) - MeanTrainSet)*PCs(:,1:NFeatures);
%     
%     %% Train classifiers with 10 first PCs
%     PCA_LDAModel = fitcdiscr(TrainSetPCA(:,1:NFeatures),Labels(IndTrain),'DiscrimType','quadratic'); % Play with linear/quadratic
%     PCA_LDAPrediction(tr) = predict(PCA_LDAModel,PCATestSample);
%     PCA_SVMModel = fitcsvm(TrainSetPCA(:,1:NFeatures),Labels(IndTrain),'Standardize',true,'KernelFunction','RBF',...
%     'KernelScale','auto');
%     PCA_SVMPrediction(tr) = predict(PCA_SVMModel,PCATestSample);
    
end

% Calculate accuracy (% of correct classifier predictions)
LDAAccuracy = 100*sum(LDAPrediction' == Labels)/length(Labels);
fprintf('LDA Accuracy with class weights: %.2f%%\n', LDAAccuracy);
%SVMAccuracy = 100*sum(SVMPrediction' == Labels)/length(Labels);
% PCA_LDAAccuracy = 100*sum(PCA_LDAPrediction' == Labels)/length(Labels);
% PCA_SVMAccuracy = 100*sum(PCA_SVMPrediction' == Labels)/length(Labels);

% Assuming LDAPrediction contains your predicted labels
% and Labels contains the true labels

% Convert labels to categorical if they're not already
trueLabelsCat = categorical(Labels);
predictedLabelsCat = categorical(LDAPrediction);

%% SVM with weighted sum
% Assuming DTrials and Labels are your features and labels respectively
% Let's first divide the data into training and testing sets (if you haven't already)
% cv = cvpartition(size(DTrials, 1), 'KFold', 10); % 10-fold CV
% 
% % Calculate class weights based on frequencies for weighted SVM
% classLabels = unique(Labels);
% classWeights = sum(Labels == classLabels') ./ numel(Labels);
% classWeights = 1 ./ classWeights;
% weightVector = [classWeights(1), classWeights(2)]; % Adjust based on your class labels
% 
% % Grid search for SVM regularization parameter
% CValues = logspace(-3, 3, 7); % Example range for C, adjust as needed
% minLoss = inf;
% bestC = NaN;
% 
% for C = CValues
%     % Initialize a template SVM model with the current C value and class weights
%     t = templateSVM('KernelFunction', 'linear', 'BoxConstraint', C, ...
%                     'ClassWeights', weightVector);
%                 
%     % Train the SVM model using the template with cross-validation
%     svmModel = fitcecoc(DTrials, Labels, 'Learners', t, 'CVPartition', cv);
%     
%     % Evaluate the cross-validated loss
%     cvLoss = kfoldLoss(svmModel);
%     
%     if cvLoss < minLoss
%         minLoss = cvLoss;
%         bestC = C;
%     end
% end
% 
% fprintf('Best C Value: %f with loss: %f\n', bestC, minLoss);
% 
% % Train final model on the entire dataset with the selected C
% finalTemplate = templateSVM('KernelFunction', 'linear', 'BoxConstraint', bestC, ...
%                             'ClassWeights', weightVector);
% finalSVMModel = fitcecoc(DTrials, Labels, 'Learners', finalTemplate);

% Here you can use finalSVMModel to make predictions on new data
% predLabels = predict(finalSVMModel, newFeatureData);



%%
% Plot confusion matrix
figure(4);
% % Create the confusion matrix chart and capture the handle
% cm = confusionchart(trueLabelsCat, predictedLabelsCat, ...
%     'RowSummary', 'row-normalized', ...
%     'ColumnSummary', 'column-normalized');
% 
% % Get the figure handle containing the confusion matrix chart
% fig = ancestor(cm, 'figure');
% % Apply a grayscale colormap to the figure
% colormap(fig, 'gray');
% % Access the confusion matrix underlying axes
% ax = cm.Parent;
% cm.FontSize = 50;
% %title(ax, 'Confusion Matrix for LDA Classifier', 'FontSize', 15);

% Assuming 'Labels' contains actual classes and 'LDAPrediction' contains predicted classes
% Convert numerical labels to categorical with appropriate class names
trueLabelsCat = categorical(Labels, [1, 2], {'Correct', 'Error'});
predictedLabelsCat = categorical(LDAPrediction, [1, 2], {'Correct', 'Error'});

% Plot confusion matrix with normalization
figure;
cm = confusionchart(trueLabelsCat, predictedLabelsCat, ...
    'Normalization', 'row-normalized', ...
    'RowSummary', 'row-normalized', ...
    'ColumnSummary', 'column-normalized');

% Customize font size
cm.FontSize = 40; % Adjust this value as needed

% Customize the title
title('Confusion Matrix for LDA Classifier');

% Apply a grayscale colormap
colormap('gray');

% Display class labels more clearly
cm.XLabel = 'Predicted Class';
cm.YLabel = 'Actual Class';




%%



% Topoplots
% Create figures for min and max difference topoplots
% figure('Name', 'Minimum Differences');
% load('chanlocs8.mat');
% for ch = 1:NChEEG
%     % Calculate min difference for this channel
%     [minVal, minInd] = min(squeeze(GAError(1,ch,:)) - squeeze(GACorrect(1,ch,:)));
%     
%     % Plot topoplot for min difference
%     subplot(2, 4, ch);
%     topoplot(squeeze(GAError(1,:,minInd)) - squeeze(GACorrect(1,:,minInd)), chanlocs8, 'maplimits', [-10 10]);
%     cb = colorbar;
%     set(cb, 'FontSize', 20, 'FontWeight', 'bold'); % Adjust font size and weight
%     %title(['Min Diff - ' ChannelLabels{ch}]);
%     t = title([ChannelLabels{ch}]);
%     t.FontSize = 20;    
% end
% 
% figure('Name', 'Maximum Differences');
% for ch = 1:NChEEG
%     % Calculate max difference for this channel
%     [maxVal, maxInd] = max(squeeze(GAError(1,ch,:)) - squeeze(GACorrect(1,ch,:)));
%     
%     % Plot topoplot for max difference
%     subplot(2, 4, ch);
%     topoplot(squeeze(GAError(1,:,maxInd)) - squeeze(GACorrect(1,:,maxInd)), chanlocs8, 'maplimits', [-10 10]);
%     cb = colorbar;
%     set(cb, 'FontSize', 20, 'FontWeight', 'bold'); % Adjust font size and weight
%     %title(['Max Diff - ' ChannelLabels{ch}]);
%     t = title([ChannelLabels{ch}]);
%     t.FontSize = 20;     
% end

% Begin your existing code










