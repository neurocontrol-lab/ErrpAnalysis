function [SelFeatInd, fvec, fvec_move, lbl_move, atrlbl_move, ...
    fvec_noMove, lbl_noMove, atrlbl_noMove,...
    maxFS, maxR2, AveFS, AveR2, DP] = ...
    FeatureSelection(afeats, albl, atrlbl, ChannelLabels, chanlocs64, doplots)

afeats = afeats(:,[3:6 8:11],2:16);
% chanlocs16 = chanlocs16(2:end);
chanlocs64 = chanlocs64(2:end);

% Reshape dataset for feature selection
fvec = reshape(afeats,[size(afeats,1) size(afeats,2)*size(afeats,3)]);


fvec_move = fvec(find(albl==1),:);
lbl_move = albl(albl==1);
atrlbl_move = atrlbl(albl==1);
fvec_noMove = fvec(find(albl==2),:);

lbl_noMove = albl(albl==2);
atrlbl_noMove = atrlbl(albl==2);

% dual_length = length(fvec_move); 
% fvec_noMove = fvec_noMove(1:dual_length,:);
% lbl_noMove = lbl_noMove(1:dual_length);
% atrlbl_noMove = atrlbl_noMove(1:dual_length);


% DPrhlh = mmbci_fisherscore([fvec_move;fvec_noMove],[lbl_move;lbl_noMove]); 
% DPMrhlh = reshape(DPrhlh,size(afeats,2),size(afeats,3))';

%Remove outliers
% outMove = isoutliers(fvec_move);
% outNomove = isoutlier(fvec_noMove);
%     if (outMove && outNomove) == 0
%         fvec_move = [];
%         lbl_move = [];
% 
%     end
% fvec_noMove = rmoutliers(fvec_noMove);
% 
for ch=1:15
    for fr=1:8
       DP(ch,fr) = mmbci_fisherscore([afeats(albl==1,fr,ch) ; afeats(albl==2,fr,ch)], [lbl_move;lbl_noMove]);
    end
end
    
FS = mmbci_fisherscore([fvec_move;fvec_noMove],[lbl_move;lbl_noMove]);
R2 = mmbci_rsquared([fvec_move;fvec_noMove],[lbl_move;lbl_noMove]);

maxFS = max (FS);
maxR2 = max(R2);

if(doplots)
    %heatmaps
    %imagesc(fvec)
    
    figure();
    subplot(3,1,1);imagesc(DP);colorbar;
    title('Discriminancy Motor Attempt vs Resting ');
    set(gca,'XTick',[1:1:8]);
    set(gca,'XTickLabel',[8:2:14 18:2:24],'FontSize',20);
    set(gca,'YTick',[1:1:15]);
    set(gca,'YTickLabel',ChannelLabels,'FontSize',10);
    subplot(3,1,2);topoplot(convChans([0; mean(DP(:,[1:4]),2)]),chanlocs64, 'plotrad', 0.5, 'maplimits', [0,0.3]);title('$\mu$ band','Interpreter','latex');
    subplot(3,1,3);topoplot(convChans([0; mean(DP(:,[5:8]),2)]),chanlocs64, 'plotrad', 0.5, 'maplimits', [0,0.3]);title('$\beta$ band','Interpreter','latex');
    
    
end

% Automatic way to select the features: simply rank according to
% discriminant power and select the N best
NSelFeat = 5;
[~, SortInd] = sort(DP(:),'descend');
SelFeatInd = SortInd(1:NSelFeat);
AveFS = mean(FS(SelFeatInd));
AveR2 = mean(R2(SelFeatInd));

%[SelFeatCh, SelFeatFreq] = ind2sub([size(lpsd,2), size(lpsd,3)],SelFeatInd); % Useful to compare with feature map
