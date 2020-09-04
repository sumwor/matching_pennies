%% Analyze performance of a probabilistic reward task
% modified from wanyu's start_data.m
clear all;

%% load data file

base_dir = 'E:\labcode\matching_penniess\logfile\test\';

%bandit_setPathList(base_dir);

%data= '/Users/phoenix/Documents/Kwanlab/reinforcement_learning/logfile/human/170511/';
logfile = 'test-phase2_MP_1A_zscore32.log';
algorithm = '1';
%[ dirs, expData ] = expData_reversal_fixedISI(data_dir);

%setup_figprop;  %set up default figure plotting parameters

%% process data files
%logfilepath=[base_dir, logfile];
savematpath = base_dir;
%if ~exist(savematpath,'dir')
%    mkdir(savematpath);
%end
savebehfigpath = [base_dir,'figs-beh\'];
if ~exist(savebehfigpath,'dir')
    mkdir(savebehfigpath);
end

[ logData ] = parseLogfileHW(base_dir, logfile);
    
[ sessionData, trialData] = MP_getSessionData( logData );

switch algorithm
    case '0'%for phase 0 
        plot_algorithm0(sessionData, trialData, savebehfigpath);
    case '1'
        plot_algorithm1(sessionData, trialData, savebehfigpath);
    case '2'
        plot_algorithm2(sessionData, trialData, savebehfigpath);

end
%%------following for future data analysis-----
%     probList=[0.7 0.1; 0.1 0.7];
%     [ trialData ] = bandit_assignProbs( trialData, probList);  %what were the reward probabilities associated with each rule?
% 
%     [ sessionData, blocks ] = bandit_getBlockData( sessionData, trialData );
%     
%     [ trials ] = bandit_getTrialMasks( trialData, blocks );
%  
%     %% coupling
%     %reward probabilities for left and right sides
%     p=trialData.rewardprob;
%     
%     %choice: left=-1; right=1; miss=0
%     c=zeros(sessionData.nTrials,1); %default 0=miss
%     c(trials.left)=-1;
%     c(trials.right)=1;
%  
%     %high reward side: same dummy coding
%     hr_side=nan(sessionData.nTrials,1); 
%     hr_side(trialData.highreward_side==1)=-1;
%     hr_side(trialData.highreward_side==2)=1;
%     
%     %outcome: reward=1; no reward:0; miss=NaN
%     r=nan(sessionData.nTrials,1); %default NaN=miss
%     r(trials.reward)=1;
%     r(trials.noreward)=0;
%     
%     %% analysis of behavioral performance
%     
%     % plot choice behavior - whole sessions
%     cd(savebehfigpath);
%     tlabel=strcat('Subject=',logData.subject,', Time=',logData.dateTime(1),'-',logData.dateTime(2));
%     plot_session_beh(p,c,r,sessionData.nTrials,tlabel);
%     
%     % plot choice behavior - around switches
%     trials_back=10;  % set number of previous trials
%     sw_output=choice_switch(c,trialData.rule,sessionData.nRules,trials_back);
%     plot_switch(sw_output,tlabel,sessionData.rule_labels);
% 
%     % plot choice behavior - around switches (condensed to high vs low reward side)
%     trials_back=10;  % set number of previous trials
%     sw_hrside_output=choice_switch_hrside(c,hr_side,trials_back);
%     plot_switch_hrside(sw_hrside_output,tlabel);
% 
%     % plot choice behavior - during a block
%     trials_forw=10;  % set number of trials
%     bl_output=choice_block(c,trialData.rule,sessionData.nRules,trials_forw);
%     plot_block(bl_output,tlabel,sessionData.rule_labels);
% 
%     % logistic regression
%     num_regressor=5;
%     lreg_output=logistic_reg(c,r,num_regressor);
%     plot_logreg(lreg_output,tlabel)
%     
%     % fit choice behavior to q-learning model
%     qpar=fit_qlearn(r,c);
%     
%     %%
%     save(fullfile(savematpath,'beh.mat'),...
%             'logData','trialData','sessionData','blocks','trials',...
%             'sw_output','sw_hrside_output','bl_output','lreg_output','qpar','c','r');
% 
%     close all;
%     clearvars -except i dirs expData;
% 
% % plays sound when done
% load train;
% sound(y,Fs);
