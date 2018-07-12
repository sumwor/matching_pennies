function plot_p_StayWSLS(c,r,block,savebehfigpath)

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


pStay=zeros(1, floor(length(c)/block));
for i =1:length(pStay)
    sumStay=0;
    if i==1
        for k=2:block
            if c(k)==c(k-1)
                sumStay=sumStay+1;
            end
        end
    else
        for k=(i-1)*block+1:i*block
            if c(k)==c(k-1)
                sumStay=sumStay+1;
            end
        end
    end
    pStay(i)=sumStay/block;
end

sz=80;
x_axis=[1:length(pStay)]*block;

figure;
subplot(2,1,1);
scatter(x_axis,pStay,sz,'k','filled');
hold on;plot([0 x_axis(end)], [0.5,0.5],'k--','Linewidth',1);
ylim([0 1]);
xlabel('Trial'); ylabel('P(stay)');
title('P(stay)');
%%--------figure 4: P_wsls per block trials
pWSLS=zeros(1, floor(length(c)/block));
for i =1:length(pWSLS)-1
    sumWSLS=0;
   
    for k=(i-1)*block+1:i*block
        if r(k)==1
            if c(k+1)==c(k)
                sumWSLS=sumWSLS+1;
            end
        else
            if c(k+1)~=c(k)
                sumWSLS=sumWSLS+1;
            end
        end
    end
    pWSLS(i)=sumWSLS/block;
end

sz=80;
subplot(2,1,2); scatter(x_axis,pWSLS,sz,'k','filled');
hold on;plot([0 x_axis(end)], [0.5,0.5],'k--','Linewidth',1);
ylim([0 1]);
xlabel('Trial'); ylabel('P(WSLS)');
title('P(WSLS)');

cd(savebehfigpath);
print(gcf, '-r0', 'p_StayWSLS', '-dpng'); %png format
saveas(gcf,  'p_StayWSLS', 'fig'); %fig format