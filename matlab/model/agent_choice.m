function choice=agent_choice(valueL, valueR, bet)

%%---parameters:
%   valueL: action value to choose left 
%   valueR: action value to choose right
%   beta: reverse temperature in softmax function

p_right=1/(1+exp(-bet*(valueR-valueL)));

if rand<p_right
    choice=3; %choose right
else
    choice=2; %choose left
end