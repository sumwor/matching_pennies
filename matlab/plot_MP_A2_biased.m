function plot_MP_A2_biased(sessionData, trialData, savebehfigpath)
%plot phase1_longWN logfile

% which figures are we going to generate
plotFig1=1;     %plot episodes aligned by start
episodeStart=-1;    %plot range for Fig1
%episodeEnd = 102;

plotFig1a = 1;
plotFig1b = 1;
plotFig2a=1;     %plot lick rate in waitlick period, random block and no lick period
plotFig2b=1;   %plot average lick rate 2s before go cue and 2s after the go cue
plotFig3=1;  %calculate the entropy
rewardCode=[10, 100, 111];
incorrectCode=[110, 101];
plotTrials=ceil(sessionData.nTrials / 100) * 100;

%trialData.startTimes = trialData.cueTimes;

%% ----- set up figure plotting
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

%% ----- create directory to save figure output
%savefigpath = [newroot_dir 'figs-beh/'];
%if ~exist(savefigpath,'dir')
%    mkdir(savefigpath);
%end

%% -----plot figure 1 for a overall session performance------
if (plotFig1)
    
    figure; hold on;
    title({['Mouse ' sessionData.subject{1} ' on ' sessionData.dateTime{1} ' ' sessionData.dateTime{2}(1:5)];' {\color{green}Reward} {\color{yellow}Incorrect} {\color{magenta}Timeout} {\color{black}L Licks} {\color{red}R Licks}'});
    %rewardIdx = 0;
    hit_miss = zeros(1, sessionData.nTrials); %record the hit/miss of every trial for later
    nolick_list = zeros(1, sessionData.nTrials);
    nolicktime_list=zeros(1,sessionData.nTrials-1);
    start_nolick = 1;
    %completetime=zeros(1, sessionData.nTrials);
    %rewardtimelist=zeros(1,sessionData.nTrials);
    for i=1:length(trialData.startTimes)-1
        episodeEnd = trialData.startTimes(i+1) - trialData.startTimes(i)-0.1;
        if i>1      %if it's not first episode, also look at negative time as specified by episodeStart
            episodeIndex = sessionData.time > (trialData.startTimes(i)+episodeStart+0.1) & sessionData.time < (trialData.startTimes(i)+0.1+episodeEnd);
        else
            episodeIndex = sessionData.time >= (trialData.startTimes(i)+0.1) & sessionData.time < (trialData.startTimes(i)+0.1+episodeEnd);
        end
        episodeIndexStart=find(episodeIndex,1,'first');     %getting the events that within [episodeStart, episodeEnd]
        episodeIndexEnd=find(episodeIndex,1,'last');     %getting the events that within [episodeStart, episodeEnd]
        if i < numel(trialData.startTimes)
            endtrialIdx = find(sessionData.time == trialData.startTimes(i+1), 1);
        end
        clear episodeIndex;
        
        num_nolick = 0;
        for ii =1:numel(sessionData.nTrials)
            for j=episodeIndexStart:episodeIndexEnd
                if sessionData.code(j) == 19 && j < endtrialIdx
                    num_nolick = num_nolick+1;
                end
            end 
        end
        nolick_list(i) = num_nolick;
        
        ifReward = 0;  %if 1: reward, if 2:incorrect no reward, if 3:miss
        for j=episodeIndexStart:episodeIndexEnd
            if ismember(sessionData.code(j),rewardCode) && j < endtrialIdx
                ifReward = 1;
                rewardtime = sessionData.time(j);
                hit_miss(i)=1;
                break;
            elseif ismember(sessionData.code(j),incorrectCode) && j < endtrialIdx
                ifReward = 2;
                rewardtime = sessionData.time(j);
                hit_miss(i)=2;
                break;
            end
        end
        
        %get the time of the nolick period
        if i<sessionData.nTrials
            nolicktime_list(i)=trialData.startTimes(i+1)-trialData.nolickTimes(start_nolick);
        end
        %completetime(i)=trialData.nolickTimes(start_nolick)-rewardtime;
        %rewardtimelist(i)=rewardtime;
        if ifReward == 1
            color = 'g';
            p=fill([rewardtime-trialData.startTimes(i)-0.1 trialData.nolickTimes(start_nolick)-trialData.startTimes(i)-0.1 trialData.nolickTimes(start_nolick)-trialData.startTimes(i)-0.1 rewardtime-trialData.startTimes(i)-0.1],[i-1 i-1 i i],color);
            set(p,'Edgecolor',color);
        elseif ifReward ==2
            color = 'y';
            p=fill([rewardtime-trialData.startTimes(i)-0.1 trialData.nolickTimes(start_nolick)-trialData.startTimes(i)-0.1 trialData.nolickTimes(start_nolick)-trialData.startTimes(i)-0.1 rewardtime-trialData.startTimes(i)-0.1],[i-1 i-1 i i],color);
            set(p,'Edgecolor',color);
        else
            color = 'm';
            p=fill([trialData.startTimes(i)-trialData.startTimes(i) trialData.nolickTimes(start_nolick)-trialData.startTimes(i)-0.1 trialData.nolickTimes(start_nolick)-trialData.startTimes(i)-0.1 trialData.startTimes(i)-trialData.startTimes(i)],[i-1 i-1 i i],color);
            set(p,'Edgecolor',color);
        end            
        
        %fill the nolick period, no last trial
        if i<numel(trialData.startTimes)
            nolick_color = 'b';
            nolick_p=fill([trialData.nolickTimes(start_nolick)-trialData.startTimes(i)-0.1 trialData.startTimes(i+1)-trialData.startTimes(i)-0.1 trialData.startTimes(i+1)-trialData.startTimes(i)-0.1 trialData.nolickTimes(start_nolick)-trialData.startTimes(i)-0.1],[i-1 i-1 i i],nolick_color);
            set(nolick_p, 'Edgecolor', nolick_color);
        end
        start_nolick= start_nolick + num_nolick;
        
        lickleftIndex = sessionData.lickTimes{1} > trialData.startTimes(i)+0.1+episodeStart & sessionData.lickTimes{1} <trialData.startTimes(i)+0.1+episodeEnd;
        plot([sessionData.lickTimes{1}(lickleftIndex)-trialData.startTimes(i)-0.1 sessionData.lickTimes{1}(lickleftIndex)-trialData.startTimes(i)-0.1]',i-1+[zeros(size(sessionData.lickTimes{1}(lickleftIndex))) ones(size(sessionData.lickTimes{1}(lickleftIndex)))]','k');
        lickrightIndex = sessionData.lickTimes{2} > trialData.startTimes(i)+0.1+episodeStart & sessionData.lickTimes{2} < trialData.startTimes(i)+0.1+episodeEnd;
        plot([sessionData.lickTimes{2}(lickrightIndex)-trialData.startTimes(i)-0.1 sessionData.lickTimes{2}(lickrightIndex)-trialData.startTimes(i)-0.1]',i-1+[zeros(size(sessionData.lickTimes{2}(lickrightIndex))) ones(size(sessionData.lickTimes{2}(lickrightIndex)))]','r');
    end
    plot([0 0],[0 length(trialData.startTimes)],'k','LineWidth',1);
