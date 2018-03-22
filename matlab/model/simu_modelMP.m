function [c_simu, r_simu, com_simu,  comprob_simu,altered_tList]=simu_modelMP(N, alpha, delta1, delta0,index, change)

%simulate the behavior using RL model (from Daeyeol Lee, 2004) with fitted
%parameters

%input arguments
% N: number of trials altered
% alpha, delta1, delta0: fitted parameters
% index: index of parameters to be changed (1: alpha; 2: delta1; 3: delta0)
% cahnge: percentage of change

trialPerSession=204;
alteredTrial=4;

numSession=N/alteredTrial;

bet=1; %for the inverse temperature (not needed in Daeyeol's model)

valueL=0; valueR=0;
%store the simulation results
c_simu=zeros(1, trialPerSession*numSession);
r_simu=zeros(1, trialPerSession*numSession);
com_simu=zeros(1, trialPerSession*numSession);
comprob_simu=zeros(1, trialPerSession*numSession);
altered_tList=zeros(4, numSession); %keep track on the trial number

for i=1:numSession
    choiceHis=[];
    rewardHis=[];
    altered_trials=randsample(trialPerSession, 4);
    altered_tList(:,i)=altered_trials;
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
        choice=agent_choice(valueL, valueR,bet);
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
        
        %determine the parameter
        alpha_use=alpha; delta1_use=delta1; delta0_use=delta0;
        if ismember(j,altered_trials)
            switch index
                case 1
                    alpha_use=alpha*change;
                case 2
                    delta1_use=delta1*change;
                case 3
                    delta0_use=delta0*change;
            end
        end
        %update the action value
        choice_update=c_simu(trialPerSession*(i-1)+j); reward_update=r_simu(trialPerSession*(i-1)+j);
        [valueR,valueL]=update_action_value(valueR,valueL, choice_update,reward_update, alpha_use,delta1_use, delta0_use);
    end
end



