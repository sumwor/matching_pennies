setup_figprop;

saline = load('E:\data\matching_pennies\2019SpringYohimbine\summary\a_b_saline.mat');
dose1 = load('E:\data\matching_pennies\2019SpringYohimbine\summary\a_b_0.1.mat');
dose2 = load('E:\data\matching_pennies\2019SpringYohimbine\summary\a_b_1.mat');

mean_alpha = [mean(saline.alpha), mean(dose1.alpha), mean(dose2.alpha)];
mean_beta = [mean(saline.beta(saline.beta<4)), mean(dose1.beta(dose1.beta<4)), mean(dose2.beta(dose2.beta<4))];
std_alpha = [std(saline.alpha), std(dose1.alpha), std(dose2.alpha)];
std_beta = [std(saline.beta(saline.beta<4)), std(dose1.beta(dose1.beta<4)), std(dose2.beta(dose2.beta<4))];

[h1,p1] = ttest2(saline.alpha, dose1.alpha)
[h2,p2] = ttest2(saline.alpha, dose2.alpha)
[h3,p3] = ttest2(dose1.alpha, dose2.alpha)

[hh1,pp1] = ttest2(saline.beta(saline.beta<4), dose1.beta(dose1.beta<4))
[hh2,pp2] = ttest2(saline.beta(saline.beta<4), dose2.beta(dose2.beta<4))
[hh3,pp3] = ttest2(dose1.beta(dose1.beta<4), dose2.beta(dose2.beta<4))


alpha_errhigh = mean_alpha + std_alpha;
alpha_errlow = mean_alpha - std_alpha;
beta_errhigh = mean_beta + std_beta;
beta_errlow = mean_beta - std_beta;

figure;

bar(mean_alpha,'black');
set(gca,'xticklabel', {'saline', '0.1', '1'});
hold on;
er = errorbar(mean_alpha, std_alpha);
er.Color = [0 0 0];
er.LineStyle = 'none';
title('Estimated learning rate');
print(gcf,'-dpng','est_alpha');    %png format
saveas(gcf, 'est_alpha', 'fig');
    
figure;
bar(mean_beta,'black');
set(gca,'xticklabel', {'saline', '0.1', '1'});
hold on;
er = errorbar(mean_beta, std_beta);
er.Color = [0 0 0];
er.LineStyle = 'none';
title('Estimated inverse temperature');
print(gcf,'-dpng','est_beta');    %png format
saveas(gcf, 'est_beta', 'fig');

%% calculate the probability of switch
saline_stats = load('E:\data\matching_pennies\2019SpringYohimbine\summary\stats_saline.mat');
dose1_stats = load('E:\data\matching_pennies\2019SpringYohimbine\summary\stats_0.1.mat');
dose2_stats = load('E:\data\matching_pennies\2019SpringYohimbine\summary\stats_1.mat');


pStay.saline = zeros(1, length(saline_stats.choiceBySession));
for ii = 1:length(pStay.saline)
    stay = 0;
    total = 0;
    
    % get rid of NaN
    choiceSaline = saline_stats.choiceBySession{ii}.c(~isnan(saline_stats.choiceBySession{ii}.c(:,1)),1);
    for jj = 1:length(choiceSaline)-1
        if choiceSaline(jj+1) == choiceSaline(jj)
            stay = stay + 1;
        end
        total = total + 1;
    end
    pStay.saline(ii) = stay/total;
end

pStay.dose1 = zeros(1, length(dose1_stats.choiceBySession));
for ii = 1:length(pStay.dose1)
    stay = 0;
    total = 0;
    
    % get rid of NaN
    choicedose1 = dose1_stats.choiceBySession{ii}.c(~isnan(dose1_stats.choiceBySession{ii}.c(:,1)),1);
    for jj = 1:length(choicedose1)-1
        if choicedose1(jj+1) == choicedose1(jj)
            stay = stay + 1;
        end
        total = total + 1;
    end
    pStay.dose1(ii) = stay/total;
end

pStay.dose2 = zeros(1, length(dose2_stats.choiceBySession));
for ii = 1:length(pStay.dose2)
    stay = 0;
    total = 0;
    
    % get rid of NaN
    choicedose2= dose2_stats.choiceBySession{ii}.c(~isnan(dose2_stats.choiceBySession{ii}.c(:,1)),1);
    for jj = 1:length(choicedose2)-1
        if choicedose2(jj+1) == choicedose2(jj)
            stay = stay + 1;
        end
        total = total + 1;
    end
    pStay.dose2(ii) = stay/total;