%     for i=1:length(switchTrial)
%         plot([episodeStart episodeEnd],switchTrial(i)*[1 1],'k');
%     end
    axis([episodeStart,max(diff(trialData.startTimes)),0,length(trialData.startTimes)]);
    set(gca, 'ydir','reverse')
    xlabel('Time (s)');
    ylabel('Trial');
    
    set(gcf,'Position',[40 40 600 800]);  %laptop
    set(gcf, 'PaperPositionMode', 'auto');
    print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1}], '-dpng'); %png format
end



%% ------plot response time -------
b_width = 0.1;
responseTime=zeros(1, numel(trialData.startTimes));
lickTime=sort([sessionData.lickTimes{1}; sessionData.lickTimes{2}]);
for i =1:numel(trialData.startTimes)
    for j =1:numel(lickTime)
        if lickTime(j) > trialData.startTimes(i)
            responseTime(i) = lickTime(j)-trialData.startTimes(i);
            break;
        end
    end
end
responseTime=responseTime(logical(hit_miss));
bin_rep = zeros(1, 2/b_width);
x=0.05:0.1:1.95;
for k=1:2/b_width
    bin_rep(k) = sum(responseTime>=(0.1*(k-1)) & responseTime<(0.1*k));
end

figure;
bar(x,bin_rep,'k');
xlabel('Time(s)');
ylabel('Number of trials');
title(['Response time distribution']);
    
set(gcf,'Position',[40 40 1000 1000]);  %laptop
set(gcf, 'PaperPositionMode', 'auto');
print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1} '_responee time'], '-dpng'); %png format
saveas(gcf, [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10) '_' sessionData.scenarioName{1} '_response time'], 'fig'); %fig format

%%------plot the nolick period time
b_width = 0.5;

bin_rep_nolick = zeros(1, 2/b_width);
x=0.25:0.5:ceil(max(nolicktime_list));
for k=1:(ceil(max(nolicktime_list))/b_width)
    bin_rep_nolick(k) = sum(nolicktime_list>=(0.5*(k-1)) & nolicktime_list<(0.5*k));
end

figure;
bar(x,bin_rep_nolick,'k');
xlabel('Time(s)');
ylabel('Number of trials');
xlim([0 ceil(max(nolicktime_list))]);
title(['Nolick time distribution']);
meantime=mean(nolicktime_list);
yl=ylim;

hold on;plot([meantime meantime],[0 yl(2)], 'k-','LineWidth',1);
set(gcf,'Position',[40 40 1000 1000]);  %laptop
set(gcf, 'PaperPositionMode', 'auto');
print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1} '_nolick time'], '-dpng'); %png format
saveas(gcf, [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10) '_' sessionData.scenarioName{1} '_nolick time'], 'fig'); %fig format

