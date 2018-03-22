function [valueRNew,valueLNew]=update_action_value(valueR,valueL, choice,reward, alpha,delta1, delta0)

%a single update 


        if choice==3      % update action value, chooce right
            if reward==1
                valueRNew=alpha*valueR+delta1;
            else
                valueRNew=alpha*valueR+delta0;
            end
            valueLNew=alpha*valueL;
        else
            if reward==1
                valueLNew=alpha*valueL+delta1;
            else
                valueLNew=alpha*valueL+delta0;
            end
            valueRNew=alpha*valueR;
        end    