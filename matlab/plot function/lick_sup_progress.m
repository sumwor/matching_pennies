%lick_suppression_progress

base_dir='E:\data\matching_pennies\';
subject={'760'; '761'};
phase='phase0.5';

cd(base_dir);
ave_nolick_cell=cell(1, length(subject));

%get logfiles
for i =1:length(subject)
    data_path=[base_dir, subject{i}, '\',phase];
    cd(data_path);
    logfile=dir('*.log');
    
    %get number of nolick period for each subject
    for j=1:length(logfile)
        file_name=logfile(j).name;
        
        %get session data
        [ logData ] = parseLogfileHW(data_path, file_name);
    
        [ sessionData, trialData] = MP_getSessionData( logData );
        
        %get nolick data
        nolick_list = zeros(1, sessionData.nTrials);
        hit_miss = zeros(1, sessionData.nTrials);
        start_nolick = 1;
        
        episodeStart=-1;
        for k=1:length(trialData.startTimes)-1
            
            episodeEnd = trialData.startTimes(k+1) - trialData.startTimes(k) - 0.1;
            if k>1      %if it's not first episode, also look at negative time as specified by episodeStart
                episodeIndex = sessionData.time > (trialData.startTimes(k)+episodeStart) & sessionData.time < (trialData.startTimes(k)+episodeEnd);
            else
                episodeIndex = sessionData.time >= trialData.startTimes(k) & sessionData.time < (trialData.startTimes(k)+episodeEnd);
            end
            episodeIndexStart=find(episodeIndex,1,'first');     %getting the events that within [episodeStart, episodeEnd]
            episodeIndexEnd=find(episodeIndex,1,'last');     %getting the events that within [episodeStart, episodeEnd]
            if k < numel(trialData.startTimes)
                endtrialIdx = find(sessionData.time == trialData.startTimes(k+1), 1);
            end
            clear episodeIndex;
        
            num_nolick = 0;
            %for ii =1:numel(sessionData.nTrials)
            for w=episodeIndexStart:episodeIndexEnd
                if sessionData.code(w) == 19 & w < endtrialIdx
                    num_nolick = num_nolick+1;
                end
            end 
            %end
            nolick_list(k) = num_nolick;
        
            ifReward = 0;
            for w=episodeIndexStart:episodeIndexEnd
                if sessionData.code(w) == 10 & w < endtrialIdx
                    ifReward = 1;
                    rewardtime = sessionData.time(w);
                    hit_miss(k)=1;
                    break;
                end
            end
        end
        
        ave_nolick = mean(nolick_list(logical(hit_miss)));
        ave_nolick_cell{i}=[ave_nolick_cell{i},ave_nolick];
    end
end

%plot the ave_nolick numbers

%%--------------plot settings-------------------------
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
%%---------------------

figure;
for i=1:length(subject)
    plot(ave_nolick_cell{i}, 'LineWidth', 2);
    hold on;
end

    