%% ------ plot performance (right choice rate) over a running window, and plot the win-stay/lose-switch rate
%%------ also calculate the rate of win-stay in all wins and the rate of lose switch in all loses
% and report the average precentage over the whole session
if (plotFig1a)
    

    %quantify performance using a running average
    consecStim=10;          %conseuctive trials used for generated time-lapse hit rate plots
    bin_hitRate=[]; %left and right hit rates in every n-stim bin
    bin_rightRate=[];
    %bin_lickRate = [];
    bin_WSLS=[];
    bin_WS=[];
    bin_LS=[];
    bin_WSinW=[];
    bin_LSinL=[];
    totalLose=sum(hit_miss==2);
    totalWin=sum(hit_miss==1);
    totalWS=0;
    totalLS=0;
    
    for i =1:numel(trialData.startTimes)-1
        if hit_miss(i)==1
            if trialData.response(i+1)==trialData.response(i)
                totalWS=totalWS+1;
            end
        elseif hit_miss(i)==2
            if trialData.response(i+1)~=trialData.response(i)
                totalLS=totalLS+1;
            end
        end
    end
    
    for i=-consecStim+1:numel(trialData.startTimes)-consecStim
        
        endIdx=(i+consecStim-1);
        
        startIdx=i;
        %is startIdx trial near post-switch? if so, instead of using 10 prior trials, use prior trials up to switch only
        if startIdx<1
            startIdx=1;
        end
        
        tempwinstay=0;
        tempwin=0;
        templose=0;
        temploseswitch=0;
        tempHit=sum(hit_miss(startIdx:endIdx)==1);
        tempRight=sum(trialData.response(startIdx:endIdx)==3);
 
        
        %calculate hit rate
        if numel(hit_miss(startIdx:endIdx)) == 0
            bin_hitRate=[bin_hitRate 0];
        else
            bin_hitRate=[bin_hitRate 100*(tempHit)/numel(hit_miss(startIdx:endIdx))];
        end
        
        %calculate win-stay and lose-switch rate
        for j = startIdx:endIdx
            if hit_miss(j)==1
                tempwin=tempwin+1;
                if j+1<=endIdx
                    if trialData.response(j+1)==trialData.response(j)
                        tempwinstay=tempwinstay+1;
                    end
                end
            elseif hit_miss(j)==2
                templose=templose+1;
                if j+1<=endIdx
                    if trialData.response(j+1)~=trialData.response(j)
                        temploseswitch=temploseswitch+1;
                    end
                end
            end
        end
        
       % totalWS=totalWS+tempwinstay;
        %totalLS=totalLS+temploseswitch;
        bin_WSLS=[bin_WSLS, 100*(tempwinstay+temploseswitch)/numel(hit_miss(startIdx:endIdx))];
        bin_WS=[bin_WS, 100*(tempwinstay)/numel(hit_miss(startIdx:endIdx))];
        bin_LS=[bin_LS, 100*temploseswitch/numel(hit_miss(startIdx:endIdx))];
        bin_WSinW=[bin_WSinW, 100*tempwinstay/tempwin];
        bin_LSinL=[bin_LSinL, 100*temploseswitch/templose];
        bin_rightRate=[bin_rightRate,100*tempRight/numel(trialData.response(startIdx:endIdx))];
    end
    
    
    figure;
    subplot(3,1,1)
    plot([1:numel(trialData.startTimes)],bin_rightRate,'k','LineWidth',2);
    axis([0 numel(trialData.startTimes) 0 105]);
    ylabel('Average right choice rate (%)');
    title(['Running average of ' int2str(consecStim) ' trials']);
    
    subplot(3,1,2)
    plot([1:numel(trialData.startTimes)],bin_WSLS,'LineWidth',2);
    hold on;plot([1:numel(trialData.startTimes)],bin_WS,'LineWidth',2);
    hold on;plot([1:numel(trialData.startTimes)],bin_LS,'LineWidth',2);
    legend('WSLS','WS','LS');
    ylabel('Average rate (%)');
    title(['Running average of ' int2str(consecStim) ' trials']);
    
    subplot(3,1,3)
    plot([1:numel(trialData.startTimes)],bin_WSinW,'LineWidth',2);
    hold on;plot([1:numel(trialData.startTimes)],bin_LSinL,'LineWidth',2);
    hold on; plot([0, numel(trialData.startTimes)], [100*totalWS/totalWin, 100*totalWS/totalWin],'-');
    hold on; plot([0, numel(trialData.startTimes)], [100*totalLS/totalLose, 100*totalLS/totalLose],'-');
    legend('WSinW','LSinL', ['ave WS ', num2str(100*totalWS/totalWin)],['ave LS ',num2str(100*totalLS/totalLose)]);
    ylabel('Average rate (%)');
    title(['Running average of ' int2str(consecStim) ' trials']);
    
    set(gcf,'Position',[40 40 1000 1000]);  %laptop
    set(gcf, 'PaperPositionMode', 'auto');
    print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1} '_running average'], '-dpng'); %png format
    saveas(gcf, [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10) '_' sessionData.scenarioName{1} '_runningavg'], 'fig'); %fig format
end

%% --------plot choice rate over a running window
if (plotFig1b)
   n_plot=plotTrials;
    
    figure;
    %for later computer choice, no such data for now
%     subplot(4,1,1);
%     plot(p(:,1),'r','LineWidth',2);
%     hold on;
%     plot(p(:,2),'b','LineWidth',2);
%     ylabel('Reward prob.');
%     legend('Left','Right');
%     xlim([0 n_plot]);
%     set(gca,'xticklabel',[]);
%     title(tlabel);
    
    %get the choice
    c=double(trialData.response);
    for i=1:length(c)
        if c(i)~=0
          c(i)=(c(i)-2.5)*2;
        end
    end
    
    %get the outcome
    r=trialData.outcome;
    n_missed=sum(r==77);
    r(~ismember(r, rewardCode))=0;
    r(ismember(r, rewardCode))=1;
    ave_rRate=sum(r)/(length(r)-n_missed);
    
    %take in the choice history
choiceHis=trialData.response;
pValueList=zeros(1, length(choiceHis));
comProbList=zeros(1,length(choiceHis));
dyncountlist=zeros(1,32);
dyncountlistR=zeros(1,512);
runningchoice=[];
runningreward=[];
entropyCount1=zeros(1,8);
entropyCount2=zeros(1,32);
dynentropyCount1=zeros(n_plot,8);

IndNeed=[0, 4, 8, 12, 16, 20, 24, 28];
Ind1=[0, 4, 8, 12, 16, 20, 24, 28];
for i =1:8
    Ind1(i)=Ind1(i)+64;
end
IndNeed=[IndNeed,Ind1];
temp=zeros(1,16);
for i =1:16
    temp(i)=IndNeed(i)+128;
end
IndNeed=[IndNeed,temp];
temp2=zeros(1,32);
for i =1:32
    temp2(i)=IndNeed(i)+256;
