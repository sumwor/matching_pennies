#-- scenario file --#
# matching pennies test: algorithm 0
#    animal gets reward when it chooses the same side with the computer
#algorithm 0:
#      computer's choice: generated randomly as 0.5:0.5
#algorithm 1 (only use the choice history):
#      1: 5 binomial test in total
#          1) N=0 P(left) = P(right) = 0.5
#          2) N=1 P(right(t)| right(t-1) ) = 0.5 or P(right(t) | left(t-1)) = 0.5 (depends on the choice of privous trials)
#          3) N=2; N=3; N=4;
#      2:
#          1) if there are no significant difference between 0.5 and the animals choice history, then the computer generate the choice randomly as 0.5:0.5
#          2) if there are. then find the probability(P) to choose right corresponding to the smallest p value. The computer will choose right with the probability (1-P)
#algorithm 2 (use both choice and reward history). rest same as algorithm 1

#tips: the random() function returns a random floating number between 0 and 1 (with 0, without 1)

# when I press spacebar, give it water
# when mouse licks either port, give it water
# count water given by manualfeed or induced by licks
# modified from phase0, 500 ms go cue, 3-4s free water, 2-3s no water with white noise

scenario = "phase2_matchingPennies_algorithm0";

active_buttons = 3;	#how many response buttons in scenario
button_codes = 1,2,3;
#target_button_codes = 1,2,3;
# write_codes = true;	#using analog output port to sync with electrophys
response_logging = log_all;	#log all trials
response_matching = simple_matching;	#response time match to stimuli

begin;

#-------SOUND STIMULI-------#
sound {
	wavefile { filename ="tone_5000Hz_0.2Dur.wav"; preload = true; };
} go;

sound {
	wavefile { filename ="white_noise_3s.wav"; preload=true; };
} whitenoise;


#--------trial---------#


trial {
   save_logfile {
		filename = "temp.log"; 	# use temp.log in default logfile directory
	};									#save logfile during mid-experiment
}quicksave;

trial {
   trial_type = fixed;
   trial_duration = 100;
	nothing {} startexptevent;
   code=5;
}startexpt;


trial {
	trial_type = fixed;
	trial_duration = 1900;	#at least 500ms between water
	nothing {} waterrewardexptevent;
	code=10;
	response_active = true; #still record the licks
}waterrewardmanual;



trial {
	trial_type = fixed;
	trial_duration = 1900;	#at least 500ms between water
	nothing {} waterrewardleftexptevent;
	code=100;
	response_active = true; #still record the licks
}waterrewardleft;

trial {
	trial_type = fixed;
	trial_duration = 1900;	#at least 500ms between water
	nothing {} waterrewardrightexptevent;
	code=111;
	response_active = true; #still record the licks
}waterrewardright;

trial {
	trial_type = fixed;
	trial_duration = 1900;	#at least 500ms between water
	nothing {} nowaterrewardleftexptevent;
	code=101;
	response_active = true; #still record the licks
}norewardleft;

trial {
	trial_type = fixed;
	trial_duration = 1900;	#at least 500ms between water
	nothing {} nowaterrewardrightexptevent;
	code=110;
	response_active = true; #still record the licks
}norewardright;



trial {
   trial_type = fixed;
   trial_duration = 100;
	nothing {} interpulseevent;
}interpulse;

trial {
   trial_type = first_response;
   trial_duration = 2000;
	 sound go;
   code=0;
}waitlick;



trial {
   trial_type = fixed;
	trial_duration = 1500;
   nothing {} randomblockevent;
   code=22;
}randomblock;

trial {
  trial_type = fixed;
  trial_duration = 2500;
  sound whitenoise;
  code=19;
}nolick;

trial {
	trial_type = fixed;
	trial_duration = 1000;
	nothing {} pauseevent;
	code=77;
} pause;

begin_pcl;

#for generating exponential distribution （go block)
double minimum_go=1.0;
double mu=0.2; #rate parameter for exponential distribution
double truncate_go=2.0;
double expval=0.0;

#for generating exponetial distribution (white noise block)
double minimum_wn=2.0;
double mu_wn=0.2; #rate parameter for exponential distribution
double truncate_wn=3.0;
double expval_wn=0.0;

term.print("Starting time:");
term.print(date_time());
logfile.add_event_entry(date_time());

display_window.draw_text("Initializing...");

int num_trials = 400;  # user enters initial value in dialog before scenario
preset int waterAmount_left = 14;
preset int waterAmount_right = 12;

preset int max_consecMiss = 20;                                                                                 ; #triggers end session, for mice, set to 20
int consecMiss = 0;
	# #msec to open water valve
int manualfeed=0;
int leftlick=0;
int rightlick=0;

parameter_window.remove_all();
int manualfeedIndex = parameter_window.add_parameter("Manual feed");
int leftlickIndex = parameter_window.add_parameter("Left Lick");
int rightlickIndex = parameter_window.add_parameter("Right Lick");
int missIndex = parameter_window.add_parameter("ConsecMiss");
int trialIndex = parameter_window.add_parameter("trial_num");
#int nolickIndex = parameter_window.add_parameter("noLick");
int currentAgentIndex = parameter_window.add_parameter("curAgent");
int currentComIndex = parameter_window.add_parameter("curCom");
double rand;

