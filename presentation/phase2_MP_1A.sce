#-- scenario file --#
# matching pennies test: algorithm 1
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

scenario = "phase2_matchingPennies_algorithm1";

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

int num_trials = 100;  # user enters initial value in dialog before scenario
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
int pValueIndex = parameter_window.add_parameter("p-value");
int probIndex = parameter_window.add_parameter("left-prob");
int choiceLen;
array<double> pUse[num_trials];
pUse[1]=0.5;
double rand;

#initialize the choice history and reward list
array<int> agentChoiceHistory[0]; array<int> comChoiceHistory[num_trials]; array<int> rewardHistory[0];
#2: left choice, 3: right choice for choice history
#0: no reward, 1:reward for reward history
# set up parallel port for water reward


int noLick=0;
int random = 0;
double prob=0.5;
double nullP = 0.5; #for binomial test
double maxP = 0.05;
array<int> choiceCount[2];
int leftCount=0;
int rightCount=0;  #this left and right are for binomial test
int totalCount=0;

double pValue=0.05;
  


#use subroutines to write several functions

#factorial calculation
sub
   double factorial (int n)
begin
	double fac;
   if n==0 then
      fac=1.0;
   else
      fac=1.0;
      loop
      until
         n<1
      begin
         fac=fac*double(n);
         n=n-1;
      end;
   end;
   return fac;
end;

#exponential calculation
sub
   double exponential (double base, int expo)
begin
  double exp;
  if expo==0 then
    exp=1.0;
  else
    exp=1.0;
    loop
    until
       expo<1
    begin
       exp=exp*base;
       expo=expo-1;
    end;
  end;
  return exp;
end;

#calculate the binomial distribution
sub
   double binomial_distribution (int x, int N, double p)
begin
	double binProb;
   binProb = (factorial(N) / (factorial(x)*factorial(N-x))) * exponential(p,x)*exponential((1.0-p), (N-x));
   return binProb;
end;

#2-tailed binomial test (only for p=0.5)
sub
   double binomial_test (int x, int N, double p)
begin
	 double pvalue;
    pvalue=0.0;
    int lower_inter; int higher_inter;

    if x < N-x then
        lower_inter = x;
        higher_inter = N-x;
    else
         lower_inter = N-x;
         higher_inter = x;
    end;

    loop
       int i=0
    until
       i>lower_inter
    begin
       pvalue=pvalue + binomial_distribution(i, N, p);
       i=i+1;
    end;

    pvalue=pvalue*2.0; #since p=0.5, the distribution is symmetrical, just multiply one tail probability by 2

    if pvalue>1.0 then
        pvalue=1.0;
    end;
    return pvalue;
end;

#this function is used to slice the array
sub
    array<int,1> slice (array<int,1>& inputArray, int startNum, int endNum)
begin
	 array<int> slice[0];
    loop
       int i=startNum
    until
       i>endNum
    begin
       slice.add(inputArray[i]);
       i=i+1;
    end;
    return slice
end;


#last sub! find the sequences in the choice history and get the left and right
sub
    array<int,1> choice_counting (array<int,1>& choiceHis, int num)
begin
	 #array containing left and right choices [1]:left; [2]:right
    array<int> choice[2]={0,0};
    int len = choiceHis.count();
    if num==0 then
       loop
          int i=1
       until
          i>len
       begin
          if choiceHis[i] == 2 then
               choice[1]=choice[1]+1;
          elseif choiceHis[i] == 3 then
               choice[2]=choice[2]+1;
          end;
          i=i+1;
       end;

    else
       #find the sequence by build a new array first
       array<int> seq[num];
       seq=slice(choiceHis, len-num+1, len);

       loop
          int j=1
       until
          j>len-num
       begin
          if slice(choiceHis, j, j+num-1) == seq then
             if choiceHis[j+num]==2 then  #left
                choice[1]=choice[1]+1;
             elseif choiceHis[j+num]==3 then #right
                choice[2]=choice[2]+1;
             end;
          end;
          j=j+1;
       end;
    end;
   return choice
end;


output_port port = output_port_manager.get_port(1);