end
IndNeed=[IndNeed,temp2];
%when running binomial test, ignore the miss trials
leftCountRMat=zeros(plotTrials,5);
rightCountRMat=zeros(plotTrials,5);
leftCountMat=zeros(plotTrials,5);
rightCountMat=zeros(plotTrials,5);
leftCountR=0;
rightCountR=0;
pMin=zeros(1,plotTrials);
mMin=zeros(1,plotTrials);%for debug
for i =1:length(choiceHis-1)
    if choiceHis(i)~=0
        runningchoice=[runningchoice, choiceHis(i)];
        runningreward=[runningreward, r(i)];
    end
    maxP=0.05;
    
    %get the entropycount
    if length(runningchoice)>=3 && choiceHis(i)~=0
        entroSeq1=runningchoice(end-2:end)-2;
        entroSeq2=[entroSeq1,runningreward(end-2:end-1)];
        entroInd1=bin2dec(num2str(entroSeq1))+1;
        entroInd2=bin2dec(num2str(entroSeq2))+1;
        entropyCount1(entroInd1)=entropyCount1(entroInd1)+1;
        entropyCount2(entroInd2)=entropyCount2(entroInd2)+1;
        for j=1:8
            if j==entroInd1
                dynentropyCount1(i,j)=entropyCount1(entroInd1);
            else
                dynentropyCount1(i,j)=dynentropyCount1(i-1,j);
            end
        end
    elseif length(runningchoice)>=3 && choiceHis(i)==0
        dynentropyCount1(i,:)=dynentropyCount1(i-1,:);
    end
    pvalue=zeros(0,0);
    comProb=0.67;
    if length(runningchoice)<5
        pValueList(i)=maxP;
        comProbList(i)=comProb;
    else
        %dynamic counting
        if choiceHis(i)~=0
            updateSeqR=[runningreward(end-4:end-1),runningchoice(end-4:end)-2];
            IndR=bin2dec(num2str(updateSeqR))+1;
            dyncountlistR(IndR)=dyncountlistR(IndR)+1;
            Ind=bin2dec(num2str(runningchoice(end-4:end)-2))+1;
            dyncountlist(Ind)=dyncountlist(Ind)+1;
        end
        
        %do the choice counting
        
        for j = 1:5
           leftCountR=0;
           rightCountR=0;
           if j==1
               leftCount=sum(runningchoice==2);
               rightCount=sum(runningchoice==3);
           else
               searchSeqR=runningreward(end-j+2:end);
               for x=1:4-j+1
                   searchSeqR=[searchSeqR,0];
               end
               searchSeqR=[searchSeqR,runningchoice(end-j+2:end)-2,0];
               baseIndR=bin2dec(num2str(searchSeqR))+1;
               searchSeq=[runningchoice(end-j+2:end),2];
               baseInd=bin2dec(num2str(searchSeq-2))+1;
               if j==5
                   leftCount=dyncountlist(baseInd);
                   rightCount=dyncountlist(baseInd+1);
                   leftCountR=dyncountlistR(baseIndR);
                   rightCountR=dyncountlistR(baseIndR+1);
               elseif j==4
                   leftCount=dyncountlist(baseInd)+dyncountlist(baseInd+16);
                   rightCount=dyncountlist(baseInd+1)+dyncountlist(baseInd+17);
                   leftCountR=dyncountlistR(baseIndR)+dyncountlistR(baseIndR+16)+dyncountlistR(baseIndR+256)+dyncountlistR(baseIndR+272);
                   rightCountR=dyncountlistR(baseIndR+1)+dyncountlistR(baseIndR+17)+dyncountlistR(baseIndR+257)+dyncountlistR(baseIndR+273);
               elseif j==3
                   leftCount=dyncountlist(baseInd)+dyncountlist(baseInd+16)+dyncountlist(baseInd+8)+dyncountlist(baseInd+24);
                   rightCount=dyncountlist(baseInd+17)+dyncountlist(baseInd+1)+dyncountlist(baseInd+9)+dyncountlist(baseInd+25);
                   leftCountR=dyncountlistR(baseIndR)+dyncountlistR(baseIndR+8)+dyncountlistR(baseIndR+16)+dyncountlistR(baseIndR+24)+dyncountlistR(baseIndR+128)+dyncountlistR(baseIndR+136)+dyncountlistR(baseIndR+144)+dyncountlistR(baseIndR+152)+dyncountlistR(baseIndR+256)+dyncountlistR(baseIndR+264)+dyncountlistR(baseIndR+272)+dyncountlistR(baseIndR+280)+dyncountlistR(baseIndR+384)+dyncountlistR(baseIndR+392)+dyncountlistR(baseIndR+400)+dyncountlistR(baseIndR+408);
                   rightCountR=dyncountlistR(baseIndR+1)+dyncountlistR(baseIndR+9)+dyncountlistR(baseIndR+17)+dyncountlistR(baseIndR+25)+dyncountlistR(baseIndR+129)+dyncountlistR(baseIndR+137)+dyncountlistR(baseIndR+145)+dyncountlistR(baseIndR+153)+dyncountlistR(baseIndR+257)+dyncountlistR(baseIndR+265)+dyncountlistR(baseIndR+273)+dyncountlistR(baseIndR+281)+dyncountlistR(baseIndR+385)+dyncountlistR(baseIndR+393)+dyncountlistR(baseIndR+401)+dyncountlistR(baseIndR+409);
               elseif j==2
                   leftCount=dyncountlist(baseInd)+dyncountlist(baseInd+4)+dyncountlist(baseInd+8)+dyncountlist(baseInd+12)+dyncountlist(baseInd+16)+dyncountlist(baseInd+20)+dyncountlist(baseInd+24)+dyncountlist(baseInd+28);
                   rightCount=dyncountlist(baseInd+1)+dyncountlist(baseInd+5)+dyncountlist(baseInd+9)+dyncountlist(baseInd+13)+dyncountlist(baseInd+17)+dyncountlist(baseInd+21)+dyncountlist(baseInd+25)+dyncountlist(baseInd+29);
                   for x=1:length(IndNeed)
                       leftCountR=leftCountR+dyncountlistR(baseIndR+IndNeed(x));
                       rightCountR=rightCountR+dyncountlistR(baseIndR+IndNeed(x)+1);
                   end
               end
           
           end
           leftCountMatR(i+1,j)=leftCountR;
           rightCountMatR(i+1,j)=rightCountR;
           leftCountMat(i+1,j)=leftCount;
           rightCountMat(i+1,j)=rightCount;
           
           totalN = leftCount+rightCount;
           totalNR=leftCountR+rightCountR;
           pValue=myBinomTest(leftCount,totalN, 0.67,'Two');
           pValueR=myBinomTest(leftCountR,totalNR, 0.67,'Two');
           pvalue=[pvalue,pValue,pValueR];
           if pValue < maxP
               %probability = rightCount/totalN;\
               if abs(leftCount/totalN-0.67)> abs(comProb-0.67)
                  comProb=leftCount/totalN;
               end
           end
           if pValueR<maxP
               if abs(leftCountR/totalNR-0.67)> abs(comProb-0.67)
            
                  comProb=leftCountR/totalNR;
               end
           end
        end
        comProbList(i)=comProb;
    end
