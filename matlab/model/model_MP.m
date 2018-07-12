function like0=model_MP(xpar, dat)
% % model_MP %
%PURPOSE:   Function for maximum likelihood estimation, called by
%           fit_RL().
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

%%
%beta=xpar(4);
delta0=xpar(3);
delta1=xpar(2);
alpha=xpar(1);
nt=size(dat,1);
like0=0;

v_right=0;
v_left=0;      

for k=1:nt
  
    pright=exp(v_right)/(exp(v_right)+exp(v_left));
    pleft=1-pright;
        
    if pright==0, pright=realmin; end;        % Smallest positive normalized floating point number
    if pleft==0, pleft=realmin; end;            
  
    if dat(k,1)==1, logp=log(pright);
    else logp=log(pleft);  %left choice:-1, rightChoice=1
    end;   
 
    like0=like0-logp;  % calculate log likelihood
    
    if dat(k,1)==1      % update action value, choose right
        if dat(k,2)==1
            v_right=alpha*v_right+delta1;
        else
            v_right=alpha*v_right+delta0;
        end
        v_left=alpha*v_left;
    else
        if dat(k,2)==1
            v_left=alpha*v_left+delta1;
        else
            v_left=alpha*v_left+delta0;
        end
        v_right=alpha*v_right;
    end;    
end;
