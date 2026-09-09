% Stage 2: continuous zero-phase bandpass, baseline and explicit rejection.
codeDir=fileparts(mfilename('fullpath')); addpath(codeDir);
cfg=config(); out=fullfile(cfg.output,'processed'); if ~isfolder(out), mkdir(out); end
manifest=readtable(fullfile(cfg.output,'parsed','manifest.csv'),'TextType','string','Delimiter',',','VariableNamingRule','preserve');
[b,a]=butter(cfg.filterOrder,cfg.band/(cfg.fs/2),'bandpass');
offsets=round(cfg.window(1)*cfg.fs):round(cfg.window(2)*cfg.fs)-1;
time=offsets/cfg.fs; base=time>=cfg.baseline(1) & time<cfg.baseline(2);
assert(any(base),'Empty baseline interval'); channels=cfg.channels;
for f=1:height(manifest)
    p=load(manifest.parsedPath(f)); trials=p.trials; info=p.info;
    raw=readmatrix(info.rawPath,'FileType','text'); eeg=raw(:,1:8)/1000;
    % Split at loss/nonfinite samples and timestamp discontinuities. Never filter across a gap.
    bad=raw(:,12)==255 | any(~isfinite(eeg),2);
    gap=find(diff(raw(:,13))~=1000/cfg.fs); bad(gap)=true; bad(gap+1)=true;
    edges=diff([false;~bad;false]); first=find(edges==1); last=find(edges==-1)-1;
    filtered=nan(size(eeg)); quality=true(size(bad)); guard=round(cfg.lossGuardSeconds*cfg.fs);
    for j=1:numel(first)
        ix=first(j):last(j);
        if numel(ix)<=max(3*(max(numel(a),numel(b))-1),2*guard), continue; end
        filtered(ix,:)=filtfilt(b,a,eeg(ix,:));
        quality(first(j)+guard:last(j)-guard)=false;
    end
    epochs=nan(height(trials),numel(time),8);
    trials.accepted=false(height(trials),1); trials.rejection=trials.reason;
    for k=1:height(trials)
        if ~trials.valid(k), continue; end
        ix=trials.movementSample(k)+offsets;
        if min(ix)<1 || max(ix)>size(raw,1), trials.rejection(k)="epoch_out_of_bounds"; continue; end
        if any(quality(ix)), trials.rejection(k)="data_loss_gap_or_filter_edge"; continue; end
        x=filtered(ix,:); x=x-mean(x(base,:),1);
        if any(~isfinite(x),'all'), trials.rejection(k)="nonfinite"; continue; end
        if max(abs(x),[],'all')>cfg.maxAmplitudeUV, trials.rejection(k)="amplitude"; continue; end
        epochs(k,:,:)=x; trials.accepted(k)=true; trials.rejection(k)="ok";
    end
    processingNote='New baseline pipeline; no FORCe/ICA applied. Rejected rows remain NaN to preserve trial identity.';
    save(fullfile(out,manifest.run(f)+".mat"),'epochs','time','channels','trials','info','cfg','processingNote','-v7.3');
    writetable(trials,fullfile(out,manifest.run(f)+"_quality.csv"));
    fprintf('%s: %d accepted\n',manifest.run(f),sum(trials.accepted));
end
