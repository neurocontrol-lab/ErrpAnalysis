function Accuracy = classifyMI(SelFeatInd, fvec_rh, lbl_rh, fvec_lh, lbl_lh, SubjectID)

% Create dataset
data1 = fvec_rh(:,SelFeatInd);
data2 = fvec_lh(:,SelFeatInd);

data = [data1;data2];
lbl = [lbl_rh;lbl_lh];

% Shuffle data
ShuffleInd = randperm(size(data,1));
data = data(ShuffleInd,:);
lbl = lbl(ShuffleInd);

% Split data in training/testing sets
TrainPrct = 0.5;
TrainSplit = floor(TrainPrct*size(data,1));
traindata = data(1:TrainSplit,:);
trainlbl = lbl(1:TrainSplit);
testdata = data(TrainSplit+1:end,:);
testlbl = lbl(TrainSplit+1:end);

[Class] = classify(testdata,traindata,trainlbl,'linear');
Accuracy = 100*sum(Class==testlbl)/length(testlbl);
disp(['Classification accuracy on testing set for subject ' ...
    SubjectID ': ' num2str(Accuracy) ' %']);
% Optimally, check effects of size and subsets of feature selection and
% attempt cross validation
