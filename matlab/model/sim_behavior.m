%simulate the mouse's behavior using 761 data


%%--------------------------------------------------------------------
%get the parameters estimation first

RL_algorithm='Lee';  %Daeyeol's reinforcement model from 2004 NN
%fit for q-learning
base_dir= 'E:\data\matching_pennies\760\fit_A2\';

%get history data
[c_nomiss, r_nomiss, com_nomiss,rsTime,index]=getData(base_dir);
[c_all, r_all, com_all]=getDataWithMiss(base_dir);
if RL_algorithm=='Lee'
    ans_fit=fit_modelMP(c_nomiss, r_nomiss);
    alpha_fit=ans_fit(1); delta1_fit=ans_fit(2); delta0_fit=ans_fit(3); %beta_fit=ans_fit(4);
    v_difference=get_action_value(c_nomiss, r_nomiss, alpha_fit, delta1_fit, delta0_fit);
elseif RL_algorithm=='q'
    [ans_fit, exit]=fit_qlearn(c_nomiss, r_nomiss);
    alpha_fit=ans_fit(1); beta_fit=ans_fit(2);
    v_difference=get_action_value(c_nomiss, r_nomiss, alpha_fit, delta1_fit, delta0_fit);
end
%get the action value plot 

%find the probability of choosing right in a certain value difference
%interval
%get the first 200 trials v_difference versus response time
plot_rs_v(v_difference, rsTime);
v_difference_200=v_difference(index<=200);
rsTime_200=rsTime(index<=200);
figure;scatter(abs(v_difference_200), rsTime_200);
[R,P] = corrcoef(abs(v_difference_200), rsTime_200)


%predict the animal's choice using v_difference
%[meanRL, meanRand]=predict_choice(c_nomiss,r_nomiss,v_difference,1);
xpar=[alpha_fit, delta1_fit, delta0_fit]; data=[c_nomiss double(r_nomiss)];
[AIC_RL, AIC_random, AIC_WSLS]=AIC_estimation(xpar, data);
%notice that minimal AIC indicates the best model
%where in this case, reinforcement learning model has the minimum
%AIC--great!

%next: find out a way to detect the parameter change %logsitic regression


%get simulated data, iteration is meaningless since in real experiment
%there is no iteration. However, iteration can show how stable the result
%is 

%no miss trials in the data
statsBeh.c=c_nomiss;
statsBeh.r=r_nomiss;
step_back=20;
[output_beh, negloglike_beh]=logistic_reg(statsBeh,step_back); 
plot_logreg(output_beh, 'Subject 761');

%try seperate sessions, with miss data with logistic regression
rewardb_beh=zeros(step_back, length(c_all));
unrewardb_beh=zeros(step_back, length(c_all));
biasList_beh=zeros(1,length(c_all));
for i=1:length(c_all)
    statsSep.c=c_all{i}; statsSep.r=r_all{i}; 
    [outputSep, negloglike]=logistic_reg(statsSep,step_back);
    plot_logreg(outputSep,['session (behavior) ',num2str(i)]);
    rewardb_beh(:,i)=outputSep.b_reward; unrewardb_beh(:,i)=outputSep.b_unreward;biasList_beh(i)=outputSep.b_bias;
    disp(i);
end
%get average
ave_output.n=outputSep.n;
ave_output.b_bias=mean(biasList_beh);ave_output.b_reward=mean(rewardb_beh,2);ave_output.b_unreward=mean(unrewardb_beh,2);
plot_logreg(ave_output,'Average over sessions (behavior)');

iter =1;
alpha=alpha_fit; delta1=delta1_fit; delta0=delta0_fit;
fit_list=[];
for i=1:iter
    N=400; %number of altered trials

    index=1; change=1; %change alpha to 80% first
    [c_simu, r_simu, com_simu, comprob_simu,altered_tList]=simu_modelMP(N, alpha, delta1, delta0,index, change);
    c_fit=(c_simu-2.5).*2;
    %init=[0, 0, 0, 0];
    %new_fit=fit_altered_modelMP(c_fit',r_simu',altered_tList, init,index); %run several sessions to get the best fit
    %fit_list=[fit_list, new_fit];
    %disp(i);
end

%logistic regression with separate sessions
num_session=N/4;
length_session=204;
c_session=zeros(length_session,num_session); %using real number temporally
r_session=zeros(length_session,num_session);
for i=1:num_session
    c_session(:,i)=c_fit(length_session*(i-1)+1:length_session*i);
    r_session(:,i)=r_simu(length_session*(i-1)+1:length_session*i);
end
%log reg on 100 trials
rewardb_sim=zeros(step_back, num_session);
unrewardb_sim=zeros(step_back, num_session);
biasList_sim=zeros(1,num_session);ty
for i=1:20
    statsSim.c=c_session(:,i); statsSim.r=r_session(:,i); 
    [outputSim, negloglike]=logistic_reg(statsSim,step_back);
    plot_logreg(outputSim,['session (simulation)',num2str(i)]);
    rewardb_sim(:,i)=outputSim.b_reward; unrewardb_sim(:,i)=outputSim.b_unreward;biasList_sim(i)=outputSim.b_bias;
    disp(i);
end
%get average
ave_outputSim.n=outputSim.n;
ave_outputSim.b_bias=mean(biasList_sim);ave_outputSim.b_reward=mean(rewardb_sim,2);ave_outputSim.b_unreward=mean(unrewardb_sim,2);
plot_logreg(ave_outputSim,'Average over sessions');

