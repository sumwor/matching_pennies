function [ STIM, RESP, OUTCOME, EVENT ] = MP_getPresentationCodes()
%%% getPresentationCodes retrieves codes used in presentation logfiles %%%
%Author: MJ Siniscalchi, 161212
% edit AK for Bandit tasks 170426
%
%--------------------------------------------------------------------------

%CODES FROM NBS PRESENTATION

STIM = [];

RESP.LEFT=2; 
RESP.RIGHT=3;

%---------------for algorithm0------------------------------------
% 2 second responding window, 1-2 second period, 2-3 second white
%noise period (lick no reward)
OUTCOME.MANUALREWARD=10;
OUTCOME.WATERREWARDLEFT = 100; %modified reward code
OUTCOME.WATERREWARDRIGHT = 111;
OUTCOME.NOWATERREWARDLEFT = 101;
OUTCOME.NOWATERREWARDRIGHT = 110;
%waterreward code: 3, but the trial type is nothing
EVENT.WAITLICK = 0;
EVENT.NOLICK = 19;
EVENT.STARTEXPT = 5;
%for matching pennies task, to keep track of the computer's choice
EVENT.STARTEXPTLEFT=51;
EVENT.STARTEXPTRIGHT=52;
EVENT.PAUSE = 77;

%for test
EVENT.LOOPSTART=21;
EVENT.LOOPEND=22;  %the whole time-consuming part, including count, binomial test
EVENT.TESTSTART=23;
EVENT.TESTEND=24;
EVENT.COUNTSTART=25;
EVENT.COUNTEND=26;

%for the event to complement the whole 6s period(may change to 4 second
%later)
EVENT.COMPLETE=66;

OUTCOME.MISS = 77;      %miss


%EVENT.INTERPULSE = 100;  %time between pulses of water reward
EVNET.NOLICK = 19;
%EVENT.PAUSE = 77;      %miss

end