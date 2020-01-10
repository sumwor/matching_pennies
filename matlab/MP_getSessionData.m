function [ sessionData, trialData ] = MP_getSessionData( logData )
%%% getSessionData %%%
%PURPOSE: Retrieve session data for probabilistic reward tasks.
%AUTHORS: MJ Siniscalchi 161212.
% edit AK for Bandit tasks 170426
%
%--------------------------------------------------------------------------
%
%INPUT ARGUMENTS
%   logdata:= Structure obtained with a call to parseLogfile(); fields:
%       {subject, dateTime, header, values}.
%   
%OUTPUT VARIABLES
%   sessionData:= Structure containing these fields:
%       {subject, dateTime, nTrials, *lickTimes, *nSwitch}. 
%           * lickTimes([1 2]):=[left right] lick times.
%           * nSwitch only for for RuleSwitching task; 
%               appended after calling getBlockData() 
%   trialData:= Fields: 
%       {startTimes, cueTimes, outcomeTimes, *cue, *response, *outcome}
%           *cue, response, and outcome for each trial; 
%               populated with the codes from NBS Presentation
%
%--------------------------------------------------------------------------
%

[ STIM, RESP, OUTCOME, EVENT ] = MP_getPresentationCodes();

%COPY FROM LOGDATA
sessionData.scenarioName = logData.scenarioName;
sessionData.subject = logData.subject;
sessionData.dateTime = logData.dateTime;

%SESSION DATA <<logData.header: 'Subject' 'Trial' 'Event Type' 'Code' 'Time'>>
TYPE = logData.values{3}; %Intersectional approach necessary, because values 2,3 were reused; 
CODE = logData.values{4}; %change in future Presentation scripts: with unique codes, only CODE would be needed to parse the logfile...

is_zero=false;
if CODE(1)==0
    is_zero=true;
    CODE=CODE(2:end);  %eliminate the first zero (no idea where it comes from; 12/01/2017) 
    TYPE=TYPE(2:end); %same thing here
end
%sessionData.nTrials = sum(CODE==EVENT.STARTEXPT); %If escaped before last trial, nStartTimes could be > nOutcomes

lastCode=find(CODE==EVENT.NOLICK,1,'last'); %get rid of CODE associated with the last, unfinished trial
TYPE = TYPE(1:lastCode);
CODE = CODE(1:lastCode);

%change the reward code to 10
outcomeCodes = cell2mat(struct2cell(OUTCOME)); %outcome-associated codes as vector
sessionData.outcome = outcomeCodes;

%CODE(strcmp(TYPE,'Nothing') & ismember(CODE,outcomeCodes)) = 10;

sessionData.nTrials = sum(CODE==EVENT.STARTEXPTLEFT | CODE==EVENT.STARTEXPTRIGHT | CODE==EVENT.STARTEXPT);

%sessionData.nTrials = sum(CODE==EVENT.STARTEXPT);

time_0 = logData.values{5}(find(CODE==EVENT.STARTEXPTLEFT | CODE==EVENT.STARTEXPTRIGHT | CODE==EVENT.STARTEXPT  ,1,'first'));
time = logData.values{5}-time_0;   %time starts at first instance of startExpt
if is_zero
    time=time(2:end);
end
time = double(time)/10000;         %time as double in seconds
time = time(1:lastCode);

%for 752-phase0-bandit6
% dispose1 = find(time > 39.515 & time < 52.231);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
%for 752-phase0-bandit8.log
% dispose1 = find(time > 454.63 & time < 468.959);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
% dispose2 = find(time > 855.709 & time < 869.859);
% startInd2 = dispose2(1); endInd2 = dispose2(end);
% CODE(startInd2:endInd2) = [];
% time(startInd2:endInd2) = [];
% TYPE(startInd2:endInd2) = [];
%for 752-phase0-bandit5.log
% dispose1 = find(time > 1049.5 & time <1062.7);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
%for 760_FREEWATER_1712051008.log
% dispose1 = find(time > 1509.4 & time <1550.4);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
%for 761_FREEWATER_1712061042.log
% dispose1 = find(time > 4934.5 & time <4945.8);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
%for 761_FREEWATER_1712071141.log
% dispose1 = find(time > 386.51 & time <391.06);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
% dispose1 = find(time > 920.26 & time <928.36);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
%for 761_FREEWATER_1712081057.log
% dispose1 = find(time > 436.5 & time <440.6);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
%for 760_FREEWATER_1712091000.log
% dispose1 = find(time >775.86 & time <783.3);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
%for 761_FREEWATER_1712090943.log
% dispose1 = find(time >510.74 & time <515.9);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];

%for 760_phase0_noWN_1712101056.log
% dispose1 = find(time >1184.8 & time <1189.6);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
% dispose1 = find(time >2066.1 & time <2070.7);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];

