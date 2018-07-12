function plot_rs_v(v_difference, rsTime)

%get the value count (same as in get_action_value.m)
bin_size=0.01;
num=ceil((max(v_difference)-min(v_difference))/bin_size);
value_bin=zeros(1,num);
value_x=ceil(min(v_difference)*100)/100-bin_size/2:bin_size:ceil(max(v_difference)*100)/100-bin_size/2;

for i=1:length(v_difference)
    ind=ceil((v_difference(i)-value_x(1))/bin_size);
    value_bin(ind)=value_bin(ind)+1;
end

%determine the response time;
% num_right=zeros(1,num);
% for i=1:length(c_nomiss)
%     index=ceil((v_difference(i)-value_x(1))/bin_size);
%     if c_nomiss(i)==1 %if choose right
%         num_right(index)=num_right(index)+1;
%     end
% end
% prob_right=num_right./value_bin;
per_value=value_bin/sum(value_bin);
figure;
yyaxis left; bar(value_x, per_value);
ylabel('Frequency');
hold on; yyaxis right; plot(v_difference, rsTime, 'k.');
%hold on; yyaxis right; plot(value_x, prob_right,'.', 'MarkerSize',25);
ylabel('Response time (s)');
xlabel('Action value difference (R-L)');

title('Action value and response time');