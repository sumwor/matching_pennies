function [v_difference]=get_action_value(c_nomiss, r_nomiss, alpha, delta1, delta0)
%using the fitted parameters to get the state-action value 
%action value difference in each trial --> predict the animals choice

set(groot, ...
    'DefaultFigureColor', 'w', ...
    'DefaultAxesLineWidth', 2, ...
    'DefaultAxesXColor', 'k', ...
    'DefaultAxesYColor', 'k', ...
    'DefaultAxesFontUnits', 'points', ...
    'DefaultAxesFontSize', 18, ...
    'DefaultAxesFontName', 'Helvetica', ...
    'DefaultLineLineWidth', 1, ...
    'DefaultTextFontUnits', 'Points', ...
    'DefaultTextFontSize', 18, ...
    'DefaultTextFontName', 'Helvetica', ...
    'DefaultAxesBox', 'off', ...
    'DefaultAxesTickLength', [0.02 0.025]);

% set the tick marks on figures to point outwards - need to set(groot) in this specific order
set(groot, 'DefaultAxesTickDir', 'out');
set(groot, 'DefaultAxesTickDirMode', 'manual');
set(0,'defaultfigureposition',[40 40 1000 1000]);

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

%get the prediction

%plot the value difference)
bin_size=0.01;
num=ceil((max(v_difference)-min(v_difference))/bin_size);
value_bin=zeros(1,num);
value_x=ceil(min(v_difference)*100)/100-bin_size/2:bin_size:ceil(max(v_difference)*100)/100-bin_size/2;

pred_prob=1./(1+exp(-value_x));
for i=1:length(c_nomiss)
    ind=ceil((v_difference(i)-value_x(1))/bin_size);
    value_bin(ind)=value_bin(ind)+1;
end

%determine the real probability to choose right;
num_right=zeros(1,num);
for i=1:length(c_nomiss)
    index=ceil((v_difference(i)-value_x(1))/bin_size);
    if c_nomiss(i)==1 %if choose right
        num_right(index)=num_right(index)+1;
    end
end
prob_right=num_right./value_bin;
per_value=value_bin/sum(value_bin);

figure;
yyaxis left; bar(value_x, per_value);
ylabel('Frequency');
hold on; yyaxis right; plot(value_x, pred_prob);
hold on; yyaxis right; plot(value_x, prob_right,'.', 'MarkerSize',25);
ylabel('P(right)');
xlabel('Action value difference (R-L)');

title('761 algorithm2');