%for 760_FREEWATER_1712111121.log
% dispose1 = find(time >650.7 & time <656.88);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
% dispose1 = find(time >2170.6 & time <2176.4);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
%for 760_FREEWATER_1712131312.log
% dispose1 = find(time >2215.4 & time <2230.5);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
%for 760_FREEWATER_1712141309.log
% dispose1 = find(time >4928.3 & time <4941.8);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
%for 760-phase2_MP_1A_lookup20
% dispose1 = find(time > 3643.8 & time < 3648.2);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
%for 761-phase2_MP_2A.8
% dispose1 = find(time > 823.2 & time < 830.5);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];
%for 760-phase2_MP_2A9
% dispose1 = find(time > 77.7 & time < 83.6);
% startInd1 = dispose1(1); endInd1 = dispose1(end);
% CODE(startInd1:endInd1) = [];
% time(startInd1:endInd1) = [];
% TYPE(startInd1:endInd1) = [];

sessionData.time = time;
sessionData.event = EVENT;
sessionData.code = CODE;
sessionData.lickTimes{1} = time(strcmp(TYPE,'Response') & CODE==RESP.LEFT);    %left licktimes
sessionData.lickTimes{2} = time(strcmp(TYPE,'Response') & CODE==RESP.RIGHT);   %right licktimes

%TRIAL DATA <<{startTimes, cueTimes, outcomeTimes, cue, response, outcome}>>
trialData.start=CODE(CODE==EVENT.STARTEXPTLEFT | CODE==EVENT.STARTEXPTRIGHT | CODE==EVENT.STARTEXPT);
trialData.startTimes = time(CODE==EVENT.STARTEXPTLEFT | CODE==EVENT.STARTEXPTRIGHT | CODE==EVENT.STARTEXPT); 

trialData.comChoiceCode=(double(CODE(CODE==EVENT.STARTEXPTLEFT | CODE==EVENT.STARTEXPTRIGHT))-51.5)*2;

%outcomeCodes = cell2mat(struct2cell(OUTCOME)); %outcome-associated codes as vector
trialData.outcome =  CODE(strcmp(TYPE,'Nothing') & ismember(CODE,outcomeCodes));
trialData.outcomeTimes = time(strcmp(TYPE,'Nothing') & ismember(CODE,outcomeCodes));

%find the random block start time
%trialData.random = CODE();

%random blocks for logfile before (include) 05/24/2017
%trialData.randomTimes = time(CODE==EVENT.RANDOMBLOCK);
%find the white noise no lick period
trialData.nolick = CODE(CODE==EVENT.NOLICK);
trialData.nolickTimes = time(CODE==EVENT.NOLICK);

trialData.pauseTimes = time(CODE==EVENT.PAUSE);

%for testing
% trialData.loopstartTimes=time(CODE==EVENT.LOOPSTART);
% trialData.loopendTimes=time(CODE==EVENT.LOOPEND);
% trialData.teststartTimes=time(CODE==EVENT.TESTSTART);
% trialData.testendTimes=time(CODE==EVENT.TESTEND);
% trialData.countstartTimes=time(CODE==EVENT.COUNTSTART);
% trialData.countendTimes=time(CODE==EVENT.COUNTEND);
% trialData.completeTimes=time(CODE==EVENT.COMPLETE);
% countTime=trialData.countendTimes-trialData.countstartTimes;
% testTime=trialData.testendTimes-trialData.teststartTimes;
% count1=zeros(395);
% count2=zeros(395);
% count3=zeros(395);
% count4=zeros(395);
% test1=zeros(395);
% test2=zeros(395);
% test3=zeros(395);
% test4=zeros(395);
% for i = 1:395
%     count1(i)=countTime(4*i-3);
%     test1(i)=testTime(4*i-3);
%     count2(i)=countTime(4*i-2);
%     test2(i)=testTime(4*i-2);
%     count3(i)=countTime(4*i-1);
%     test3(i)=testTime(4*i-1);
%     count4(i)=countTime(4*i);
%     test4(i)=testTime(4*i);
% end

respIdx = find(strcmp(TYPE,'Response'));
respTimes = time(respIdx);

trialData.response = zeros(sessionData.nTrials,1,'uint32');  %The first lick after startexpt or cue
trialData.rt = nan(sessionData.nTrials,1);                    %Time of the first lick

idx = find(trialData.outcome~=OUTCOME.MISS); %Idx all non-miss trials
for i = 1:numel(idx)
     %First response post-cue and RT
     temp = find(respTimes>(trialData.startTimes(idx(i))+0.01),1,'first');
     trialData.response(idx(i)) = CODE(respIdx(temp));
     trialData.rt(idx(i)) = respTimes(temp)-trialData.startTimes(idx(i))-0.1; %don't forget the 0.1 s between startexpt and waitlick (the actual start)
end

%subtract 100ms for interpulse interval on valves; doing so before calculating response data resulted in errors, likely because of uncertainty in presentation timing 
temp = (trialData.outcome~=OUTCOME.MISS); 
trialData.outcomeTimes(temp) = trialData.outcomeTimes(temp)-0.1;


end

