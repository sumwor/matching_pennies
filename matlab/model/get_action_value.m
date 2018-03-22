function [v_difference]=get_action_value(c_nomiss, r_nomiss, alpha, delta1, delta0)
%using the fitted parameters to get the state-action value 
%action value difference in each trial --> predict the animals choice


valueLeft=zeros(1,length(c_nomiss));
valueRight=zeros(1,length(c_nomiss));
v_left=0; v_right=0;
pRight=zeros(1,length(c_nomiss));
for k=1:length(c_nomiss)
  
    pright=exp(v_right)/(exp(v_right)+exp(v_left));
    pRight(k)=pright;
    pleft=1-pright;
    
    if c_nomiss(k)==1      % update action value, chooce right
        if r_nomiss(k)==1
            v_right=alpha*v_right+delta1;
        else
            v_right=alpha*v_right+delta0;
        end
        v_left=alpha*v_left;
    else
        if r_nomiss(k)==1
            v_left=alpha*v_left+delta1;
        else
            v_left=alpha*v_left+delta0;
        end
        v_right=alpha*v_right;
    end;    
    valueRight(k)=v_right; valueLeft(k)=v_left;
end;

v_difference=valueRight-valueLeft;

%plot the value difference)
bin_size=0.01;
num=ceil((max(v_difference)-min(v_difference))/bin_size);
value_bin=zeros(1,num+1);
value_x=ceil(min(v_difference)*100)/100-bin_size/2:bin_size:ceil(max(v_difference)*100)/100-bin_size/2;
for i=1:length(c_nomiss)
    ind=ceil((v_difference(i)-min(v_difference))/bin_size)+1;
    value_bin(ind)=value_bin(ind)+1;
end
per_value=value_bin/sum(value_bin);
bar(value_x, per_value,'k');
xlabel('Action value difference (R-L)');
ylabel('Frequency');
title('761 algorithm1');