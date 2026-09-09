% Stage 3: subject averages and trial-level statistics, without feature selection.
codeDir=fileparts(mfilename('fullpath')); addpath(codeDir); cfg=config();
out=fullfile(cfg.output,'figures'); if ~isfolder(out), mkdir(out); end
for s=1:numel(cfg.subjects)
    files=dir(fullfile(cfg.output,'processed',['*_' cfg.subjects{s} '_*_EEG.mat']));
    assert(~isempty(files),'No processed runs for %s',cfg.subjects{s});
    X=[]; labels=[];
    for f=1:numel(files)
        d=load(fullfile(files(f).folder,files(f).name)); keep=d.trials.accepted;
        X=cat(1,X,d.epochs(keep,:,:)); labels=[labels;d.trials.label(keep)]; %#ok<AGROW>
    end
    assert(sum(labels==1)>=2 && sum(labels==2)>=2,'Too few retained trials');
    correct=squeeze(mean(X(labels==1,:,:),1)); displaced=squeeze(mean(X(labels==2,:,:),1));
    difference=displaced-correct; p=nan(size(correct));
    for ch=1:8
        [~,p(:,ch)]=ttest2(X(labels==1,:,ch),X(labels==2,:,ch),'Dim',1,'Vartype','equal');
    end
    significant=p<cfg.alpha/numel(p);
    fig=figure('Visible','off','Position',[100 100 1100 1000]); tiledlayout(4,2);
    for ch=1:8
        nexttile; plot(d.time,correct(:,ch),'b',d.time,displaced(:,ch),'r',d.time,difference(:,ch),'k'); hold on;
        plot(d.time(significant(:,ch)),difference(significant(:,ch),ch),'.','Color',[.7 .5 0]);
        xline(0,'--m'); xline(.5,'--g'); title(d.channels{ch}); xlabel('Time from movement (s)'); ylabel('microvolts');
        if ch==1
            lg=legend('Non-displaced','Displaced','Displaced - non-displaced','Bonferroni significant');
            lg.Layout.Tile='south';
        end
    end
    sgtitle(sprintf('%s: non-displaced n=%d, displaced n=%d; new preprocessing',cfg.subjects{s},sum(labels==1),sum(labels==2)));
    exportgraphics(fig,fullfile(out,[cfg.subjects{s} '_averages.png'])); close(fig);
    time=d.time; save(fullfile(out,[cfg.subjects{s} '_averages.mat']),'correct','displaced','difference','p','significant','time','labels','cfg');
end
