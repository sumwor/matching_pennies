function [dyncountNew, dyncountRNew]=update_dynamic_a2(choiceHistory, rewardHistory, dyncount, dyncountR)

%%
%dyncount: dynamic counting of choise only using choice history
%dyncountR: dynamic counting of choice using both choice and reward history

%if the most recent choice is not miss, then update the counting
%change the left right representation from -1,1 to 2,3

%choiceHistory=choiceHistory/2+2.5; %in simulation, there is no miss, don't
%worry about this yet %stick to 2,3 instead of -1,1
if length(choiceHistory)<5
    dyncountNew=dyncount;
    dyncountRNew=dyncountR;
else
    if choiceHistory(end)~=0
        updateSeqR=[rewardHistory(end-4:end-1),choiceHistory(end-4:end)-2];
        IndR=bin2dec(num2str(updateSeqR))+1;
        dyncountR(IndR)=dyncountR(IndR)+1;
        Ind=bin2dec(num2str(choiceHistory(end-4:end)-2))+1;
        dyncount(Ind)=dyncount(Ind)+1;
    end
    dyncountNew=dyncount;
    dyncountRNew=dyncountR;
end

