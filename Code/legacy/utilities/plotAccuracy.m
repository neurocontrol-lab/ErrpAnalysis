function [] = plotAccuracy(Accuracy, SubID, randVariable, SesDates)

figure();
counter = 0;
%labels = {};
 labels = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6','S7', ...                
          'S8', 'S9', 'S10', 'S11', 'S12', 'S13', 'S14', 'S15',...
          'S16', 'S17', 'S18', ...
          'S19', 'S20', 'S21', 'S22', ...
          'S23', 'S24', 'S25', 'S26', 'S27', 'S28', 'S29', 'S30', 'S31', 'S32' };
 SubID = labels;
tmpAcc = [];
tmpRV = [];
%bwidth = 0.8 * (1/length(Accuracy));
for i = 1:length(Accuracy)
       for ses=1:length(Accuracy{i})
        counter = counter +1;
        tmpAcc(counter) = Accuracy{i}(ses);
        tmpRV(counter) = randVariable{i}(ses);
        bar(counter, Accuracy{i}(ses), 'b'); hold on; 
        labels{counter} = [SubID{i} ',' num2str(ses)];
        line([counter-0.5 counter+0.5], [randVariable{i}(ses) randVariable{i}(ses)],'LineWidth',3,'Color','r','LineStyle','--'); 
    end
    
end
line([0 counter+1], [50 50],'LineWidth',3,'Color','r');
axis([0 counter+1 20 65]);
set(gca, 'XTick',[1:1:counter]);
xlabel('Subject','FontSize',35);
ylabel('Classification Accuracy (%)','FontSize',20);
set(gca, 'XTick', [1:counter], 'FontSize',20)
set(gca,'XTickLabel', labels,'FontSize',20) 
