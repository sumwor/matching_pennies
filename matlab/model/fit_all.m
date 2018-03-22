clear all;

base_dir = 'E:\data\matching_pennies\761\model_A2\';
%go back to check how well the parameters predict the actually behavior
%modify parameters to see how many trials we need to see the difference
%(changes in the parameters)

%bandit_setPathList(base_dir);
rewardCode=[10, 100, 111];
incorrectCode=[110, 101];
%data=
%'/Users/phoenix/Documents/Kwanlab/reinforcement_learning/logfile/human/170511/';\
cd(base_dir);
logfiles = dir('*.log');
c_all=[];r_all=[];com_all=[];
%get concatenated choice and reward history
for i =1:length(logfiles)
    [ logData ] = parseLogfileHW(base_dir, logfiles(i).name);
    
    [ sessionData, trialData] = MP_getSessionData( logData );
    c=double(trialData.response);
    for i=1:length(c)
        if c(i)~=0
          c(i)=(c(i)-2.5)*2;
        end
    end
    r=trialData.outcome;
    com=trialData.comChoiceCode;
    n_missed=sum(r==77);
    r(~ismember(r, rewardCode))=0;
    r(ismember(r, rewardCode))=1;
    
    %concatenate
    c_all=[c_all;c]; r_all=[r_all;r];com_all=[com_all; com];
    
end

%fit the model
ans=fit_modelMP(c_all,r_all);
ans

%get the state value
c_nomiss=c_all(c_all~=0);
r_nomiss=r_all(c_all~=0);
com_nomiss=com_all(c_all~=0);
alpha=ans(1); delta1=ans(2); delta0=ans(3);
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
%use the parameters to predict data
%start with v_difference
p_right=1./(1+exp(-v_difference));

p_predict=zeros(1, length(c_nomiss));
p_predict_rand=zeros(1, length(c_nomiss));
for k=1:length(c_nomiss)
    rng('shuffle');
    ran=rand(1);
    if ran<p_right(k)
        p_predict(k)=1;
    else
        p_predict(k)=-1;
    end
end
for k=1:length(c_nomiss)
    rng('shuffle');
    ran=rand(1);
    if ran<0.5
        p_predict_rand(k)=1;
    else
        p_predict_rand(k)=-1;
    end
end

