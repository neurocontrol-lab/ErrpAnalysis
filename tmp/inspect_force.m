% Read-only compatibility inspection; no analysis products are written.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'Code','FORCe'),fullfile(root,'Code','FORCe','mex-files'));
v=ver; disp(string({v.Name})');
d=load(fullfile(root,'Code','FORCe','EEG_example.mat'));
fprintf('Example variables:\n'); disp(fieldnames(d));
c=load(fullfile(root,'chanlocs8.mat')); ch=c.chanlocs8;
for k=1:numel(ch)
    fprintf('%d %s X=%g Y=%g Z=%g\n',k,ch(k).labels,ch(k).X,ch(k).Y,ch(k).Z);
end
f=dir(fullfile(root,'output','pipeline_v1','processed','*_mle01_pre_run1_EEG.mat'));
p=load(fullfile(f(1).folder,f(1).name));
k=find(p.trials.accepted,1); x=squeeze(p.epochs(k,:,:))';
fprintf('Compatibility input: previously accepted/baselined epoch, not proposed production input.\n');
for w=1:2
    z=x(:,(w-1)*500+(1:500)); tic;
    y=FORCe(z,500,ch,0); elapsed=toc;
    fprintf('8-channel window %d: size=%dx%d finite=%d time=%g inputRMS=%g outputRMS=%g\n',w,size(y,1),size(y,2),all(isfinite(y),'all'),elapsed,sqrt(mean(z.^2,'all')),sqrt(mean(y.^2,'all')));
end
fprintf('72-sample MI dispatch check:\n');
try; mi((1:72)',sin((1:72)')); catch ME; disp(ME.message); end
for name={'S1extractedData.mat','S2extractedData.mat'}
    fprintf('GA %s\n',name{1}); q=whos('-file',fullfile(root,'GA_data',name{1}));
    for j=1:numel(q); fprintf('%s %s %s\n',q(j).name,mat2str(q(j).size),q(j).class); end
end
f=dir(fullfile(root,'cleanErrPotData','mle01','*.mat'));
q=load(fullfile(f(1).folder,f(1).name)); fprintf('Legacy example: %s\n',f(1).name); disp(fieldnames(q));
if isfield(q,'RunResults')
    disp(fieldnames(q.RunResults));
    for name={'Trials','CleanTrials','Labels','freq'}
        if isfield(q.RunResults,name{1}); fprintf('%s size=%s\n',name{1},mat2str(size(q.RunResults.(name{1})))); end
    end
end
