function [choice, comProb] =com_choice(choiceHistory, rewardHistory, algorithm, dyncount, dyncountR)

%this function works well %cross check with plot_MP_A2

%%----input parameters
%   choiceHistory: the choice history of the agent
    %  2: left
    %   3: right
%   rewardHistory: the outcome history of the agent
    % 0: no reward
    % 1: reward
%   algorithm: the algotithm computer using to predict agent's choice
    % 1: algorithm1, only exploit choice history
    % 2: algorithm2, exploit both choice and reward history, %only test
    % algorithm2 right now
%   dyncount: previous count of left and right choice

%%----output results
% choice: computer's choice
    %  2: left
    %  3: right
% comProb: computer's probability to choose right




%%------main code
if algorithm==2
    if length(choiceHistory)<5
       comProb=0.5;
       if rand()<0.5
           choice=3;
       else
           choice=2;
       end
    else
        %%initialize parameters
        leftCountR=0;
        rightCountR=0; 
        leftCount=0;
        rightCount=0;
        maxP=0.05;
        comProb=0.5;
        
        %do the choice counting
        
        for N=1:5
            [leftCount, rightCount, leftCountR, rightCountR]=choice_counting(dyncount,dyncountR, N, choiceHistory, rewardHistory);
           
            totalN = leftCount+rightCount;
            totalNR=leftCountR+rightCountR;
            pValue=myBinomTest(rightCount,totalN, 0.5,'Two');
            pValueR=myBinomTest(rightCountR,totalNR, 0.5,'Two');
            if pValue < maxP
                %probability = rightCount/totalN;\
                if abs(leftCount/totalN-0.5)> abs(comProb-0.5)
                    comProb=leftCount/totalN;
                end
            end
            if pValueR<maxP
                if abs(leftCountR/totalNR-0.5)> abs(comProb-0.5)
                    comProb=leftCountR/totalNR;
                end
            end
       end

        
        
       if rand()<comProb
          choice=3;
       else
          choice=2;
       end
    end
end

    
