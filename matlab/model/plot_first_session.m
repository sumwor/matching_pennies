function plot_first_session(c,r,com,comprob)
%plot a example session of the simulation
c=(c-2.5).*2;
com=(com-2.5)*2;
n_plot=204;

figure;
subplot(4,1,1);
    bar(-1*(com==-1),1,'FaceColor','r','EdgeColor','none');
    hold on;
    bar((com==1),1,'FaceColor','b','EdgeColor','none');
    ylabel("Computer's choice");
    yticks([-1 1]);
    yticklabels({'Left','Right'});
    xlim([0 n_plot]);
    %set(gca,'xticklabel',[]);
    
    subplot(4,1,2);
    bar(-1*(c==-1),1,'FaceColor','r','EdgeColor','none');
    hold on;
    bar((c==1),1,'FaceColor','b','EdgeColor','none');
    ylabel("Animal's choice");
    yticks([-1 1]);
    yticklabels({'Left','Right'});
    xlim([0 n_plot]);
    %set(gca,'xticklabel',[]);

    subplot(4,1,3);
    bar(r,1,'k');
    ylabel('Outcome');
    ylim([0 1]);
    yticks([0 1]);
    yticklabels({'No reward','Reward'});
    xlim([0 n_plot]);
    hold on;
    plot(smooth(double(r==1),10,'lowess'),'r','LineWidth',2);
    %set(gca,'xticklabel',[]);

%     subplot(3,2,4);
%     plot(smooth(double(r==1),10),'k','LineWidth',2);
%     hold on;
%     plot([0, numel(r)], [ave_rRate, ave_rRate],'-');
%     ylabel('Reward rate');
%     %set(gca,'xticklabel',[]);
%     xlim([0 n_plot]);
%     
%     legend('Running reward rate', ['average rate :', num2str(ave_rRate)]);

    
    
    subplot(4,1,4);
    plot(comprob,'k','LineWidth',2);  
    hold on;
    ylabel('P(right) for computer');
    xlim([0 n_plot]);
    ylim([-0.1 1.1]);
    xlabel('Trial');