display_window.draw_text("Water reward with left lick or right lick or Spacebar...");


rand =random();
if (rand <= 0.5) then
   comChoiceHistory[1]=2;
else
   comChoiceHistory[1]=3;
end;
#get the first choice


loop
	int i = 1
until
	i > num_trials
begin

#get the fitst computer choice

   waitlick.present();

  #generate the computer's choice here (not sure about the consequence, if it takes too much time, then it may delay the response recording, wait for later testing)
  #for algorithm 1, need to do 5 binomial test first.

  #choiceLen=agentChoiceHistory.count();     i equals to the length of agentChoiceHistory
  


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
			rewardHistory.add(1);
			if (comChoiceHistory[i]==2) then
				agentChoiceHistory.add(2);
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
				agentChoiceHistory.add(3);
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
			rewardHistory.add(0);
			if ((response_manager.last_response()==2)) then
				agentChoiceHistory.add(2);
				leftlick = leftlick + 1;
				norewardright.present();  #nowaterrewardright means the computer chooses right
				parameter_window.set_parameter(leftlickIndex,string(leftlick));
				consecMiss=0;
				parameter_window.set_parameter(missIndex,string(consecMiss));
			elseif ((response_manager.last_response()==3)) then
				agentChoiceHistory.add(3);
				rightlick = rightlick + 1;
				norewardleft.present();
				parameter_window.set_parameter(rightlickIndex,string(rightlick));
				consecMiss=0;
				parameter_window.set_parameter(missIndex,string(consecMiss));
			end;
		end;

	else
	   pause.present();
	   agentChoiceHistory.add(0); #0 represent missed trial
	   rewardHistory.add(0);
	   consecMiss=consecMiss+1;
	   parameter_window.set_parameter(missIndex,string(consecMiss));
	end;

   parameter_window.set_parameter(currentAgentIndex,string(agentChoiceHistory[i]));


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
	
	maxP=0.05;
	prob=0.5;
	if i<=4 then
        rand =random();
        if (rand <= 0.5) then
            comChoiceHistory[i]=2;
        else
            comChoiceHistory[i]=3;
        end;
   else
        loop
            int j=0
        until
            j>4
        begin
            choiceCount = choice_counting(agentChoiceHistory, j);
            leftCount = choiceCount[1];
				rightCount = choiceCount[2];
            #for test:
            #leftMat[j][i] = leftCount
            #rightMat[j][i] = rightCount

            totalCount = leftCount+rightCount;

            pValue = binomial_test(rightCount, totalCount, nullP);

            #for test:
            #pValueMat[j][i] = pValue

            if (pValue < maxP) then
                 prob = double(rightCount)/double(totalCount);
                 maxP=pValue;
            end;
            
				j=j+1;
         end;
         
			#the loop above is for find the minimum p-value in binomial test and the corresponding probobility to choose right

         rand =random();

         #for test:
             #randMat[i]=rand
             #probMat[i]=probability
         if i<=num_trials then
				if (rand > (1.0-prob)) then
                 comChoiceHistory[i]=2;
				else
                 comChoiceHistory[i]=3;
				end;
				pUse[i]=prob;
			end;
   end;
  
	parameter_window.set_parameter(probIndex, string(prob));

        
	parameter_window.set_parameter(pValueIndex, string(maxP));

	parameter_window.set_parameter(trialIndex,string(i));

	if (i%5) == 0 then		#every 5 trials, save a temp logfile
		quicksave.present();
	end;

end;

output_file ofile1 = new output_file;
ofile1.open("Algo1test.txt", false);
ofile1.print("agentChoice\tcomChoice\treward\tprobobilityRight\n");
loop int k=1
until k>num_trials
begin
	ofile1.print(agentChoiceHistory[k]);
	ofile1.print("\t");
	ofile1.print(comChoiceHistory[k]);
	ofile1.print("\t");
	ofile1.print(rewardHistory[k]);
	ofile1.print("\t");
	ofile1.print(pUse[k]);
	ofile1.print("\n");
	k=k+1;
end;
ofile1.close();
	

display_window.draw_text("Free water session has ended.");
term.print("Ending time:");
term.print(date_time());