block=200;
leng=floor(length(c_nomiss)/block);
rate=zeros(1, leng);
rate_rand=zeros(1, leng);
for j=1:leng
    hitrate=sum(c_nomiss(block*(j-1)+1:block*j)==p_predict(block*(j-1)+1:block*j)')/block;
    rate(j)=hitrate;
    hitrate2=sum(c_nomiss(block*(j-1)+1:block*j)==p_predict_rand(block*(j-1)+1:block*j)')/block;
    rate_rand(j)=hitrate2;
end
sz=80;
x_axis=[1:leng]*200;
figure; scatter(x_axis,rate*100,sz,'r','filled');
hold on; scatter(x_axis, rate_rand*100, sz,'k', 'filled');
ylim([0 100]);
xlabel('Trial'); ylabel('Prediction accuracy (%)')

figure;
bar([mean(rate_rand)*100,mean(rate)*100],0.5);
ylim([0 100]);
xticklabels({'Control';'Action value based prediction'});

%%--------alter parameters, alpha
alpha_alter=alpha*0.8; %80 percent change
delta1_alter=delta1*0.8;

%generate new data
alterN=1200;


session=204;
n_sessions=alterN/4;

%valueL=valueLeft(end); valueR=valueRight(end); %starting action value
valueL=0; valueR=0;
%store the simulation results
c_simu=zeros(1, session*n_sessions);
r_simu=zeros(1, session*n_sessions);
com_simu=zeros(1,session*n_sessions);
altered_tList=zeros(4, n_sessions); %keep track on the trial number
for i=1:n_sessions
    choiceHis=[];
    rewardHis=[];
    altered_trials=randsample(session, 4);
    altered_tList(:,i)=altered_trials;
    comProbList=zeros(1,session);
    dyncountlist=zeros(1,32);
    dyncountlistR=zeros(1,512);
    for j=1:session
        %generate animal choice
        pR=exp(valueR)/(exp(valueR)+exp(valueL));
        choiceRand=rand();
        if choiceRand<pR
            c_simu(session*(i-1)+j)=3;
            choiceHis=[choiceHis,3];
        else
            c_simu(session*(i-1)+j)=2;
            choiceHis=[choiceHis,2];
        end
        
        %generate computer choice
        if j<=5
            if rand()<0.5
                com_choice=3;
                com_simu(session*(i-1)+j)=3;
            else
                com_choice=2;
                com_simu(session*(i-1)+j)=2;
            end
        else 
        %adding algorithm2
            
            
           
            IndNeed=[0, 4, 8, 12, 16, 20, 24, 28];
            Ind1=[0, 4, 8, 12, 16, 20, 24, 28];
            for f =1:8
                Ind1(f)=Ind1(f)+64;
            end
            IndNeed=[IndNeed,Ind1];
            temp=zeros(1,16);
            for f =1:16
                temp(f)=IndNeed(f)+128;
            end
            IndNeed=[IndNeed,temp];
            temp2=zeros(1,32);
            for f =1:32
                temp2(f)=IndNeed(f)+256;
            end
            IndNeed=[IndNeed,temp2];
            %when running binomial test, ignore the miss trials
      
            leftCountR=0;
            rightCountR=0;
            
          
            pvalue=zeros(0,0);
            maxP=0.05;
            
          
            if choiceHis(j)~=0
                updateSeqR=[rewardHis(end-4:end-1),choiceHis(end-4:end)-2];
                IndR=bin2dec(num2str(updateSeqR))+1;
                dyncountlistR(IndR)=dyncountlistR(IndR)+1;
                Ind=bin2dec(num2str(choiceHis(end-4:end)-2))+1;
                dyncountlist(Ind)=dyncountlist(Ind)+1;
            end
        
        %do the choice counting
        
            for g = 1:5
                leftCountR=0;
                rightCountR=0;
                comProb=0.5;
                if g==1
                    leftCount=sum(choiceHis==2);
                    rightCount=sum(choiceHis==3);
                else
                    searchSeqR=rewardHis(end-g+2:end);
                    for x=1:4-g+1
                        searchSeqR=[searchSeqR,0];
                    end
                    searchSeqR=[searchSeqR,choiceHis(end-g+2:end)-2,0];
                    baseIndR=bin2dec(num2str(searchSeqR))+1;
                    searchSeq=[choiceHis(end-g+2:end),2];
                    baseInd=bin2dec(num2str(searchSeq-2))+1;
                    if g==5
                        leftCount=dyncountlist(baseInd);
                        rightCount=dyncountlist(baseInd+1);
                        leftCountR=dyncountlistR(baseIndR);
                        rightCountR=dyncountlistR(baseIndR+1);
                    elseif g==4
                        leftCount=dyncountlist(baseInd)+dyncountlist(baseInd+16);
                        rightCount=dyncountlist(baseInd+1)+dyncountlist(baseInd+17);
                        leftCountR=dyncountlistR(baseIndR)+dyncountlistR(baseIndR+16)+dyncountlistR(baseIndR+256)+dyncountlistR(baseIndR+272);
                        rightCountR=dyncountlistR(baseIndR+1)+dyncountlistR(baseIndR+17)+dyncountlistR(baseIndR+257)+dyncountlistR(baseIndR+273);
                    elseif g==3
                        leftCount=dyncountlist(baseInd)+dyncountlist(baseInd+16)+dyncountlist(baseInd+8)+dyncountlist(baseInd+24);
                        rightCount=dyncountlist(baseInd+17)+dyncountlist(baseInd+1)+dyncountlist(baseInd+9)+dyncountlist(baseInd+25);
                        leftCountR=dyncountlistR(baseIndR)+dyncountlistR(baseIndR+8)+dyncountlistR(baseIndR+16)+dyncountlistR(baseIndR+24)+dyncountlistR(baseIndR+128)+dyncountlistR(baseIndR+136)+dyncountlistR(baseIndR+144)+dyncountlistR(baseIndR+152)+dyncountlistR(baseIndR+256)+dyncountlistR(baseIndR+264)+dyncountlistR(baseIndR+272)+dyncountlistR(baseIndR+280)+dyncountlistR(baseIndR+384)+dyncountlistR(baseIndR+392)+dyncountlistR(baseIndR+400)+dyncountlistR(baseIndR+408);
                        rightCountR=dyncountlistR(baseIndR+1)+dyncountlistR(baseIndR+9)+dyncountlistR(baseIndR+17)+dyncountlistR(baseIndR+25)+dyncountlistR(baseIndR+129)+dyncountlistR(baseIndR+137)+dyncountlistR(baseIndR+145)+dyncountlistR(baseIndR+153)+dyncountlistR(baseIndR+257)+dyncountlistR(baseIndR+265)+dyncountlistR(baseIndR+273)+dyncountlistR(baseIndR+281)+dyncountlistR(baseIndR+385)+dyncountlistR(baseIndR+393)+dyncountlistR(baseIndR+401)+dyncountlistR(baseIndR+409);
                    elseif g==2
                        leftCount=dyncountlist(baseInd)+dyncountlist(baseInd+4)+dyncountlist(baseInd+8)+dyncountlist(baseInd+12)+dyncountlist(baseInd+16)+dyncountlist(baseInd+20)+dyncountlist(baseInd+24)+dyncountlist(baseInd+28);
                        rightCount=dyncountlist(baseInd+1)+dyncountlist(baseInd+5)+dyncountlist(baseInd+9)+dyncountlist(baseInd+13)+dyncountlist(baseInd+17)+dyncountlist(baseInd+21)+dyncountlist(baseInd+25)+dyncountlist(baseInd+29);
                        for x=1:length(IndNeed)
                            leftCountR=leftCountR+dyncountlistR(baseIndR+IndNeed(x));
                            rightCountR=rightCountR+dyncountlistR(baseIndR+IndNeed(x)+1);
                        end
                    end
           
                end
          
           
                totalN = leftCount+rightCount;
                totalNR=leftCountR+rightCountR;
                pValue=myBinomTest(rightCount,totalN, 0.5,'Two');
                pValueR=myBinomTest(rightCountR,totalNR, 0.5,'Two');
                pvalue=[pvalue,pValue,pValueR];
                if pValue < maxP
                %probability = rightCount/totalN;\
                    if abs(leftCount/totalN-0.5)> abs(comProb-0.5)
                        comProb=leftCount/totalN;
                    end
                end
                if pValueR<maxP
                    if abs(leftCountR/totalNR-0.5)> abs(comProb-0.5)
            
                        comProb=leftCountR/totalNR;
                    end
                end
            end
            comProbList(j)=comProb;
        
        
            if rand()<comProb
                com_choice=3;
                com_simu(session*(i-1)+j)=3;
            else
                com_choice=2;
                com_simu(session*(i-1)+j)=2;

            end
        end
        %get the reward
        if c_simu(session*(i-1)+j)==com_choice
            r_simu(session*(i-1)+j)=1;
            rewardHis=[rewardHis,1];
        else
            r_simu(session*(i-1)+j)=0;
            rewardHis=[rewardHis,0];
        end
        
        %update the action value
        if ismember(j,altered_trials)
            alpha_use=alpha_alter;
        else
            alpha_use=alpha;
        end
        if c_simu(session*(i-1)+j)==3      % update action value, chooce right
            if r_simu(session*(i-1)+j)==1
                valueR=alpha_use*valueR+delta1;
            else
                valueR=alpha_use*valueR+delta0;
            end
            valueL=alpha_use*valueL;
        else
            if r_simu(session*(i-1)+j)==1
                valueL=alpha_use*valueL+delta1;
            else
                valueL=alpha_use*valueL+delta0;
            end
            valueR=alpha_use*valueR;
        end    
    end
end


% get the overall index of the altered trial
all_ind=zeros(1,alterN);
ind=1;
for h =1:alterN/4
    for l=1:4
        all_ind(ind)=altered_tList(l,h)+session*(h-1)+1;
        ind=ind+1;
    end
    
end
all_ind=sort(all_ind);

%for logistic regression
Y_altered=(c_simu(all_ind)');
step_back=4;
%get predictors
YR=zeros(length(c_simu),1);   % rewarded
YR=1*((c_simu==3) & (r_simu==1)) + (-1)*((c_simu==2) & (r_simu==1));
NR=zeros(length(c_simu),1);   % unrewarded
NR=1*((c_simu==3) & (r_simu==0)) + (-1)*((c_simu==2) & (r_simu==0));
rmat=zeros(length(Y_altered),2*step_back);
for i=1:length(Y_altered)
    for j=1:step_back
        rmat(i,j)=YR(all_ind(i)-j);
    end
    for j=1+step_back:2*step_back
        rmat(i,j)=NR(all_ind(i)-j+step_back);
    end
end
[b,~,stats] =glmfit(rmat,(Y_altered==3), 'binomial', 'link', 'logit');
%reward coefficient
R_co=(b(2:5));
NR_co= (b(6:9));

%%---original fitting
YR1=zeros(length(c_nomiss),1);   % rewarded
YR1=1*((c_nomiss==1) & (r_nomiss==1)) + (-1)*((c_nomiss==-1) & (r_nomiss==1));

NR1=zeros(length(c_nomiss),1);   % unrewarded
NR1=1*((c_nomiss==1) & (r_nomiss==0)) + (-1)*((c_nomiss==-1) & (r_nomiss==0));

% generate regressor matrix

%control
rmat1=zeros(length(NR1)-step_back,2*step_back);
rmat2=zeros(length(c_nomiss)-step_back,step_back);
rmat3=zeros(length(c_nomiss)-step_back,step_back);
for i=1+step_back:length(NR1)
    for j=1:step_back
        rmat1(i-step_back,j)=YR1(i-j);
    end
    for j=1+step_back:2*step_back
        rmat1(i-step_back,j)=NR1(i-j+step_back);
    end
end
for i=1+step_back:length(c_nomiss)
    for j=1:step_back
        rmat2(i-step_back,j)=c_nomiss(i-j);
    end
    
end
for i=1+step_back:length(c_nomiss)
    for j=1:step_back
        rmat3(i-step_back,j)=com_nomiss(i-j);
    end
    
end
%logistic regression

[b1,~,stats] =glmfit(rmat1,(c_nomiss(1+step_back:end)==1), 'binomial', 'link', 'logit');
pval=stats.p;

b_bias=b1(1);
b_reward=b1(2:1+step_back);
b_unreward=b1(2+step_back:2*step_back+1);

n=-1:-1:-step_back;

[b2,~,stats] =glmfit(rmat2,(c_nomiss(1+step_back:end)==1), 'binomial', 'link', 'logit');


b2_choice=b2(2:1+step_back);
[b3,~,stats] =glmfit(rmat3,(c_nomiss(1+step_back:end)==1), 'binomial', 'link', 'logit');
b3_com=b3(2:1+step_back);


%for altered trial
rmat4=zeros(alterN,step_back);
for i=1:alterN
    rmat4(i,:)=2*(c_simu((all_ind(i)-step_back):(all_ind(i)-1))-2.5);
end

[b4,~,stats] =glmfit(rmat4,(Y_altered==3), 'binomial', 'link', 'logit');
b4_choice=b4(2:1+step_back);

rmat5=zeros(alterN,step_back);
for i=1:alterN
    rmat5(i,:)=2*(com_simu((all_ind(i)-step_back):(all_ind(i)-1))-2.5);
end

[b5,~,stats] =glmfit(rmat5,(Y_altered==3), 'binomial', 'link', 'logit');
b4_choice=b4(2:1+step_back);
b5_com=b5(2:1+step_back);
figure;
plot(n,b_reward,'k.-','MarkerSize',30,'LineWidth',3);
hold on; plot(n,R_co,'r.-','MarkerSize',30,'LineWidth',3);


figure;
plot(n,b_unreward,'k.-','MarkerSize',30,'LineWidth',3);
hold on; plot(n,NR_co,'r.-','MarkerSize',30,'LineWidth',3);

figure;
n2=-4:-1;
plot(n,b2_choice,'k.-','MarkerSize',30,'LineWidth',3);
hold on; plot(n,b3_com,'r.-','MarkerSize',30,'LineWidth',3);
ylim([-0.5 1.6]);
figure; plot(n2,b4_choice,'k.-','MarkerSize',30,'LineWidth',3);
hold on; plot(n2,b5_com,'r.-','MarkerSize',30,'LineWidth',3);
ylim([-0.5 1.6]);
legend;
ylim([-0.5 1.6]);
%get the original logsitic regression
step_back=4;
c_log=(c_simu-2.5)*2;
output=logistic_reg(c_log,r_simu,step_back) 
%refit the model
c_simu1=(c_simu-2.5).*2; %change 2/3 to -1/1 to suit the function
init=[alpha, delta1, delta0, 0.5];
newans=fit_altered_modelMP(c_simu1,r_simu,altered_tList, init);

        
        
        
        


