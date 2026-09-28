function [trials, labels, SamplingFreq] = getTrials(GDFPath, SubjectID)

disp(['Extracting trials for all runs of subject ' SubjectID]);

% SamplingRate
% Receives path to the EEG data (GDF file recorded with the CNBI MI offline
% protocol), the SubjectID of the subject whose data must be processed, and the
% EEG data smapling rate, and returns a 3D matrix trials: Ntrials x NSamples x NChannels 
% and a vector of size Ntrials with the trial labels

% Find GDF files of this subject. One GDF file corresponds to a single run
Runs = dir(GDFPath);

% Iterate through all subject runs, extracting the trial in each of those
% and concatenating them into a single "trials" variable for this subject
trials = [];
labels = [];
for run=1:length(Runs)
    try

    % Load GDF file with biosig toolbox
    [data, header] = sload([GDFPath '/' Runs(run).name]);
    
    SamplingFreq = header.SampleRate;

    if (sum(sum(isnan(data))) > 0)
        continue
    end
    catch
        disp('corrupt file, skipping')
        continue
    end

    %Remove the trigger channel
    data(:,end) = []; 

    % Find beginning of each trial (781 event)
    Ind781 = find(header.EVENT.TYP == 781);

    % Trial extraction
    pos = header.EVENT.POS;
    cf = find(header.EVENT.TYP==781);
    cue = cf-1; 

    if (length(cf) < 15)
    % Too few trials
    %RunResults.fine = 0;
    disp('Too few trials, skipping...');
    return;
    end

    trials = [];
    for tr = 1 : length(pos)
        if (header.EVENT.TYP(tr)==781)
            if (header.EVENT.TYP(tr-1)==783)
                trials(end+1,:) = [header.EVENT.POS(tr) header.EVENT.POS(tr)+ 4*sfreq];

            else
                trials(end+1,:) = [header.EVENT.POS(tr)+ 4*sfreq header.EVENT.POS(tr)+ 7*sfreq];
            end

        end

    end

    %trials = [pos(cf) pos(cf)+4*sfreq pos(cf)+4*sfreq pos(cf)+7*sfreq]; 
    %trials = [pos(cf) pos(cf)+7*sfreq]; 
    labels = header.EVENT.TYP(cue);

    %trialsFES = trials(:,4);
    %labels_NotFES = trial(:,1:3)

    In783 = find(labels == 783);
    labels(In783) = 2;

    InMove = union(find(labels == 769),find(labels == 770)) ;
    labels(InMove) = 1;

end

%     % Build 2D trial matrix
%     % Data are from 781 + DUR, (should be around 4 seconds)
%     % Drop trigger channel
% 
%     % Empty variables of interest
%     runtrials = [];
%     runlabels = [];
%     for tr=1:length(Ind781)
% 
%         start = header.EVENT.POS(Ind781(tr));
% 
%         % Fix duration
%         %dur = header.EVENT.DUR(Ind781(tr));
%         dur = 4*SamplingFreq-1;
% 
%         runtrials(tr,:,:) = data(start:start+dur,1:16); 
%         runlabels(tr) = header.EVENT.TYP(Ind781(tr)-1);
% 
%     end
%     % Make labels a column vector
%     runlabels = runlabels';
% 
%     % Concatenate trials of different runs for this subject
%     trials = cat(1,trials, runtrials);
%     labels = cat(1,labels, runlabels);
% 
% end
% 
% % Relabel labels
% labels(labels==769)=1; % 769 denotes Left Hand Motor Attempt, remap to 1
% labels(labels==770)=2; % 770 denotes Right Hand Motor Attempt, remap to 2
% %labels(labels==771)=3; % 771 denotes Feet MI, remap to 3
% labels(labels==783)=3; % 783 denotes Resting/Idling, remap to 3

disp('a')