%try logistic regression
%to fit alex's code
stats.c=c_fit'; stats.r=r_simu'; player=1; step_back=20;
[output, negloglike]=logistic_reg(stats,step_back); 
plot_logreg(output, 'test');
%find the possible relationship between logistic regression and RL model
changeList=0.5:0.1:1.0;
rewardb=zeros(step_back, length(changeList));
unrewardb=zeros(step_back, length(changeList));
biasList=zeros(1,length(changeList));
for i=1:length(changeList)
    N=400; %number of altered trials

    index=1; change=changeList(i); %change alpha to 80% first
    [c_simu, r_simu, com_simu, comprob_simu,altered_tList]=simu_modelMP(N, alpha, delta1, delta0,index, change);
    c_fit=(c_simu-2.5).*2;
    stats.c=c_fit; stats.r=r_simu; player=1; step_back=20;
    [output, negloglike]=logistic_reg(stats,step_back);
    rewardb(:,i)=output.b_reward; unrewardb(:,i)=output.b_unreward;biasList(i)=output.b_bias;
    disp(i);
end


figure; 
for j=1:length(changeList)
    wid=1/length(changeList);
    hold on;
    plot(rewardb(:,j), 'color',[1,wid*(j-1),wid*(j-1)]);
end
legendText=cell(1,length(changeList));
for i=1:length(changeList)
    legendText{i}=num2str(changeList(i));
end
legend(legendText);
title('Logistic regression coefficient for reward trials');

figure; 
for j=1:length(changeList)
    wid=1/length(changeList);
    hold on;
    plot(unrewardb(:,j), 'color',[wid*(j-1),wid*(j-1),wid*(j-1)]);
end
legendText=cell(1,length(changeList));
for i=1:length(changeList)
    legendText{i}=num2str(changeList(i));
end
legend(legendText);
title('Logistic regression coefficient for unreward trials');
%plot a example session (first);
figure;
plot_first_session(c_simu(1:204), r_simu(1:204), com_simu(1:204), comprob_simu(1:204));
%looks fine, now doing the model_fitting %try original Daeyeol model then
%q-learning
%more plot here
c_fit=(c_simu-2.5).*2; %change 2/3 to -1/1 to suit the function
com_fit=(com_simu-2.5).*2;
%P_right and P_reward
block=200;
savebehfigpath='E:\data\matching_pennies\simulation';
c_plot=c_fit(1:10000); r_plot=r_simu(1:10000); com_plot=com_fit(1:10000);
plot_p_RightReward(c_plot,r_plot,block,savebehfigpath);
plot_p_StayWSLS(c_plot,r_plot,block,savebehfigpath);
plot_entropy(c_plot,r_plot,block,savebehfigpath);
plot_MI(c_plot,r_plot,com_plot,block,savebehfigpath);

%refit the model

init=[0, 0, 0, 0];
new_fit=fit_altered_modelMP(c_fit',r_simu',altered_tList, init,index) %run several sessions to get the best fit
%fit_result=fit_modelMP(c_fit', r_simu')
%the simulation process must be wrong...just don't know where......

%did not change any parameters, using simulated data to fit the original
%model did not result in expected results

%test win-stay-lose-switch strategy
%a simulation for WSLS strategy
% numTrials=10000;
% [c_simu_WSLS, r_simu_WSLS, com_simu_WSLS,  comprob_simu_WSLS]=simu_WSLS(numTrials);
% plot_first_session(c_simu_WSLS(501:1000), r_simu_WSLS(501:1000), com_simu_WSLS(501:1000), comprob_simu_WSLS(501:1000));
% c_WSLS=(c_simu_WSLS-2.5).*2;
% ans=fit_modelMP(c_WSLS, r_simu_WSLS)
% ans=fit_modelMP(c_fit, r_simu)

%%try to solve this by brutal force
%double check with the real data
% alpha_list=0.93; a=length(alpha_list);
% delta1_list=-1:0.01:1; b=length(delta1_list);
% delta2_list=-1:0.01:1;c=length(delta2_list);
% beta_list=0:0.01:5;d=length(beta_list);
% likeli_simu=zeros(a,b,c,d); likeli_real=zeros(a,b,c,d);
% for q=1:a
%     for w=1:b
%         for e=1:c
%             for r=1:d
%                 xpar=[alpha_list(q) delta1_list(w) delta2_list(e) beta_list(r)];
%                 data1=[c_nomiss r_nomiss]; %data2=[c_fit(1:10000)' r_simu(1:10000)'];
%                 %likeli_simu(q,w,e)=model_MP(xpar, data2);
%                 likeli_real(q,w,e,r)=model_MP_beta(xpar, data1);
%             end
%         end
%         disp(w)
%     end
%     
% end
% %save the data
%  %csvwrite('likeli_simu.csv',likeli_simu); 
%  csvwrite('likeli_real.csv',likeli_real);
%  
% %find the minimum for real data and simulated data
% like=squeeze(likeli_real(1,:,:,:));
% [min_real, idx_real] = min(like(:));
% [n_real, m_real, t_real] = ind2sub(size(like),idx_real);

% [min_simu, idx_simu] = min(likeli_simu(:));
% [n_simu, m_simu, t_simu] = ind2sub(size(likeli_simu),idx_simu);