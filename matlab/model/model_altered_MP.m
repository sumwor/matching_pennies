function like0=model_altered_MP(xpar, dat, trials, index)
% % model_altered_MP %
%PURPOSE:   Function for maximum likelihood estimation, called by
%           fit_RL(), including altered parameters
%
%INPUT ARGUMENTS
%   xpar:       alpha: discount factor, delta1 (RPE reward) ,delta0(RPE no reward), adding
%   beta in the future
%   dat:        data
%               dat(:,1) = choice vector
%               dat(:,2) = reward vector
%
%OUTPUT ARGUMENTS
%   like0:      the log-likelihood

%not sure what kind of data structure we are going to use in the real
%experement data yet. 2/23/2018
%%
session=204;
altered_list=trials; %trials that being altered
switch index
    case 1
        alpha_altered=xpar(4); %only alpha_altered for now
    case 2
        delta1_altered=xpar(4);
    case 3
        delta0_altered=xpar(4);
end

delta0=xpar(3);
delta1=xpar(2);
alpha=xpar(1);
nt=size(dat,1);
like0=0;

v_right=0;
v_left=0;      

[m,n]=size(altered_list);
altered_all=zeros(1,m*n); %get a overall number for every altered trial

for i=1:n
    altered_all(m*i-m+1:m*i)=altered_list(:,i)+session*(i-1);
end
    
for k=1:nt
    
    %find the altered trials
    alpha_use=alpha; delta1_use=delta1; delta0_use=delta0;
    if ismember(k, altered_all)
        switch index
            case 1
                alpha_use=alpha_altered;
            case 2
                delta1_use=delta1_altered;
            case 3
                delta0_use=delta0_altered;
        end
    end
    
    pright=exp(v_right)/(exp(v_right)+exp(v_left));
    pleft=1-pright;
        
    if pright==0, pright=realmin; end;        % Smallest positive normalized floating point number
    if pleft==0, pleft=realmin; end;            
  
    if dat(k,1)==1, logp=log(pright);
    else logp=log(pleft);  %left choice:-1, rightChoice=1
    end
 
    like0=like0-logp;  % calculate log likelihood
    
    if dat(k,1)==1      % update action value, choose right
        if dat(k,2)==1
            v_right=alpha_use*v_right+delta1_use;
        else
            v_right=alpha_use*v_right+delta0_use;
        end
        v_left=alpha_use*v_left;
    else
        if dat(k,2)==1
            v_left=alpha_use*v_left+delta1_use;
        else
            v_left=alpha_use*v_left+delta0_use;
        end
        v_right=alpha_use*v_right;
    end;    
end;