end

%another counting method:


    
    subplot(4,1,1);
    bar(-1*(trialData.comChoiceCode==-1),1,'FaceColor','r','EdgeColor','none');
    hold on;
    bar((trialData.comChoiceCode==1),1,'FaceColor','b','EdgeColor','none');
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
    yticks([0 1]);
    yticklabels({'No reward','Reward'});
    xlim([0 n_plot]);
    hold on;
    filtered_R = smooth(double(r==1),10,'lowess');
    filtered_R(filtered_R>1)=1; filtered_R(filtered_R<0)=0;
    plot(filtered_R,'r','LineWidth',2);
    strmax = ['Average reward = ',num2str(ave_rRate)];
    text(plotTrials,1.1,strmax,'HorizontalAlignment','right');
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
    plot([1:numel(trialData.startTimes)],comProbList,'k','LineWidth',2);  
    hold on;
    ylabel('P(right) for computer');
    xlim([0 n_plot]);
    ylim([-0.1 1.1]);
    xlabel('Trial');
    
    
    print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1} '_session_beh'], '-dpng'); %png format
    saveas(gcf, [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10) '_' sessionData.scenarioName{1} '_session_beh'], 'fig'); %fig format

end


%%--check some p-values and choice
% leftAfterLeft=0;
% totalAfterLeft=0;
% leftAfterRight=0;
% totalAfterRight=0;
% for i=200:499
%     if comProbList(i)>0.5
%         totalAfterRight=totalAfterRight+1;
%         if trialData.response(i+1)==2
%             leftAfterRight=leftAfterRight+1;
%         end
%     end
%     if comProbList(i)<=0.5
%         totalAfterLeft=totalAfterLeft+1;
%         if trialData.response(i+1)==2
%             leftAfterLeft=leftAfterLeft+1;
%         end
%     end
% end

%%------plot the most significant test
% figure;plot(pMin,'d');
% ylim([0 9]);
% yticks([0,1,2,3,4,5,6,7,8,9]);
% yticklabels({'null','r_1','r_2','r_3','r_4','c_0','c_1','c_2','c_3','c_4'});
% title("most sigificant test");
% print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1} '_bi_test'], '-dpng'); %png format
% saveas(gcf, [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10) '_' sessionData.scenarioName{1} '_bi_test'], 'fig'); %fig format

%%check the function in behavior simulation is correct or not
% comProb_simu=zeros(1,length(choiceHis));
% dyncountlist1=zeros(1,32);
% dyncountlistR1=zeros(1,512);
% runningchoice1=[]; runningreward1=[];
% algorithm=2;
% for i =1:length(choiceHis)
%     if choiceHis(i)~=0
%         runningchoice1=[runningchoice1, choiceHis(i)];
%         runningreward1=[runningreward1, r(i)];
%         [dyncountlist1, dyncountlistR1]=update_dynamic_a2(runningchoice1, runningreward1, dyncountlist1, dyncountlistR1);
%     end
%     
%         
%     %generate computer choice
%     [comChoice,comProb]=com_choice(runningchoice1, runningreward1, algorithm, dyncountlist1, dyncountlistR1);
%     comProb_simu(i)=comProb;
% end
% figure; plot(comProb_simu);
% figure;plot(comProb_simu-comProbList);

cmap=jet(8);
figure;
for i=1:8
    plot(dynentropyCount1(:,i), 'LineWidth',2, 'Color', cmap(i, :));
    hold on;
