function [like0]=model_WSLS(dat)

%estimate the log likelihood for win stay lose switch strategy

nt=size(dat,1);
like0=0;

for k=1:nt
    
    if k==1
        pright=0.5;
        pleft=0.5;
        if dat(k,1)==1, logp=log(pright);
        else logp=log(pleft);  %left choice:-1, rightChoice=1
        end;   
    else
        if dat(k-1,2)==1 %win
            if dat(k-1,1)==1 %right
                pright=1; pleft=realmin;
            else
                pleft=1;pright=realmin;
            end
        else %lose
            if dat(k-1,1)==1 %right
                pleft=1; pright=realmin;
            else
                pright=1; pleft=realmin;
            end
        end
        if dat(k,1)==1, logp=log(pright);
        else logp=log(pleft);  %left choice:-1, rightChoice=1
        end;   
    end
    like0=like0-logp;  % calculate log likelihood
    
end;
