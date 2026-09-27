% Optionally compare v1 with the configured pipeline on matched runs and trials.
codeDir=fileparts(mfilename('fullpath')); addpath(codeDir); cfg=config();
out=fullfile(cfg.output,'comparison'); if ~isfolder(out), mkdir(out); end
manifest=readtable(fullfile(cfg.output,'selected_manifest.csv'),'TextType','string');
summary=table();
for subject=string(cfg.subjects)
    for session=string(cfg.sessions)
        rows=find(manifest.subject==subject & manifest.session==session);
        oldX=[]; newX=[]; labels=[]; oldKeep=[]; newKeep=[];
        for row=rows'
            name=manifest.run(row)+".mat";
            d=load(fullfile(cfg.output,'processed',name));
            old=load(fullfile(cfg.baselineOutput,'processed',name));
            assert(isequaln(old.trials.label,d.trials.label) && ...
                isequaln(old.trials.movementSample,d.trials.movementSample));
            oldX=cat(1,oldX,old.epochs); newX=cat(1,newX,d.epochs);
            labels=[labels;d.trials.label]; oldKeep=[oldKeep;old.trials.accepted];
            newKeep=[newKeep;d.trials.accepted];
        end
        if isempty(rows), continue; end
        common=oldKeep & newKeep;
        for condition=1:2
            a=labels==condition;
            summary=[summary;table(subject,session,condition, ...
                sum(a & oldKeep),sum(a & newKeep),sum(a & common), ...
                sum(a & ~oldKeep & newKeep),sum(a & oldKeep & ~newKeep), ...
                'VariableNames',{'subject','session','condition','v1Accepted', ...
                'v2Accepted','common','recovered','lost'})];
        end
        for mode=["common","own"]
            if mode=="common", ka=common; kb=common; else, ka=oldKeep; kb=newKeep; end
            fig=figure('Visible','off','Position',[50 50 1150 1000]); tiledlayout(4,2);
            for ch=1:8
                nexttile; hold on;
                a=squeeze(mean(oldX(ka & labels==1,:,ch),1));
                b=squeeze(mean(newX(kb & labels==1,:,ch),1));
                e=squeeze(mean(oldX(ka & labels==2,:,ch),1));
                f=squeeze(mean(newX(kb & labels==2,:,ch),1));
                h=plot(d.time,a,'b--',d.time,b,'b-',d.time,e,'r--',d.time,f,'r-');
                xline(0,'k:','HandleVisibility','off'); title(d.channels{ch});
                xlabel('Time from movement (s)'); ylabel('microvolts');
                if ch==1
                    lg=legend(h,{'v1 non-displaced','FORCe non-displaced','v1 displaced','FORCe displaced'});
                    lg.Layout.Tile='south';
                end
            end
            sgtitle(sprintf('%s / %s / %s trials: v1 n=%d, FORCe n=%d; PILOT', ...
                subject,session,mode,sum(ka),sum(kb)));
            exportgraphics(fig,fullfile(out,subject+"_"+session+"_"+mode+".png")); close(fig);
        end

    end
end
writetable(summary,fullfile(out,'comparison_counts.csv'));
disp(summary);
