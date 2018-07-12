function plot_entropy(c,r,block,savebehfigpath)

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


enA3=zeros(1, floor(length(c)/block));

enA5=zeros(1, floor(length(c)/block));


%change left representation from  -1 to 0
c(c==-1)=0;


for i =1:length(enA3)
    entropyCount3=zeros(1,8);
    entropyCount5=zeros(1,32);
    for k =(i-1)*block+1:i*block-2
        ind3=bin2dec(num2str(c(k:k+2)))+1;
        entropyCount3(ind3)=entropyCount3(ind3)+1;
        ind5=bin2dec(num2str([c(k:k+2)'; r(k:k+1)']'))+1;
        entropyCount5(ind5)=entropyCount5(ind5)+1;
    end
    %calculate the entropy
    p3=entropyCount3/sum(entropyCount3);
    if ismember(0,p3)
       warning('certain patterns did not occur, zero probability generated');
       IndexZero=find(~p3);
       for x=1:length(IndexZero)
           p3(IndexZero(x))=realmin;
       end
    end
    en1=-sum(p3.*log2(p3))+(length(p3)-1)/(1.3863*sum(entropyCount3));
    enA3(i)=en1;
    p5=entropyCount5/sum(entropyCount5);
     if ismember(0,p5)
        warning('certain patterns did not occur, zero probability generated');
        IndexZero=find(~p5);
        for x=1:length(IndexZero)
            p5(IndexZero(x))=realmin;
        end
     end
    en2=-sum(p5.*log2(p5))+(length(p5)-1)/(1.3863*sum(entropyCount5));
    enA5(i)=en2;
end

sz=80;
x_axis=[1:length(enA3)]*block;

figure; subplot(2,1,1);
scatter(x_axis,enA3,sz,'k','filled');
hold on;plot([0 x_axis(end)], [3,3],'k--','Linewidth',1);
ylim([0 4]);
xlabel('Trial'); ylabel('Entropy (bits)');
title('Entropy of 3 consecutive choices');

subplot(2,1,2); scatter(x_axis,enA5,sz,'k','filled');
hold on;plot([0 x_axis(end)], [5,5],'k--','Linewidth',1);
ylim([0 6]);
xlabel('Trial'); ylabel('Entropy (bits)');
title('Entropy of 3 choices and 2 rewards');

cd(savebehfigpath);
print(gcf, '-r0', 'p_entropy', '-dpng'); %png format
saveas(gcf,  'p_entropy', 'fig'); %fig format