end

meanStay = [mean(pStay.saline), mean(pStay.dose1), mean(pStay.dose2)];
stdStay = [std(pStay.saline), std(pStay.dose1), std(pStay.dose2)];

[h1,p1] =ttest2(pStay.saline, pStay.dose1)
[h2, p2] = ttest2(pStay.saline, pStay.dose2)
[h3,p3] = ttest2(pStay.dose1, pStay.dose2)

%% ---- WSLS
pWS.saline = zeros(1, length(saline_stats.choiceBySession));
pLS.saline = zeros(1, length(saline_stats.choiceBySession));
pWSLS.saline = zeros(1, length(saline_stats.choiceBySession));
for ii = 1:length(pWS.saline)
    WS = 0;
    LS = 0;
    total = 0;
    
    % get rid of NaN
    choiceSaline = saline_stats.choiceBySession{ii}.c(~isnan(saline_stats.choiceBySession{ii}.c(:,1)),1);
    outcomeSaline = saline_stats.choiceBySession{ii}.r(~isnan(saline_stats.choiceBySession{ii}.c(:,1)));
    total = length(outcomeSaline);
    W = sum(outcomeSaline);
    L = total - W;
    for jj = 1:length(choiceSaline)-1
        
        if choiceSaline(jj+1) == choiceSaline(jj) & outcomeSaline(jj) == 1
            WS = WS + 1;
        elseif choiceSaline(jj+1) ~= choiceSaline(jj) & outcomeSaline(jj) == 0
            LS = LS + 1;
        end
    end
    pWS.saline(ii) = WS/W;
    pLS.saline(ii) = LS/L;
    pWSLS.saline(ii) = (WS+LS) / total;
end

pWS.dose1 = zeros(1, length(dose1_stats.choiceBySession));
pLS.dose1 = zeros(1, length(dose1_stats.choiceBySession));
pWSLS.dose1 = zeros(1, length(dose1_stats.choiceBySession));
for ii = 1:length(pWS.dose1)
    WS = 0;
    LS = 0;
    total = 0;
    
    % get rid of NaN
    choiceSaline = dose1_stats.choiceBySession{ii}.c(~isnan(dose1_stats.choiceBySession{ii}.c(:,1)),1);
    outcomeSaline = dose1_stats.choiceBySession{ii}.r(~isnan(dose1_stats.choiceBySession{ii}.c(:,1)));
    total = length(outcomeSaline);
    W = sum(outcomeSaline);
    L = total - W;
    for jj = 1:length(choiceSaline)-1
        
        if choiceSaline(jj+1) == choiceSaline(jj) & outcomeSaline(jj) == 1
            WS = WS + 1;
        elseif choiceSaline(jj+1) ~= choiceSaline(jj) & outcomeSaline(jj) == 0
            LS = LS + 1;
        end
    end
    pWS.dose1(ii) = WS/W;
    pLS.dose1(ii) = LS/L;
    pWSLS.dose1(ii) = (WS+LS) / total;
end

pWS.dose2 = zeros(1, length(dose2_stats.choiceBySession));
pLS.dose2 = zeros(1, length(dose2_stats.choiceBySession));
pWSLS.dose2 = zeros(1, length(dose2_stats.choiceBySession));
for ii = 1:length(pWS.dose2)
    WS = 0;
    LS = 0;
    
    % get rid of NaN
    choiceSaline = dose2_stats.choiceBySession{ii}.c(~isnan(dose2_stats.choiceBySession{ii}.c(:,1)),1);
    outcomeSaline = dose2_stats.choiceBySession{ii}.r(~isnan(dose2_stats.choiceBySession{ii}.c(:,1)));
    total = length(outcomeSaline);
    W = sum(outcomeSaline);
    L = total - W;
    for jj = 1:length(choiceSaline)-1
        
        if choiceSaline(jj+1) == choiceSaline(jj) & outcomeSaline(jj) == 1
            WS = WS + 1;
        elseif choiceSaline(jj+1) ~= choiceSaline(jj) & outcomeSaline(jj) == 0
            LS = LS + 1;
        end
    end
    pWS.dose2(ii) = WS/W;
    pLS.dose2(ii) = LS/L;
    pWSLS.dose2(ii) = (WS+LS) / total;