#initialize the choice history and reward list
array<int> agentChoiceHistory[num_trials]; array<int> comChoiceHistory[num_trials]; array<int> rewardHistory[num_trials];
#2: left choice, 3: right choice for choice history
#0: no reward, 1:reward for reward history
# set up parallel port for water reward
output_port port = output_port_manager.get_port(1);

display_window.draw_text("Water reward with left lick or right lick or Spacebar...");


loop
	int i = 1
until
	i > num_trials
begin
	int noLick=0;
	int random = 0;
	startexpt.present();
	waitlick.present();

  #generate the computer's choice here (not sure about the consequence, if it takes too much time, then it may delay the response recording, wait for later testing)
  #for algorithm 0, it is easy

  rand = random();
  if rand < 0.5 then
    comChoiceHistory[i] = 2;
  else
    comChoiceHistory[i] = 3;
  end;

    #show the choice
  parameter_window.set_parameter(currentComIndex,string(comChoiceHistory[i]));

	if response_manager.response_count()>0 then
		if (response_manager.last_response() == 1) then	#if spacebar
			port.set_pulse_width(waterAmount_left);
			port.send_code(4);		#give water reward to left
			interpulse.present();
			port.send_code(4);	#second pulse
			port.set_pulse_width(waterAmount_right);
			port.send_code(8);		#give water reward to right
			interpulse.present();
			port.send_code(8);	#second pulse
			waterrewardmanual.present();
			manualfeed = manualfeed + 1;
			parameter_window.set_parameter(manualfeedIndex, string(manualfeed));
			consecMiss=0;
		elseif (response_manager.last_response() == comChoiceHistory[i]) then	#if licking the same port as the computer chooses
      rewardHistory[i]=1;
      if (comChoiceHistory[i]==2) then
         agentChoiceHistory[i]=2;
			   port.set_pulse_width(waterAmount_left);
			   port.send_code(4);		#give water reward to left
			   interpulse.present();
			   port.send_code(4);	#second pulse
			   waterrewardleft.present();
			   leftlick = leftlick + 1;
			   parameter_window.set_parameter(leftlickIndex,string(leftlick));
			   consecMiss=0;
			   parameter_window.set_parameter(missIndex,string(consecMiss));
     elseif (comChoiceHistory[i]==3) then
         agentChoiceHistory[i]=3;
         port.set_pulse_width(waterAmount_right);
         port.send_code(8);		#give water reward to right
         interpulse.present();
         port.send_code(8);	#second pulse
         waterrewardright.present();
         rightlick = rightlick + 1;
         parameter_window.set_parameter(rightlickIndex,string(rightlick));
         consecMiss=0;
         parameter_window.set_parameter(missIndex,string(consecMiss));
      end;
    elseif (response_manager.last_response() != comChoiceHistory[i]) then
      rewardHistory[i]=0;
      if ((response_manager.last_response()==2)) then
        agentChoiceHistory[i]=2;
        leftlick = leftlick + 1;
				norewardright.present();  #nowaterrewardright means the computer chooses right
        parameter_window.set_parameter(leftlickIndex,string(leftlick));
        consecMiss=0;
        parameter_window.set_parameter(missIndex,string(consecMiss));
      elseif ((response_manager.last_response()==3)) then
        agentChoiceHistory[i]=3;
        rightlick = rightlick + 1;
				norewardleft.present();
        parameter_window.set_parameter(rightlickIndex,string(rightlick));
        consecMiss=0;
        parameter_window.set_parameter(missIndex,string(consecMiss));
      end;
		end;

	else
	  pause.present();
		consecMiss=consecMiss+1;
		parameter_window.set_parameter(missIndex,string(consecMiss));
	end;

  parameter_window.set_parameter(currentAgentIndex,string(agentChoiceHistory[i]));

	loop
		expval=minimum_go-1.0/mu*log(random())
	until
		expval<truncate_go
	begin
		expval=minimum_go-1.0/mu*log(random());
		random = random +1;
		#parameter_window.set_parameter(randomIndex, string(random));
	end;

	randomblock.set_duration(int(1000.0*expval));
	randomblock.present();

	#logfile.add_event_entry("nolickloop_begin");
   loop
	   expval_wn=minimum_wn-1.0/mu_wn*log(random())
   until
	   expval_wn<truncate_wn
   begin
	   expval_wn=minimum_wn-1.0/mu_wn*log(random());
		noLick = noLick + 1;
		#parameter_window.set_parameter(nolickIndex, string(noLick));
   end;
	#logfile.add_event_entry("nolick_begin");
   nolick.set_duration(int(1000.0*expval_wn));
   nolick.present();
	i=i+1;
	parameter_window.set_parameter(trialIndex,string(i));

	if (i%5) == 0 then		#every 5 trials, save a temp logfile
		quicksave.present();
	end;

end;


display_window.draw_text("Free water session has ended.");
term.print("Ending time:");
term.print(date_time());
