function [c_nomiss,r_nomiss,com_nomiss, rsTime,index]=getData(base_dir)
%get the choice, reward, and computer choice history data (without miss
%trials)
clear all;

base_dir = 'E:\data\matching_pennies\761\model_A2\';
%go back to check how well the parameters predict the actually behavior
%modify parameters to see how many trials we need to see the difference
%(changes in the parameters)

%bandit_setPathList(base_dir);
rewardCode=[10, 100, 111];
incorrectCode=[110, 101];
%data=
%'/Users/phoenix/Documents/Kwanlab/reinforcement_learning/logfile/human/170511/';\
cd(base_dir);
logfiles = dir('*.log');
c_all=[];r_all=[];com_all=[]; rs_all=[]; index=[];
rs=nan(500, length(logfiles));
%get concatenated choice and reward history

%try plot the response time for only first 200 trials in a session
%get mean response time versus trials(1-500)
for i =1:length(logfiles)
    [ logData ] = parseLogfileHW(base_dir, logfiles(i).name);
    
    [ sessionData, trialData] = MP_getSessionData( logData );
    c=double(trialData.response);
    for k=1:length(c)
        if c(k)~=0
          c(k)=(c(k)-2.5)*2;
        end
    end
    r=trialData.outcome;
    com=trialData.comChoiceCode;
    n_missed=sum(r==77);
    r(~ismember(r, rewardCode))=0;
    r(ismember(r, rewardCode))=1;
    
    %concatenate
    index=[index; (1:length(c))'];
    c_all=[c_all;c]; r_all=[r_all;r];com_all=[com_all; com];rs_all=[rs_all; trialData.rt];
    %get mean response time
    rs(1:length(trialData.rt),i)=trialData.rt;
end

c_nomiss=c_all(c_all~=0);
r_nomiss=r_all(c_all~=0);
com_nomiss=com_all(c_all~=0);
rsTime=rs_all(c_all~=0);
index=index(c_all~=0);