end

% ttest
meanWS = [mean(pWS.saline), mean(pWS.dose1), mean(pWS.dose2)];
stdWS = [std(pWS.saline), std(pWS.dose1), std(pWS.dose2)];

[h1,p1] =ttest2(pWS.saline, pWS.dose1)
[h2, p2] = ttest2(pWS.saline, pWS.dose2)
[h3,p3] = ttest2(pWS.dose1, pWS.dose2)

meanLS = [mean(pLS.saline), mean(pLS.dose1), mean(pLS.dose2)];
stdLS = [std(pLS.saline), std(pLS.dose1), std(pLS.dose2)];

[h1,p1] =ttest2(pLS.saline, pLS.dose1)
[h2, p2] = ttest2(pLS.saline, pLS.dose2)
[h3,p3] = ttest2(pLS.dose1, pLS.dose2)

meanWSLS = [mean(pWSLS.saline), mean(pWSLS.dose1), mean(pWSLS.dose2)];
stdWSLS = [std(pWSLS.saline), std(pWSLS.dose1), std(pWSLS.dose2)];

[h1,p1] =ttest2(pWSLS.saline, pWSLS.dose1)
[h2, p2] = ttest2(pWSLS.saline, pWSLS.dose2)
[h3,p3] = ttest2(pWSLS.dose1, pWSLS.dose2)


meanRRate = [mean(saline_stats.rrate_array), mean(dose1_stats.rrate_array), mean(dose2_stats.rrate_array)]
stdRRate = [std(saline_stats.rrate_array), std(dose1_stats.rrate_array), std(dose2_stats.rrate_array)]

[h1,p1] =ttest2(saline_stats.rrate_array, dose1_stats.rrate_array)
[h2, p2] = ttest2(saline_stats.rrate_array, dose2_stats.rrate_array)
[h3,p3] = ttest2(dose1_stats.rrate_array, dose2_stats.rrate_array)

meanEntro = [mean(saline_stats.entro_array), mean(dose1_stats.entro_array), nanmean(dose2_stats.entro_array)]
stdentro = [std(saline_stats.entro_array), std(dose1_stats.entro_array), nanstd(dose2_stats.entro_array)]

[h1,p1] =ttest2(saline_stats.entro_array, dose1_stats.entro_array)
[h2, p2] = ttest2(saline_stats.entro_array, dose2_stats.entro_array)
[h3,p3] = ttest2(dose1_stats.entro_array, dose2_stats.entro_array)

%% try two-way anova
data = [pStay.saline, pStay.dose1, pStay.dose2];
f1 = [ones(1, length(pStay.saline)), ones(1, length(pStay.dose1))*2, ones(1, length(pStay.dose2))*3];
f2 = [saline_stats.subMask, dose1_stats.subMask, dose2_stats.subMask];
p = anovan(data,{f1,f2},'model','interaction','varnames',{'f1','f2'})

% there is between subject effect, that's look at individual subjects
meanStay_1 = [mean(pStay.saline(4:5)), mean(pStay.dose1(4:5)), mean(pStay.dose2(4:5))];
stdStay_1 = [std(pStay.saline(4:5)), std(pStay.dose1(4:5)), std(pStay.dose2(4:5))];

figure;
bar(meanStay_1,'black');
set(gca,'xticklabel', {'saline', '0.1', '1'});
hold on;
er = errorbar(meanStay_1, stdStay_1);
er.Color = [0 0 0];
er.LineStyle = 'none';
title('Averaged probability of stay');
print(gcf,'-dpng','p_stay_863');    %png format
saveas(gcf, 'est_beta', 'fig');

[h1,p1] =ttest2(pStay.saline(1:3), pStay.dose1(1:3))% almost significant
[h2, p2] = ttest2(pStay.saline(1:3), pStay.dose2(1:3))
[h3,p3] = ttest2(pStay.dose1(1:3), pStay.dose2(1:3))


[h1,p1] =ttest2(pStay.saline(4:5), pStay.dose1(4:5)) % significant
[h2, p2] = ttest2(pStay.saline(4:5), pStay.dose2(4:5))
[h3,p3] = ttest2(pStay.dose1(4:5), pStay.dose2(4:5))


