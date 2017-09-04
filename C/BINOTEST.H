#ifndef _BINOTEST_H_
#define _BINOTEST_H_
#include <vector>



int computer_choice(int *rarr, int narr, int norder, \
					std::vector<double>  & prob_details, \
					std::vector<double>  & diff_details, int & order_picked );




int computer_choice_reward(int *rarr  , int narr_response,				\
						   int *rewarr, int narr_reward,				\
						   int norder,							\
						   std::vector<double>  & prob_details, \
						   std::vector<double>  & diff_details, \
						   std::vector<double>  & reward_prob_details,	\
						   std::vector<double>  & rew_diff_details,		\
						   int & order_picked, 
						   int &algorithm_type);

//int computer_choice_reward(int *rarr, int *rewarr, int narr, int norder)


#endif