end
ylabel('Occurrence');
xlabel('Trial');
legend('LLL','LLR','LRL','LRR','RLL','RLR','RRL','RRR','Location','northwest');
title("Cumulative # of 3-choice patterns");
print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1} '_cumulative_patterns'], '-dpng'); %png format
saveas(gcf, [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10) '_' sessionData.scenarioName{1} '_cumulative_patterns'], 'fig'); %fig format
%% -------- plot number of nolick periods in different trials ------
% if (plotFig2a)
%     lick_num_wait = zeros(1, numel(trialData.startTimes)-1);  lick_num_nolick = zeros(1, numel(trialData.startTimes)-1);
%     wait_timebin = zeros(1, numel(trialData.startTimes)-1);  nolick_timebin = zeros(1, numel(trialData.startTimes)-1);
%     for i=1:numel(trialData.startTimes) - 1
%         templickLeft = find(sessionData.lickTimes{1} > trialData.startTimes(i) & sessionData.lickTimes{1} < trialData.nolickTimes(i));
%         templickRight = find(sessionData.lickTimes{2} > trialData.startTimes(i) & sessionData.lickTimes{2} < trialData.nolickTimes(i));
%         lick_num_wait(i) = numel(templickLeft) + numel(templickRight);
%         wait_timebin(i) = trialData.nolickTimes(i) - trialData.startTimes(i);
%         templickLeft = find(sessionData.lickTimes{1} > trialData.nolickTimes(i) & sessionData.lickTimes{1} < trialData.startTimes(i+1));
%         templickRight = find(sessionData.lickTimes{2} > trialData.nolickTimes(i) & sessionData.lickTimes{2} < trialData.startTimes(i+1));
%         lick_num_nolick(i) = numel(templickLeft) + numel(templickRight);
%         nolick_timebin(i) = trialData.startTimes(i+1) - trialData.nolickTimes(i);
%     end
%     lickrate_wait = lick_num_wait ./ wait_timebin;
%     lickrate_nolick = lick_num_nolick ./ nolick_timebin;
%     
%     mean_lickrate_wait = mean(lickrate_wait);
%     mean_lickrate_nolick = mean(lickrate_nolick);
%     figure;
%     subplot(2, 1, 1);
%     plot([1:(numel(trialData.startTimes)-1)], lickrate_wait);
%     hold on; plot([1 (numel(trialData.startTimes)-1)],[mean_lickrate_wait mean_lickrate_wait], '-');
%     
%     xlabel('trial number');
%     ylabel('lick rate (Hz)');
%     title(['lick rate (Left + Right) per trial during wait lick period']);
%     legend('lick rate every trial', ['average lick rate ' num2str(mean_lickrate_wait)]);
%     
%     subplot(2, 1, 2);
%     plot([1:(numel(trialData.startTimes)-1)], lickrate_nolick);
%     hold on; plot([1 (numel(trialData.startTimes)-1)],[mean_lickrate_nolick mean_lickrate_nolick], '-');
%     
%     xlabel('trial number');
%     ylabel('lick rate (Hz)');
%     title(['lick rate (Left + Right) per trial during no lick period']);
%     legend('lick rate every trial', ['average lick rate ' num2str(mean_lickrate_nolick)]);
%    
%     set(gcf,'Position',[40 40 1000 1000]);  %laptop
%     set(gcf, 'PaperPositionMode', 'auto');
%     print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1} '_lick rate'], '-dpng'); %png format
%     saveas(gcf, [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10) '_' sessionData.scenarioName{1} '_lick rate'], 'fig'); %fig format
% end


%% --------plot number of nolick period in different trials

ave_nolick = mean(nolick_list(logical(hit_miss)));
figure;
plot(nolick_list);
hold on; plot([0, numel(nolick_list)], [ave_nolick, ave_nolick],'-');
xlabel('Trial number');
ylabel('Number of no lick periods');
legend('Number of nolick period per trial', ['Average number (hit trials only):', num2str(ave_nolick)]);

set(gcf,'Position',[40 40 1000 1000]);  %laptop
set(gcf, 'PaperPositionMode', 'auto');
print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1} '_number of nolick'], '-dpng'); %png format
saveas(gcf, [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10) '_' sessionData.scenarioName{1} '_number of nolick'], 'fig'); %fig format


%%------------number of NL period distribution after reward/no reward/miss
%%trials
reward_NL = nolick_list(hit_miss ==1);
noreward_NL = nolick_list(hit_miss ==2);
miss_NL = nolick_list(hit_miss == 0);
left_NL = nolick_list(trialData.response==2);
right_NL = nolick_list(trialData.response==3);

%get the bar plot
Frequency = zeros(5, 3);
Frequency_choice = zeros(5,2);
for i=1:5
    Frequency(i,1) = sum(reward_NL ==i)/length(reward_NL);
end
for j=1:5
    Frequency(j,2) = sum(noreward_NL ==j)/length(noreward_NL);
end
for k=1:5
    Frequency(k,3) = sum(miss_NL ==k)/length(miss_NL);
end
for u=1:5
    Frequency_choice(u,1) = sum(left_NL ==u)/length(left_NL);
end
for v=1:5
    Frequency_choice(v,2) = sum(right_NL ==v)/length(right_NL);
end

figure;
bar(Frequency);
legend('reweard', 'noreward','miss');
xlabel("# of No Lick Period");
ylabel("Percentage of Trials (%)");
print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1} '_number of nolick distribution'], '-dpng'); %png format
saveas(gcf, [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10) '_' sessionData.scenarioName{1} '_number of nolick distribution'], 'fig'); %fig format

figure;
bar(Frequency_choice);
legend('left', 'right');
xlabel("# of No Lick Period");
ylabel("Percentage of Trials (%)");
print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1} '_number of nolick distribution_choice'], '-dpng'); %png format
saveas(gcf, [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10) '_' sessionData.scenarioName{1} '_number of nolick distribution_choice'], 'fig'); %fig format
%% -------- plot average lick rate 2s before and following the go cue ------
 TotalTime = 2;
 %running average of lick rate, time_bin = 0.1s
 t_bin = 0.1;
  