[h1,p1] =ttest2(pStay.saline(6:8), pStay.dose1(6:8))
[h2, p2] = ttest2(pStay.saline(6:8), pStay.dose2(6:8))
[h3,p3] = ttest2(pStay.dose1(6:8), pStay.dose2(6:8))


[h1,p1] =ttest2(pStay.saline(9:11), pStay.dose1(9:11))
[h2, p2] = ttest2(pStay.saline(9:11), pStay.dose2(9:12))
[h3,p3] = ttest2(pStay.dose1(9:11), pStay.dose2(9:12))


[h1,p1] =ttest2(pStay.saline(12:14), pStay.dose1(13:15))
[h2, p2] = ttest2(pStay.saline(12:14), pStay.dose2(13:15))
[h3,p3] = ttest2(pStay.dose1(12:14), pStay.dose2(13:15))


[h1,p1] =ttest2(pStay.saline(15:18), pStay.dose1(15:17))
[h2, p2] = ttest2(pStay.saline(15:18), pStay.dose2(16:18))
[h3,p3] = ttest2(pStay.dose1(16:18), pStay.dose2(15:17))


[h1,p1] =ttest2(pStay.saline(19:22), pStay.dose1(18:20))
[h2, p2] = ttest2(pStay.saline(19:22), pStay.dose2(19:21))
[h3,p3] = ttest2(pStay.dose1(18:20), pStay.dose2(19:21))

[h1,p1] =ttest2(pStay.saline(23:25), pStay.dose1(21:23))
[h2, p2] = ttest2(pStay.saline(23:25), pStay.dose2(22:25))
[h3,p3] = ttest2(pStay.dose1(21:23), pStay.dose2(22:25))


%% WS

% the first subjects

[h1,p1] =ttest2(pWS.saline(1:3), pWS.dose1(1:3))% almost significant
[h2, p2] = ttest2(pWS.saline(1:3), pWS.dose2(1:3))
[h3,p3] = ttest2(pWS.dose1(1:3), pWS.dose2(1:3))

meanWS_1 = [mean(pWS.saline(4:5)), mean(pWS.dose1(4:5)), mean(pWS.dose2(4:5))];
stdWS_1 = [std(pWS.saline(4:5)), std(pWS.dose1(4:5)), std(pWS.dose2(4:5))];

figure;
bar(meanWS_1,'black');
set(gca,'xticklabel', {'saline', '0.1', '1'});
hold on;
er = errorbar(meanWS_1, stdWS_1);
er.Color = [0 0 0];
er.LineStyle = 'none';
ylim([0 1])
title('Averaged probability of win-stay');
print(gcf,'-dpng','p_WS_862');    %png format
saveas(gcf, 'p_WS_862', 'fig');

%% entropy 883   863 also
[h1,p1] =ttest2(saline_stats.entro_array(23:25), dose1_stats.entro_array(21:23))
[h2, p2] = ttest2(saline_stats.entro_array(23:25), dose2_stats.entro_array(22:25))
[h3,p3] = ttest2(dose1_stats.entro_array(21:23), dose2_stats.entro_array(22:25))

[h1,p1] =ttest2(saline_stats.entro_array(23:25), dose1_stats.entro_array(21:23))
[h2, p2] = ttest2(saline_stats.entro_array(23:25), dose2_stats.entro_array(22:25))
[h3,p3] = ttest2(dose1_stats.entro_array(21:23), dose2_stats.entro_array(22:25))

meanEntro_1 = [mean(saline_stats.entro_array(23:25)), mean(dose1_stats.entro_array(21:23)), mean(dose2_stats.entro_array(22:25))];
stdEntro_1 = [std(saline_stats.entro_array(23:25)), std(dose1_stats.entro_array(21:23)), std(dose2_stats.entro_array(22:25))];

figure;
bar(meanEntro_1,'black');
set(gca,'xticklabel', {'saline', '0.1', '1'});
hold on;
er = errorbar(meanEntro_1, stdEntro_1);
er.Color = [0 0 0];
er.LineStyle = 'none';
ylim([2.5 3.5])
title('Averaged entropy');
print(gcf,'-dpng','p_entro_883');    %png format
saveas(gcf, 'p_entro_883', 'fig');

