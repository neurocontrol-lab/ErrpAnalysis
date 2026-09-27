function [clean, status] = clean_epoch_force(epoch, cfg, chanlocs)
% Call supplied FORCe on the two one-second halves of a samples x channels epoch.
% A failed window rejects the whole epoch. The join at movement onset still
% requires scientific review; this adapter does not correct the boundary.
assert(cfg.fs==500 && isequal(size(epoch),[1000 numel(cfg.channels)]), ...
    'FORCe expects a two-second epoch at 500 Hz');
assert(isequal(lower(string({chanlocs.labels})),lower(string(cfg.channels))), ...
    'FORCe channel order mismatch');
clean=nan(size(epoch)); status="ok";
if ~isreal(epoch) || any(~isfinite(epoch),'all')
    status="invalid_input"; return;
end
for w=1:2
    ix=(w-1)*500+(1:500); x=epoch(ix,:)';
    % Retain the pilot policy: exclude the unresolved interpolation branch.
    if any(max(x,[],2)>200)
        status="channel_threshold";
    elseif any(std(x,0,2)<1e-12)
        status="flat_channel";
    else
        try
            % Suppress the library's verbose console output.
            evalc('[y, details]=FORCe(x,cfg.fs,chanlocs,0);');
            status=string(details.status);
            if ~isequal(size(y),size(x)) || ~isreal(y) || any(~isfinite(y),'all')
                status="invalid_output";
            elseif sqrt(mean(y.^2,'all'))<1e-12
                status="zero_output";
            end
            if status=="ok", clean(ix,:)=y'; end
        catch ME
            warning('FORCe:CleaningFailed','%s',ME.message);
            status="failed";
        end
    end
    if status~="ok", clean(:)=NaN; return; end
end
end