lickBeforeGohit = zeros(1, numel(trialData.startTimes)-1);  lickAfterGohit = zeros(1, numel(trialData.startTimes)-1);
lickBeforeGomiss = zeros(1, numel(trialData.startTimes)-1);  lickAfterGomiss = zeros(1, numel(trialData.startTimes)-1);
 
runningLickRBeforeGo =zeros(numel((trialData.startTimes) -1), TotalTime/t_bin);
runningLickRAfterGo = zeros(numel((trialData.startTimes) -1), TotalTime/t_bin);
 

 
 %for go cue period
 for i=1:numel(trialData.startTimes) - 1
     if i > 1  
        if hit_miss(i) == 1
            templickBeforeLefthit = find(sessionData.lickTimes{1} > (trialData.startTimes(i)-TotalTime) & sessionData.lickTimes{1} < trialData.startTimes(i));
            templickBeforeRighthit = find(sessionData.lickTimes{2} > (trialData.startTimes(i)-TotalTime) & sessionData.lickTimes{2} < trialData.startTimes(i));
            templickAfterLefthit =  find(sessionData.lickTimes{1} > (trialData.startTimes(i)) & sessionData.lickTimes{1} < (trialData.startTimes(i)+TotalTime));
            templickAfterRighthit =  find(sessionData.lickTimes{2} > (trialData.startTimes(i)) & sessionData.lickTimes{2} < (trialData.startTimes(i)+TotalTime));
            
            lickBeforeGohit(i) = numel(templickBeforeLefthit) + numel(templickBeforeRighthit);
            lickAfterGohit(i) = numel(templickAfterLefthit) + numel(templickAfterRighthit);
            
            %calculate the running lick rate before and after the go cue
            for j = 1: (TotalTime/t_bin - 1)
                templickBeforeGoLeft = find(sessionData.lickTimes{1} > (trialData.startTimes(i)-TotalTime + j*t_bin) & sessionData.lickTimes{1} < (trialData.startTimes(i)-TotalTime + (j+1)*t_bin));
                templickBeforeGoRight = find(sessionData.lickTimes{2} > (trialData.startTimes(i)-TotalTime + j*t_bin) & sessionData.lickTimes{2} < (trialData.startTimes(i)-TotalTime + (j+1)*t_bin));
                templickAfterGoLeft = find(sessionData.lickTimes{1} > (trialData.startTimes(i) + j*t_bin) & sessionData.lickTimes{1} < (trialData.startTimes(i) + (j+1)*t_bin));
                templickAfterGoRight = find(sessionData.lickTimes{2} > (trialData.startTimes(i) + j*t_bin) & sessionData.lickTimes{2} < (trialData.startTimes(i) + (j+1)*t_bin));
                templickBeforeGo = numel(templickBeforeGoLeft) + numel(templickBeforeGoRight);
                templickAfterGo = numel(templickAfterGoLeft) + numel(templickAfterGoRight);
                runningLickRBeforeGo(i,j) = templickBeforeGo / t_bin;
                runningLickRAfterGo(i,j) =  templickAfterGo / t_bin;
            end
            
            %for white noise period
            templickBeforeLefthitWN = find(sessionData.lickTimes{1} > (trialData.nolickTimes(i)-TotalTime) & sessionData.lickTimes{1} < trialData.nolickTimes(i));
            templickBeforeRighthitWN = find(sessionData.lickTimes{2} > (trialData.nolickTimes(i)-TotalTime) & sessionData.lickTimes{2} < trialData.nolickTimes(i));
            templickAfterLefthitWN =  find(sessionData.lickTimes{1} > (trialData.nolickTimes(i)) & sessionData.lickTimes{1} < (trialData.nolickTimes(i)+TotalTime));
            templickAfterRighthitWN =  find(sessionData.lickTimes{2} > (trialData.nolickTimes(i)) & sessionData.lickTimes{2} < (trialData.nolickTimes(i)+TotalTime));
            
            lickBeforeWNhit(i) = numel(templickBeforeLefthitWN) + numel(templickBeforeRighthitWN);
            lickAfterWNhit(i) = numel(templickAfterLefthitWN) + numel(templickAfterRighthitWN);
            
            %calculate the running lick rate before and after the go cue
            for j = 1: TotalTime/t_bin
                templickBeforeWNLeft = find(sessionData.lickTimes{1} > (trialData.nolickTimes(i)-TotalTime + (j-1)*t_bin) & sessionData.lickTimes{1} < (trialData.nolickTimes(i)-TotalTime + j*t_bin));
                templickBeforeWNRight = find(sessionData.lickTimes{2} > (trialData.nolickTimes(i)-TotalTime + (j-1)*t_bin) & sessionData.lickTimes{2} < (trialData.nolickTimes(i)-TotalTime + j*t_bin));
                templickAfterWNLeft = find(sessionData.lickTimes{1} > (trialData.nolickTimes(i) + (j-1)*t_bin) & sessionData.lickTimes{1} < (trialData.nolickTimes(i) + j*t_bin));
                templickAfterWNRight = find(sessionData.lickTimes{2} > (trialData.nolickTimes(i) + (j-1)*t_bin) & sessionData.lickTimes{2} < (trialData.nolickTimes(i) + j*t_bin));
                templickBeforeWN = numel(templickBeforeWNLeft) + numel(templickBeforeWNRight);
                templickAfterWN = numel(templickAfterWNLeft) + numel(templickAfterWNRight);
                runningLickRBeforeWN(i,j) = templickBeforeWN / t_bin;
                runningLickRAfterWN(i,j) =  templickAfterWN / t_bin;
            end
            
        else
            %go cue period
            templickBeforeLeftmiss = find(sessionData.lickTimes{1} > (trialData.startTimes(i)-TotalTime) & sessionData.lickTimes{1} < trialData.startTimes(i));
            templickBeforeRightmiss = find(sessionData.lickTimes{2} > (trialData.startTimes(i)-TotalTime) & sessionData.lickTimes{2} < trialData.startTimes(i));
            templickAfterLeftmiss =  find(sessionData.lickTimes{1} > (trialData.startTimes(i)) & sessionData.lickTimes{1} < (trialData.startTimes(i)+TotalTime));
            templickAfterRightmiss =  find(sessionData.lickTimes{2} > (trialData.startTimes(i)) & sessionData.lickTimes{2} < (trialData.startTimes(i)+TotalTime));
            
            lickBeforeGomiss(i) = numel(templickBeforeLeftmiss) + numel(templickBeforeRightmiss);
            lickAfterGomiss(i) = numel(templickAfterLeftmiss) + numel(templickAfterRightmiss);
            
            %white noise period
            templickBeforeLeftmissWN = find(sessionData.lickTimes{1} > (trialData.nolickTimes(i)-TotalTime) & sessionData.lickTimes{1} < trialData.nolickTimes(i));
            templickBeforeRightmissWN = find(sessionData.lickTimes{2} > (trialData.nolickTimes(i)-TotalTime) & sessionData.lickTimes{2} < trialData.nolickTimes(i));
            templickAfterLeftmissWN =  find(sessionData.lickTimes{1} > (trialData.nolickTimes(i)) & sessionData.lickTimes{1} < (trialData.nolickTimes(i)+TotalTime));
            templickAfterRightmissWN =  find(sessionData.lickTimes{2} > (trialData.nolickTimes(i)) & sessionData.lickTimes{2} < (trialData.nolickTimes(i)+TotalTime));
            
            lickBeforeWNmiss(i) = numel(templickBeforeLeftmissWN) + numel(templickBeforeRightmissWN);
            lickAfterWNmiss(i) = numel(templickAfterLeftmissWN) + numel(templickAfterRightmissWN);
        end
        
     else
         lickBeforeGohit(i) = 0; lickBeforeGomiss(i)=0;
         runningLickRBeforeGo(i,:) = zeros(1, TotalTime/t_bin);
       
     end
     
 end

     
 runningAverageBeforeGo = mean(runningLickRBeforeGo, 1);
 runningAverageAfterGo = mean(runningLickRAfterGo, 1);

 
 meanLickRBeforeGohit = mean(lickBeforeGohit ./ TotalTime);
 meanLickRAfterGohit = mean(lickAfterGohit ./ TotalTime);
 
 %missed trials may useless
 meanLickRBeforeGomiss = mean(lickBeforeGomiss ./ TotalTime);
 meanLickRAfterGomiss = mean(lickAfterGomiss ./ TotalTime); %must be zero since miss is no licking within 2 seconds after the go cue
 
 figure;
 

 plot([-1.95:0.1:1.95], [runningAverageBeforeGo runningAverageAfterGo], 'black', 'LineWidth', 2);
 
 hold on; plot([-1.95, 0],[meanLickRBeforeGohit, meanLickRBeforeGohit],'LineWidth', 1);
 hold on; plot([0, 1.95], [meanLickRAfterGohit, meanLickRAfterGohit], 'LineWidth', 1);
 hold on; plot([0, 0], [0, 5], '-');
 legend('Licking rate', ['Mean rate before ', num2str(meanLickRBeforeGohit)], ['Mean rate after ' num2str(meanLickRAfterGohit)]);
 xlabel('Time from go cue (s)');
 ylabel('Lick rate (Hz)');
 title('Average licking rate from go cue');
 
 
 
 set(gcf,'Position',[40 40 1000 1000]);  %laptop
 set(gcf, 'PaperPositionMode', 'auto');
 print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1} '_running_lick_rate'], '-dpng'); %png format
 saveas(gcf, [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10) '_' sessionData.scenarioName{1} '_running_lick_rate'], 'fig'); %fig format
 
 %%-----plot win-stay/lose-switch rate
 
 %% calculate the entropy
 if (plotFig3) 
    %for three consecutive trials
    
    p1=entropyCount1/sum(entropyCount1);
    if ismember(0,p1)
        warning('certain patterns did not occur, zero probability generated');
        IndexZero=find(~p1);
        for i=1:length(IndexZero)
            p1(IndexZero(i))=realmin;
        end
    end
    en1=-sum(p1.*log2(p1))+(length(p1)-1)/(1.3863*sum(entropyCount1));
    p2=entropyCount2/sum(entropyCount2);
    if ismember(0,p2)
        warning('certain patterns did not occur, zero probability generated');
        IndexZero=find(~p2);
        for i=1:length(IndexZero)
            p2(IndexZero(i))=realmin;
        end
    end
    en2=-sum(p2.*log2(p2))+(length(p2)-1)/(1.3863*sum(entropyCount2));
    enbar=[en1,en2];
    c=categorical({'E_3','E_5'});
    figure;bar(c,enbar);
    title('Average entropy of the session');
    set(gcf,'Position',[40 40 1000 1000]);  %laptop
    set(gcf, 'PaperPositionMode', 'auto');
    print(gcf, '-r0', [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10)  '_' sessionData.scenarioName{1} '_entropy'], '-dpng'); %png format
    saveas(gcf, [savebehfigpath sessionData.subject{1} '_' sessionData.dateTime{1}(1:2) '_' sessionData.dateTime{1}(4:5) '_' sessionData.dateTime{1}(7:10) '_' sessionData.scenarioName{1} '_entropy'], 'fig'); %fig format
    en1
    en2
 end
 
 %%%fit the reinforcement leanring model
 %fit_modelMP(c,r);