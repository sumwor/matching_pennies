function like0=model_altered_MP(xpar, dat, trials)
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
alpha_altered=xpar(4); %only alpha_altered for now
delta0=xpar(3);
delta1=xpar(2);
alpha=xpar(1);
nt=size(dat,1);
like0=0;

v_right=0;
v_left=0;      

altered_all=zeros(1,nt); %get a overall number for every altered trial
[m,n]=size(altered_list);
for i=1:n
    altered_all(m*i-m+1:m*i)=altered_list(:,i)*session*(i-1);
end
    
for k=1:nt
    
    %find the altered trials
    if ismember(k, altered_all)
        alpha_use=alpha_altered;
    else
        alpha_use=alpha;
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
            v_right=alpha_use*v_right+delta1;
        else
            v_right=alpha_use*v_right+delta0;
        end
        v_left=alpha_use*v_left;
    else
        if dat(k,2)==1
            v_left=alpha_use*v_left+delta1;
        else
            v_left=alpha_use*v_left+delta0;
        end
        v_right=alpha_use*v_right;
    end;    
end;
