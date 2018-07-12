function plot_MI(c,r,com, block,savebehfigpath)

%mutual information between animal & computers 3 consecutive choice and
%animal's choice following that
%still some bugs
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

MI=zeros(1, floor(length(c)/block));

c(c==-1)=0;
com(com==-1)=0;
for i=1:length(MI)
    choiceList=zeros(1,64);
    outcomeList=zeros(1,2);
    C_OList=zeros(1,64,2);
    %for k =1:floor(block/3)
    for k=(i-1)*block+1:i*block-3
        cPattern=[c(k:k+2)';com(k:k+2)'];
        ind=bin2dec(num2str(cPattern'))+1;
        choiceList(ind)=choiceList(ind)+1;
        if c(k+3)==1 %right
            outcomeList(1)=outcomeList(1)+1;
            C_OList(1,ind, 1)=C_OList(1,ind,1)+1;
        else %left
            outcomeList(2)=outcomeList(2)+1;
            C_OList(1,ind, 2)=C_OList(1,ind,2)+1;
        end
    end
    %calculate the mutual information
    MI_sum=0;
    p1=outcomeList(1)/sum(outcomeList);
    p2=outcomeList(2)/sum(outcomeList);
    for h=1:64
        p_j=choiceList(h)/sum(choiceList);
        p_1j=C_OList(1,h, 1)/sum(sum(C_OList));
        p_2j=C_OList(1,h,2)/sum(sum(C_OList));
        if p_1j==0
            p_1j=realmin;
        end
        if p_2j==0
            p_2j=realmin;
        end
        if p_j==0
            p_j=realmin;
        end

        MInfo=p_1j*log2(p_1j/(p_j*p1))+p_2j*log2(p_2j/(p_j*p2));
        %MI=p_1j*log2(p_whole1)+p_2j*log2(p_whole2);
        MI_sum=MI_sum+MInfo;
    end
    MI_sum=MI_sum-63/(1.3863*block);
    MI(i)=MI_sum;
end

sz=80;
x_axis=[1:length(MI)]*block;
figure;
scatter(x_axis,MI,sz,'k','filled');
hold on;plot([0 x_axis(end)], [0,0],'k--','Linewidth',1);
ylim([-0.2 0.8]);


xlabel('Trial'); ylabel('Mutual information (bits)');
title('Mutual information');
cd(savebehfigpath);
print(gcf, '-r0', 'MI', '-dpng'); %png format
saveas(gcf,  'MI', 'fig'); %fig format
