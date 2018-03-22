function choice=agent_choice_WSLS(c,r,j)

%generate agent's choice based on win stay lose switch strategy
if j==1 %first trial the choice is random
    if rand<0.5
        choice=2;
    else
        choice=3;
    end
else
    if r==1 %win
        if c==2
            choice=2;
        else
            choice=3;
        end
    else
        if c==2
            choice=3;
        else
            choice=2;
        end
    end
end

