function [] = showTopographicComparisonRHLH(fvec_move, fvec_noMove, chanlocs16)

figure();
subplot(2,1,1);topoplot(mean(fvec_move(:,[3 4 5 6]),2)-...
   mean(fvec_noMove(:,[3 4 5 6]),2),chanlocs16);
title('$\mu$ band, Motor Attempt vs Rest','Interpreter','latex');
colorbar;

subplot(2,1,2);topoplot(mean(fvec_move(:,[8 9 10 11]),2)-...
    mean(fvec_noMove(:,[8 9 10 11]),2),chanlocs16);
title('$\beta$ band, Motor Attempt vs Rest','Interpreter','latex');
colorbar;