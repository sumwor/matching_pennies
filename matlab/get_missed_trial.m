clear all;

%% load data file

%base_dir = 'E:\data\matching_pennies\755\algorithm0\';
base_dir = 'E:\data\matching_pennies\761\phase2_A2\';

%bandit_setPathList(base_dir);

%data= '/Users/phoenix/Documents/Kwanlab/reinforcement_learning/logfile/human/170511/';
logfile = '761-phase2_MP_2A.16.log';

[ logData ] = parseLogfileHW(base_dir, logfile);
    
[ sessionData, trialData] = MP_getSessionData( logData );