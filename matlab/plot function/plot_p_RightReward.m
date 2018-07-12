function plot_p_RightReward(c,r,block,savebehfigpath)

%plot behavior summary of right and reward
set(groot, ...
    'DefaultFigureColor', 'w', ...
    'DefaultAxesLineWidth', 2, ...
    'DefaultAxesXColor', 'k', ...
    'DefaultAxesYColor', 'k', ...
    'DefaultAxesFontUnits', 'points', ...
    'DefaultAxesFontSize', 18, ...
    'DefaultAxesFontName', 'Helvetica', ...
    'DefaultLineLineWidth', 1, ...
    'DefaultTextFontUnits', 'Points', ...
    'DefaultTextFontSize', 18, ...
    'DefaultTextFontName', 'Helvetica', ...
    'DefaultAxesBox', 'off', ...
    'DefaultAxesTickLength', [0.02 0.025]);

% set the tick marks on figures to point outwards - need to set(groot) in this specific order
set(groot, 'DefaultAxesTickDir', 'out');
set(groot, 'DefaultAxesTickDirMode', 'manual');
set(0,'defaultfigureposition',[40 40 1000 1000]);





pRight=zeros(1, floor(length(c)/block));


for i =1:length(pRight)
    pRight(i)=sum(c((i-1)*block+1:i*block)==1)/block;
end

x_axis=[1:length(pRight)]*block;
sz=80;
figure; 
subplot(2,1,1);
scatter(x_axis,pRight,sz,'k','filled');
hold on;plot([0 x_axis(end)], [0.5,0.5],'k--','Linewidth',1);
ylim([0 1]);
%xlabel('Trial'); 
ylabel('P(right)');
title('P(right)');

%%---------figure 2: P_reward per 200 trials
pReward=zeros(1, floor(length(c)/block));
for i =1:length(pReward)
    pReward(i)=sum(r((i-1)*block+1:i*block)==1)/block;
end
subplot(2,1,2); 
scatter(x_axis,pReward,sz,'k','filled');
hold on;plot([0 x_axis(end)], [0.5,0.5],'k--','Linewidth',1);
ylim([0 1]);
xlabel('Trial'); ylabel('P(reward)');
title('P(reward)');
%add the transit point

cd(savebehfigpath);
print(gcf, '-r0', 'p_RightReward', '-dpng'); %png format
saveas(gcf,  'p_RightReward', 'fig'); %fig format