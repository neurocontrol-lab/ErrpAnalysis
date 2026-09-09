function cfg = config()
% Explicit settings for the new pipeline; independent of the current folder.
cfg.root = fileparts(fileparts(mfilename('fullpath')));
cfg.subjects = {'spe30','mle01'}; % S1, S2; run manifest remains auditable
cfg.runPattern = '*_run*_EEG.easy'; % excludes training and stimulation
cfg.fs = 500;
cfg.channels = {'P3','PO3','PO7','CP5','CP1','Cz','FCz','FC1'};
cfg.band = [1 20];
cfg.filterOrder = 4;
cfg.window = [-1 1]; % half-open: [-1,1), 1000 samples
cfg.baseline = [-0.2 0]; % half-open; deliberate choice, not legacy first-sample baseline
cfg.maxAmplitudeUV = 100;
cfg.lossGuardSeconds = 2; % conservative exclusion around loss; not a proven filter bound
cfg.output = fullfile(cfg.root,'output','pipeline_v1');
cfg.alpha = 0.05;
end
