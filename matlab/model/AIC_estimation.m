function [AIC1, AIC2, AIC3]=AIC_estimation(xpar, data)

%maximum likelihood to determine the model's strength
%determine which model is the best using AIC (2k-2ln(L)) k:number of
%parameters estimated

%%  output
% AIC1: AIC estimation for reinforcement learning
% AIC2: AIC estimation for random model
% AIC3: AIC estimation for WSLS model

%for reinforcement learning model

like0_RL=model_MP(xpar, data);  %like0 is already log likelihood
AIC1=2*3+2*like0_RL;

%for random
like0_random=length(data(:,1))*log(0.5);
AIC2=2*0-2*like0_random;

%for win-stay-lose-switch
like0_WSLS=model_WSLS(data); %for deterministic model, AIC is given by
%AIC=nln(RSS/n)+2k
AIC3=2*0+2*like0_WSLS;

