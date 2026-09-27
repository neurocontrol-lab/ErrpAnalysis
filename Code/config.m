function cfg = config(version)
if nargin<1, version="v2"; end
assert(ismember(string(version),["v1","v2"]),'Unknown pipeline version');
% Explicit settings for the new pipeline; independent of the current folder.
cfg.root = fileparts(fileparts(mfilename('fullpath')));
folders=dir(fullfile(cfg.root,'data'));
folders=folders([folders.isdir] & ~startsWith({folders.name},'.'));
cfg.subjects={};
for k=1:numel(folders)
    if ~isempty(dir(fullfile(folders(k).folder,folders(k).name,'*_run*_EEG.easy')))
        cfg.subjects{end+1}=folders(k).name;
    end
end
cfg.sessions = {'pre','post','retest'};
cfg.runPattern = '*_run*_EEG.easy'; % excludes training and stimulation
cfg.fs = 500;
cfg.channels = {'P3','PO3','PO7','CP5','CP1','Cz','FCz','FC1'};
cfg.band = [1 20];
cfg.filterOrder = 4;
cfg.window = [-1 1]; % half-open: [-1,1), 1000 samples
cfg.baseline = [-0.2 0]; % half-open; deliberate choice, not legacy first-sample baseline
cfg.maxAmplitudeUV = 100;
cfg.lossGuardSeconds = 2; % conservative exclusion around loss; not a proven filter bound
cfg.version = char(version);
cfg.output = fullfile(cfg.root,'output',['pipeline_' cfg.version]);
cfg.baselineOutput = fullfile(cfg.root,'output','pipeline_v1');
cfg.parsedOutput = fullfile(cfg.baselineOutput,'parsed'); % shared event metadata for v1/v2
cfg.cleaningMethod = 'none';
cfg.maxRunsPerSubjectSession = Inf;
if strcmp(cfg.version,'v2')
    cfg.subjects = {'spe30','mle01'};
    cfg.cleaningMethod = 'FORCe';
end
cfg.forceRoot = fullfile(cfg.root,'Code','FORCe');
cfg.alpha = 0.05;
end
