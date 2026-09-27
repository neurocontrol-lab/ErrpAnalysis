function test_force_integration()
% Optional quick check on one real epoch; no pipeline outputs are written.
here=fileparts(mfilename('fullpath')); addpath(here,fullfile(here,'helpers'));
cfg=config(); addpath(cfg.forceRoot,fullfile(cfg.forceRoot,'mex-files'));
previous=dwtmode('status','nodisp'); dwtmode('sym','nodisp');
cleanup=onCleanup(@() dwtmode(previous,'nodisp'));
f=dir(fullfile(cfg.baselineOutput,'processed','*_mle01_pre_run1_EEG.mat'));
assert(~isempty(f),'Run stage 2 for v1 before this optional check');
p=load(fullfile(f(1).folder,f(1).name)); k=find(p.trials.accepted,1);
x=squeeze(p.epochs(k,:,:)); loc=load(fullfile(cfg.root,'chanlocs8.mat'));
[y,status]=clean_epoch_force(x,cfg,loc.chanlocs8);
assert(status=="ok" && isequal(size(y),size(x)) && all(isfinite(y),'all'));
x(1)=NaN; [y,status]=clean_epoch_force(x,cfg,loc.chanlocs8);
assert(status=="invalid_input" && all(isnan(y),'all'));
fprintf('PASS: real-epoch cleaning and invalid-input handling.\n');
end
