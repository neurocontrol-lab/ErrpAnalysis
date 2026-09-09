function [trials, events, info] = parse_run(raw, mouse, cfg)
% Preserve raw indices. Detect changes of code, including 255 -> 500.
assert(size(raw,2)==13,'Expected 13 columns in EASY recording.');
trigger = raw(:,12);
idx = find(trigger~=0 & [true; diff(trigger)~=0]);
events = table(idx,trigger(idx),'VariableNames',{'sample','code'});
info.samples = size(raw,1);
info.lossSamples = find(trigger==255);
info.timestampGaps = find(diff(raw(:,13))~=1000/cfg.fs);
info.unknownCodes = setdiff(unique(trigger),[0 100 200 255 300 400 500]);
starts = events.sample(events.code==100);
n = numel(starts);
trial=(1:n)'; startSample=starts; targetSample=nan(n,1);
movementSample=targetSample; displacementSample=targetSample;
label=targetSample; valid=false(n,1); reason=strings(n,1);
mouseTrial=targetSample; mouseJump=targetSample;
mouseIds=unique(mouse.trial,'stable');
mouseStarts=mouse(mouse.event==100,:);
% Require explicit trial starts; never silently align by nearest timestamp.
paired=min(height(mouseStarts),n);
mouseAligned = paired>0 && height(mouseStarts)==numel(mouseIds) ...
    && isequal(mouseStarts.trial(:),mouseIds(:));
if mouseAligned
    clockOffset=raw(starts(1:paired),13)/1000-mouseStarts.time(1:paired);
    mouseAligned=all(abs(clockOffset-median(clockOffset))<0.1);
end
for k=1:n
    stop=size(raw,1)+1;
    if k<n, stop=starts(k+1); end
    e=events(events.sample>=starts(k) & events.sample<stop,:);
    c=e.code; task=e(ismember(c,[100 200 300 400 500]),:);
    if ~mouseAligned || k>paired, reason(k)="mouse_trial_count_order_or_timing"; continue; end
    mouseTrial(k)=mouseIds(k);
    m=mouse(mouse.trial==mouseIds(k) & ismember(mouse.event,[100 200 300 400 500]),:);
    for code=[300 400 500]
        p=e.sample(c==code);
        if numel(p)==1
            if code==300, targetSample(k)=p; end
            if code==400, movementSample(k)=p; end
            if code==500, displacementSample(k)=p; end
        end
    end
    if ~isequal(task.code(:),m.event(:)), reason(k)="mouse_eeg_event_disagreement"; continue; end
    expected=[100;200;300;400];
    displaced=any(c==500);
    if displaced, expected=[expected;500]; end
    if ~isequal(task.code,expected), reason(k)="incomplete_or_duplicate_events"; continue; end
    if displaced
        mouseJump(k)=m.x_target(m.event==500)-m.x_target(m.event==400);
        if abs(mouseJump(k))~=400, reason(k)="unexpected_target_jump"; continue; end
    else
        mouseJump(k)=0;
    end
    % Last trial requires post-movement samples in the mouse log.
    lastTime=max(mouse.time(mouse.trial==mouseIds(k)));
    if k==n && lastTime<=m.time(m.event==400)
        reason(k)="unconfirmed_terminal_trial"; continue;
    end
    label(k)=1+displaced; valid(k)=true; reason(k)="ok";
end
trials=table(trial,mouseTrial,startSample,targetSample,movementSample,...
    displacementSample,label,mouseJump,valid,reason);
end
