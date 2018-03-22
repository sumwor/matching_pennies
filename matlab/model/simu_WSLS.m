function [c_simu, r_simu, com_simu,  comprob_simu]=simu_WSLS(N)

%simulate the behavior using win-stay-lose-switch model (from Daeyeol Lee, 2004) with fitted
%parameters

%input arguments
% N: number of trials altered
% alpha, delta1, delta0: fitted parameters
% index: index of parameters to be changed (1: alpha; 2: delta1; 3: delta0)
% change: percentage of change

trialPerSession=500;
numSession=N/trialPerSession;

%store the simulation results
c_simu=zeros(1, trialPerSession*numSession);
r_simu=zeros(1, trialPerSession*numSession);
com_simu=zeros(1, trialPerSession*numSession);
comprob_simu=zeros(1, trialPerSession*numSession);

for i=1:numSession
    choiceHis=[];
    rewardHis=[];
    comProbList=zeros(1,trialPerSession);
    dyncountlist=zeros(1,32);
    dyncountlistR=zeros(1,512);
    algorithm=2;
    for j=1:trialPerSession
        
        
        %update the dynamic programming counting
        [dyncountlist, dyncountlistR]=update_dynamic_a2(choiceHis, rewardHis, dyncountlist, dyncountlistR);
        
        %generate computer choice
        [comChoice,comProb]=com_choice(choiceHis, rewardHis, algorithm, dyncountlist, dyncountlistR);
        com_simu(trialPerSession*(i-1)+j)=comChoice;
        comprob_simu(trialPerSession*(i-1)+j)=comProb;
        
        %generate animal choice
        if j==1
            lastchoice=0; lastreward=0;
        else
            lastchoice=c_simu(trialPerSession*(i-1)+j-1); lastreward=r_simu(trialPerSession*(i-1)+j-1);
        end
        
        choice=agent_choice_WSLS(lastchoice,lastreward,j);
        c_simu(trialPerSession*(i-1)+j)=choice;
        choiceHis=[choiceHis,choice];
        
        %get the reward
        if c_simu(trialPerSession*(i-1)+j)==comChoice
            r_simu(trialPerSession*(i-1)+j)=1;
            rewardHis=[rewardHis,1];
        else
            r_simu(trialPerSession*(i-1)+j)=0;
            rewardHis=[rewardHis,0];
        end
        
        
    end
end



