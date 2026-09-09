% Stage 1: event metadata only. Original EEG and legacy MAT files are untouched.
codeDir=fileparts(mfilename('fullpath')); addpath(codeDir,fullfile(codeDir,'helpers'));
cfg=config(); out=fullfile(cfg.output,'parsed'); if ~isfolder(out), mkdir(out); end
manifest=table();
for s=1:numel(cfg.subjects)
    subject=cfg.subjects{s}; folder=fullfile(cfg.root,'data',subject);
    files=dir(fullfile(folder,cfg.runPattern));
    for f=1:numel(files)
        name=files(f).name; rawPath=fullfile(folder,name);
        suffix=extractAfter(name,15); suffix=erase(suffix,'_EEG.easy');
        logs=dir(fullfile(folder,[name(1:8) '*' char(suffix) '_tdcserror_.csv']));
        % Aborted starts can leave header-only CSVs with the same run suffix.
        usable=false(size(logs));
        for j=1:numel(logs)
            candidate=readtable(fullfile(folder,logs(j).name),'VariableNamingRule','preserve');
            usable(j)=ismember('event',candidate.Properties.VariableNames) && ...
                height(candidate)>0 && any(candidate.event==100);
        end
        logs=logs(usable);
        assert(numel(logs)<=1,'Ambiguous mouse logs for %s.',name);
        mousePath='';
        if isempty(logs)
            mouse=table([],[],[],[],[],'VariableNames',{'trial','time','event','x_target','y_target'});
        else
            mousePath=fullfile(folder,logs(1).name);
            mouse=readtable(mousePath,'VariableNamingRule','preserve');
        end
        raw=readmatrix(rawPath,'FileType','text');
        [trials,events,info]=parse_run(raw,mouse,cfg);
        info.rawPath=rawPath; info.mousePath=mousePath; info.subject=subject;
        stem=erase(name,'.easy'); parsedPath=fullfile(out,[stem '.mat']);
        save(parsedPath,'trials','events','info','cfg');
        writetable(trials,fullfile(out,[stem '_trials.csv']));
        manifest=[manifest;table(string(subject),string(stem),string(parsedPath),...
            height(trials),sum(trials.valid),'VariableNames',...
            {'subject','run','parsedPath','trials','validTrials'})]; %#ok<AGROW>
        fprintf('%s: %d/%d valid event sequences\n',stem,sum(trials.valid),height(trials));
    end
end
writetable(manifest,fullfile(out,'manifest.csv'));
