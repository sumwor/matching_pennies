function [meanRL, meanRand] = predict_choice(c_nomiss,r_nomiss,v_difference,N)
%use the parameters to predict data
%start with v_difference

%%three methods to predict the animal's choice
% 1) reinforcement learning model
% 2) completely random
% 3) win-stay-lose-switch strategy

%N: iteration

%%output
% c1: reinforcement learning model
% c2: completely random
% c3: win-stay-lose-switch strategy


%RL model
block=200;
leng=floor(length(c_nomiss)/block);
mean_rate_RL=zeros(1,leng); mean_rate_rand=zeros(1,leng); mean_rate_WSLS=zeros(1,leng);
for i=1:N
    p_right_RL=1./(1+exp(-v_difference));
    c1=zeros(1, length(c_nomiss));
    for k=1:length(c_nomiss)
        rng('shuffle');
        ran=rand(1);
        if ran<p_right_RL(k)
            c1(k)=1;
        else
         c1(k)=-1;
        end
    end

    %completely random
    c2=zeros(1, length(c_nomiss));
    for k=1:length(c_nomiss)
        rng('shuffle');
        ran=rand(1);
        if ran<0.5
            c2(k)=1;
        else
            c2(k)=-1;
        end
    end
    
    %win-stay-lose-switch
    c3=zeros(1,length(c_nomiss));
    for k=1:length(c_nomiss)
        if k==1  %first predict is random
            rng('shuffle');
            ran=rand(1);
            if ran<0.5
                c3(k)=1;
            else
                c3(k)=-1;
            end
        else
            if r_nomiss(k-1)==1 %win
                c3(k)=c_nomiss(k-1);
            else %lose
                c3(k)=-c_nomiss(k-1);
            end
        end
    end
    
    rate=zeros(1, leng);
    rate_rand=zeros(1, leng);
    for j=1:leng
        hitrate=sum(c_nomiss(block*(j-1)+1:block*j)==c1(block*(j-1)+1:block*j)')/block;
        rate(j)=hitrate;
        hitrate2=sum(c_nomiss(block*(j-1)+1:block*j)==c2(block*(j-1)+1:block*j)')/block;
        rate_rand(j)=hitrate2;
        hitrate3=sum(c_nomiss(block*(j-1)+1:block*j)==c3(block*(j-1)+1:block*j)')/block;
        rate_WSLS(j)=hitrate3;
    end
    mean_rate_RL=[mean_rate_RL;rate]; 
    mean_rate_rand=[mean_rate_rand;rate_rand];
    mean_rate_WSLS=[mean_rate_WSLS;rate_WSLS];
    
    disp(i)
end
mean_rate_RL1=mean(mean_rate_RL); 
mean_rate_rand1=mean(mean_rate_rand);
mean_rate_WSLS1=mean(mean_rate_WSLS);

%plot the prediction accuracy

sz=80;
x_axis=(1:leng)*200;
figure; scatter(x_axis,mean_rate_RL1*100,sz,'r','filled');
hold on; scatter(x_axis, mean_rate_rand1*100, sz,'k', 'filled');
%hold on; scatter(x_axis, mean_rate_WSLS1*100, sz,'b', 'filled'); get rid
%of the WSLS
ylim([0 100]);
xlabel('Trial'); ylabel('Prediction accuracy (%)')
legend('RL', 'random');

%runnign test
[h1, p1]=ttest2(rate, rate_rand); [h2,p2]=ttest2(rate, rate_WSLS);
mean_rate=mean(rate); mean_rate_rand=mean(rate_rand); mean_rate_WSLS=mean(rate_WSLS);







