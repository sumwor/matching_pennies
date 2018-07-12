function [c_all,r_all,com_all, rsTime,index]=getDataWithMiss(base_dir)
%get the choice, reward, and computer choice history data (with miss
%trials, and do not concatenate)



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
c_all=cell(1,length(logfiles));r_all=cell(1,length(logfiles));com_all=cell(1,length(logfiles));

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
    
    
    
    c_all{i}=c; r_all{i}=r;com_all{i}=com;
  
end



