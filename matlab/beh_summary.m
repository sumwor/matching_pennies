clear all;

%%---------set the figure properties
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

%add a plot showing how many trials in each session

%combine the whole sessions (including algorithm1 and algorithm2)
base_dir='E:\data\matching_pennies\761\';
base_dir1 = 'E:\data\matching_pennies\761\model_A1\';
base_dir2 = 'E:\data\matching_pennies\761\model_A2\';
savebehfigpath=[base_dir,'figs_summary\'];
%bandit_setPathList(base_dir);
rewardCode=[10, 100, 111];
incorrectCode=[110, 101];
%data=
%'/Users/phoenix/Documents/Kwanlab/reinforcement_learning/logfile/human/170511/';\
cd(base_dir1);
logfiles = dir('*.log');
c_all1=[];r_all1=[]; com_all1=[];
num_session1=[];
num_session2=[];
%get concatenated choice and reward history
for i =1:length(logfiles)
    [ logData ] = parseLogfileHW(base_dir1, logfiles(i).name);
    
    [ sessionData, trialData] = MP_getSessionData( logData );
    c=double(trialData.response);
    for i=1:length(c)
        if c(i)~=0
          c(i)=(c(i)-2.5)*2;
        end
        
    end
    r=trialData.outcome;
    com=trialData.comChoiceCode;
    n_missed=sum(r==77);
    r(~ismember(r, rewardCode))=0;
    r(ismember(r, rewardCode))=1;
    num_session1=[num_session1, length(c(c~=0))];
    %concatenate
    c_all1=[c_all1;c]; r_all1=[r_all1;r]; com_all1=[com_all1;com];
    
end

cd(base_dir2);
logfiles = dir('*.log');
c_all2=[];r_all2=[]; com_all2=[];

%get concatenated choice and reward history
for i =1:length(logfiles)
    [ logData ] = parseLogfileHW(base_dir2, logfiles(i).name);
    
    [ sessionData, trialData] = MP_getSessionData( logData );
    c=double(trialData.response);
    for i=1:length(c)
        if c(i)~=0
          c(i)=(c(i)-2.5)*2;
        end
    end
    r=trialData.outcome;
    com=trialData.comChoiceCode;
    n_missed=sum(r==77);
    r(~ismember(r, rewardCode))=0;
    r(ismember(r, rewardCode))=1;
    num_session2=[num_session2, length(c(c~=0))];
    %concatenate
    c_all2=[c_all2;c]; r_all2=[r_all2;r]; com_all2=[com_all2; com];
    
end


%exclude the missed trials
c_nomiss1=c_all1(c_all1~=0);
r_nomiss1=r_all1(c_all1~=0);
com_nomiss1=com_all1(c_all1~=0);

c_nomiss2=c_all2(c_all2~=0);
r_nomiss2=r_all2(c_all2~=0);
com_nomiss2=com_all2(c_all2~=0);

block=200;
len1=length(c_nomiss1);
transit_point=200*(floor(len1/block)+0.5);
%---------figure 0: number of trials per session

transit_session=length(num_session1)+0.5;
figure;
plot([num_session1,num_session2], 'k.', 'MarkerSize',35);
ylim([0 500]);
xlabel('Session');
ylabel('Number of trials');
title('Number of trials per session');
hold on;plot([transit_session transit_session],[0 500], 'k-','LineWidth',1);

print(gcf, '-r0', [savebehfigpath sessionData.subject{1}, '_n_trials'], '-dpng'); %png format
saveas(gcf, [savebehfigpath sessionData.subject{1}, '_n_trials'], 'fig'); %fig format

%%--------figure 1: P_right per 200 trials  no missed trials





pRight1=zeros(1, floor(len1/block));


for i =1:length(pRight1)
    pRight1(i)=sum(c_nomiss1((i-1)*block+1:i*block)==1)/block;
end

len2=length(c_nomiss2);
pRight2=zeros(1, floor(len2/block));
for i =1:length(pRight2)
    pRight2(i)=sum(c_nomiss2((i-1)*block+1:i*block)==1)/block;
end


pRight=[pRight1, pRight2];
x_axis=[1:length(pRight)]*block;
sz=80;
figure; 
subplot(2,1,1);
scatter(x_axis,pRight,sz,'k','filled');
hold on;plot([transit_point transit_point],[0 1], 'k-','LineWidth',1);
hold on;plot([0 x_axis(end)], [0.5,0.5],'k--','Linewidth',1);
ylim([0 1]);
%xlabel('Trial'); 
ylabel('P(right)');
title('P(right)');

%%---------figure 2: P_reward per 200 trials
pReward1=zeros(1, floor(len1/block));
for i =1:length(pReward1)
    pReward1(i)=sum(r_nomiss1((i-1)*block+1:i*block)==1)/block;
end

pReward2=zeros(1, floor(len2/block));
for i =1:length(pReward2)
    pReward2(i)=sum(r_nomiss2((i-1)*block+1:i*block)==1)/block;
end

pReward=[pReward1, pReward2];
subplot(2,1,2); 
scatter(x_axis,pReward,sz,'k','filled');
hold on;plot([transit_point transit_point],[0 1], 'k-','LineWidth',1);
hold on;plot([0 x_axis(end)], [0.5,0.5],'k--','Linewidth',1);
ylim([0 1]);
xlabel('Trial'); ylabel('P(reward)');
title('P(reward)');
%add the transit point

print(gcf, '-r0', [savebehfigpath sessionData.subject{1}, '_p_reward'], '-dpng'); %png format
saveas(gcf, [savebehfigpath sessionData.subject{1}, '_p_reward'], 'fig'); %fig format

%%------------figure 3: P_stay per block trials
pStay1=zeros(1, floor(len1/block));
for i =1:length(pStay1)
    sumStay=0;
    if i==1
        for k=2:block
            if c_nomiss1(k)==c_nomiss1(k-1)
                sumStay=sumStay+1;
            end
        end
    else
        for k=(i-1)*block+1:i*block
            if c_nomiss1(k)==c_nomiss1(k-1)
                sumStay=sumStay+1;
            end
        end
    end
    pStay1(i)=sumStay/block;
end

pStay2=zeros(1, floor(len2/block));
for i =1:length(pStay2)
    sumStay=0;
    if i==1
        for k=2:block
            if c_nomiss2(k)==c_nomiss2(k-1)
                sumStay=sumStay+1;
            end
        end
    else
        for k=(i-1)*block+1:i*block
            if c_nomiss2(k)==c_nomiss2(k-1)
                sumStay=sumStay+1;
            end
        end
    end
    pStay2(i)=sumStay/block;
end

pStay=[pStay1, pStay2];

figure;
subplot(2,1,1);
scatter(x_axis,pStay,sz,'k','filled');
hold on;plot([transit_point transit_point],[0 1], 'k-','LineWidth',1);
hold on;plot([0 x_axis(end)], [0.5,0.5],'k--','Linewidth',1);
ylim([0 1]);
xlabel('Trial'); ylabel('P(stay)');
title('P(stay)');
%%--------figure 4: P_wsls per block trials
pWSLS1=zeros(1, floor(len1/block));
for i =1:length(pWSLS1)
    sumWSLS=0;
   
    for k=(i-1)*block+1:i*block
        if r_nomiss1(k)==1
            if c_nomiss1(k+1)==c_nomiss1(k)
                sumWSLS=sumWSLS+1;
            end
        else
            if c_nomiss1(k+1)~=c_nomiss1(k)
                sumWSLS=sumWSLS+1;
            end
        end
    end
    
    pWSLS1(i)=sumWSLS/block;
end

pWSLS2=zeros(1, floor(len2/block));
for i =1:length(pWSLS2)
    sumWSLS=0;
   
    for k=(i-1)*block+1:i*block
        if r_nomiss2(k)==1
            if c_nomiss2(k+1)==c_nomiss2(k)
                sumWSLS=sumWSLS+1;
            end
        else
            if c_nomiss2(k+1)~=c_nomiss2(k)
                sumWSLS=sumWSLS+1;
            end
        end
    end
    
    pWSLS2(i)=sumWSLS/block;
end

pWSLS=[pWSLS1,pWSLS2];
sz=80;
subplot(2,1,2); scatter(x_axis,pWSLS,sz,'k','filled');
hold on;plot([transit_point transit_point],[0 1], 'k-','LineWidth',1);
hold on;plot([0 x_axis(end)], [0.5,0.5],'k--','Linewidth',1);
ylim([0 1]);
xlabel('Trial'); ylabel('P(WSLS)');
title('P(WSLS)');
print(gcf, '-r0', [savebehfigpath sessionData.subject{1}, '_p_WSLS'], '-dpng'); %png format
saveas(gcf, [savebehfigpath sessionData.subject{1}, '_p_WSLS'], 'fig'); %fig format

%%-------figure 5: entropy (combinations of 3)
enA13=zeros(1, floor(len1/block));
enA23=zeros(1, floor(len2/block));

enA15=zeros(1, floor(len1/block));
enA25=zeros(1, floor(len2/block));

%change left representation from  -1 to 0
c_nomiss1(c_nomiss1==-1)=0;
c_nomiss2(c_nomiss2==-1)=0;

for i =1:length(enA13)
    entropyCount3=zeros(1,8);
    entropyCount5=zeros(1,32);
    for k =(i-1)*block+1:i*block
        ind3=bin2dec(num2str(c_nomiss1(k:k+2)'))+1;
        entropyCount3(ind3)=entropyCount3(ind3)+1;
        ind5=bin2dec(num2str([c_nomiss1(k:k+2); r_nomiss1(k:k+1)]'))+1;
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
    enA13(i)=en1;
    p5=entropyCount5/sum(entropyCount5);
     if ismember(0,p5)
        warning('certain patterns did not occur, zero probability generated');
        IndexZero=find(~p5);
        for x=1:length(IndexZero)
            p5(IndexZero(x))=realmin;
        end
     end
    en2=-sum(p5.*log2(p5))+(length(p5)-1)/(1.3863*sum(entropyCount5));
    enA15(i)=en2;
end

for i =1:length(enA23)
    entropyCount3=zeros(1,8);
    entropyCount5=zeros(1,32);
    for k =(i-1)*block+1:i*block
        ind3=bin2dec(num2str(c_nomiss2(k:k+2)'))+1;
        entropyCount3(ind3)=entropyCount3(ind3)+1;
        ind5=bin2dec(num2str([c_nomiss2(k:k+2); r_nomiss2(k:k+1)]'))+1;
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
    enA23(i)=en1;
    p5=entropyCount5/sum(entropyCount5);
    if ismember(0,p5)
       warning('certain patterns did not occur, zero probability generated');
       IndexZero=find(~p5);
       for x=1:length(IndexZero)
           p5(IndexZero(x))=realmin;
       end
    end
    en2=-sum(p5.*log2(p5))+(length(p5)-1)/(1.3863*sum(entropyCount5));
    enA25(i)=en2;
end

enA3=[enA13, enA23];
enA5=[enA15, enA25];
sz=80;
figure; subplot(2,1,1);
scatter(x_axis,enA3,sz,'k','filled');
hold on;plot([transit_point transit_point],[0 4], 'k-','LineWidth',1);
hold on;plot([0 x_axis(end)], [3,3],'k--','Linewidth',1);
ylim([0 4]);
xlabel('Trial'); ylabel('Entropy (bits)');
title('Entropy of 3 consecutive choices');

sz=80;
subplot(2,1,2); scatter(x_axis,enA5,sz,'k','filled');
hold on;plot([transit_point transit_point],[0 6], 'k-','LineWidth',1);
hold on;plot([0 x_axis(end)], [5,5],'k--','Linewidth',1);
ylim([0 6]);
xlabel('Trial'); ylabel('Entropy (bits)');
title('Entropy of 3 choices and 2 rewards');
print(gcf, '-r0', [savebehfigpath sessionData.subject{1}, '_entropy_5'], '-dpng'); %png format
saveas(gcf, [savebehfigpath sessionData.subject{1}, '_entropy_5'], 'fig'); %fig format

%find mutual information
MI1=zeros(1, floor(len1/block));
MI2=zeros(1, floor(len2/block));
com_nomiss1(com_nomiss1==-1)=0;
com_nomiss2(com_nomiss2==-1)=0;
for i=1:length(MI1)
    choiceList=zeros(1,64);
    cList=zeros(1,2);
    C_RList=zeros(1,64,2);
    %for k =1:floor(block/3)
    for k=(i-1)*block+1:i*block
        %cPattern=[c_nomiss1(3*k+block*(i-1)-2:3*k+block*(i-1)); com_nomiss1(3*k+block*(i-1)-2:3*k+block*(i-1))];
        cPattern=[c_nomiss1(k:k+2);com_nomiss1(k:k+2)];
        ind=bin2dec(num2str(cPattern'))+1;
        choiceList(ind)=choiceList(ind)+1;
        if c_nomiss1(k+3)==1
            cList(1)=cList(1)+1;
            C_RList(1,ind, 1)=C_RList(1,ind,1)+1;
        else
            cList(2)=cList(2)+1;
            C_RList(1,ind, 2)=C_RList(1,ind,2)+1;
        end
    end
    %calculate the mutual information
    MI_sum=0;
    p1=cList(1)/sum(cList);
    p2=cList(2)/sum(cList);
    for h=1:64
        p_j=choiceList(h)/sum(choiceList);
        p_1j=C_RList(1,h, 1)/sum(sum(C_RList));
        p_2j=C_RList(1,h,2)/sum(sum(C_RList));
        if p_1j==0
            p_1j=realmin;
        end
        if p_2j==0
            p_2j=realmin;
        end
        if p_j==0
            p_j=realmin;
        end
%         if p_1j==0
%             warning('certain patterns did not occur, zero probability generated');
%            p_whole1=realmin;
%         end
%         if p_2j==0
%             warning('certain patterns did not occur, zero probability generated');
%            p_whole2=realmin;
%         end
%         if (p_1j~=0 && p_j==0)
%         warning('certain patterns did not occur, zero probability generated');
%            p_j=realmin;
%            p_whole1=p_1j/(p_j*p1);
%         end
%         if (p_2j~=0 && p_j==0)
%         warning('certain patterns did not occur, zero probability generated');
%            p_j=realmin;
%            p_whole2=p_2j/(p_j*p2);
%         end
%         if (p_1j~=0 && p_j~=0)
%             p_whole1=p_1j/(p_j*p1);
%         end
%         if (p_2j~=0 && p_j~=0)
%             p_whole2=p_2j/(p_j*p2);
%         end
        MI=p_1j*log2(p_1j/(p_j*p1))+p_2j*log2(p_2j/(p_j*p2));
        %MI=p_1j*log2(p_whole1)+p_2j*log2(p_whole2);
        MI_sum=MI_sum+MI;
    end
    MI_sum1=MI_sum%-63/(1.3863*block);
    MI1(i)=MI_sum1;
end
for i=1:length(MI2)
    choiceList=zeros(1,64);
    cList=zeros(1,2);
    C_RList=zeros(1,64,2);
    %for k =1:floor(block/3)
    for k=(i-1)*block+1:i*block
        %cPattern=[c_nomiss2(3*k+block*(i-1)-2:3*k+block*(i-1)); com_nomiss2(3*k+block*(i-1)-2:3*k+block*(i-1))];
        cPattern=[c_nomiss2(k:k+2);com_nomiss2(k:k+2)];
        ind=bin2dec(num2str(cPattern'))+1;
        choiceList(ind)=choiceList(ind)+1;
        if c_nomiss2(k+3)==1
            cList(1)=cList(1)+1;
            C_RList(1,ind, 1)=C_RList(1,ind,1)+1;
        else
            cList(2)=cList(2)+1;
            C_RList(1,ind, 2)=C_RList(1,ind,2)+1;
        end
    end
    %calculate the mutual information
    MI_sum=0;
    p1=cList(1)/sum(cList);
    p2=cList(2)/sum(cList);
    for h=1:64
        p_j=choiceList(h)/sum(choiceList);
        p_1j=C_RList(1,h, 1)/sum(sum(C_RList));
        p_2j=C_RList(1,h,2)/sum(sum(C_RList));
        if p_1j==0
            p_1j=realmin;
        end
        if p_2j==0
            p_2j=realmin;
        end
        if p_j==0
            p_j=realmin;
        end
        
%         if p_1j==0
%             warning('certain patterns did not occur, zero probability generated');
%            p_whole1=realmin;
%         end
%         if p_2j==0
%             warning('certain patterns did not occur, zero probability generated');
%            p_whole2=realmin;
%         end
%         if (p_1j~=0 && p_j==0)
%         warning('certain patterns did not occur, zero probability generated');
%            p_j=realmin;
%            p_whole1=p_1j/(p_j*p1);
%         end
%         if (p_2j~=0 && p_j==0)
%         warning('certain patterns did not occur, zero probability generated');
%            p_j=realmin;
%            p_whole2=p_2j/(p_j*p2);
%         end
%         if (p_1j~=0 && p_j~=0)
%             p_whole1=p_1j/(p_j*p1);
%         end
%         if (p_2j~=0 && p_j~=0)
%             p_whole2=p_2j/(p_j*p2);
%         end
        %MI=p_1j*log2(p_whole1)+p_2j*log2(p_whole2);
        MI=p_1j*log2(p_1j/(p_j*p1))+p_2j*log2(p_2j/(p_j*p2));
        MI_sum=MI_sum+MI;
        
    end
    MI_sum1=MI_sum%-63/(1.3863*block);
    MI2(i)=MI_sum1;
end

MItotal=[MI1,MI2];

figure;
scatter(x_axis,MItotal,sz,'k','filled');
hold on;plot([0 x_axis(end)], [0,0],'k--','Linewidth',1);
ylim([-0.2 0.8]);
hold on;plot([transit_point transit_point],[-0.2 0.8], 'k-','LineWidth',1);
%hold on;plot([0 x_axis(end)], [3,3],'k--','Linewidth',1);
%ylim([0 4]);
xlabel('Trial'); ylabel('Mutual information (bits)');
title('Mutual information');
print(gcf, '-r0', [savebehfigpath sessionData.subject{1}, '_mutualinfo'], '-dpng'); %png format
saveas(gcf, [savebehfigpath sessionData.subject{1}, '_mutualinfo'], 'fig'); %fig format

%significance test
%probability right
[h1,p1]=ttest2(pRight1,pRight2);
[h2,p2]=ttest2(pReward1,pReward2);
[h3,p3]=ttest2(pStay1,pStay2);
[h4,p4]=ttest2(pWSLS1,pWSLS2);
[h5,p5]=ttest2(enA13,enA23);
[h6,p6]=ttest2(enA15,enA25);
