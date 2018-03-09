# -*- coding: utf-8 -*-
"""
Created on Tue Jan 09 10:14:17 2018

@author: Hongli Wang
"""

#win-stay lose-switch strategy
import numpy.random
import scipy.stats

RList=[]
nTrials=500
n_iter=500;
rewardRate=[]
def choice_counting(choiceHistory, num):
     
    leftCount=0
    rightCount=0
    
    if num==0:
        for i in range(len(choiceHistory)):
            if choiceHistory[i] == 1:
                leftCount+=1
            else:
                rightCount+=1
    else:   
        comb=choiceHistory[-num:]
      
    
        for i in range(len(choiceHistory)-num):
            if choiceHistory[i:i+num] == comb:
                if choiceHistory[i+num] == 1:
                    leftCount+=1
                else:
                    rightCount+=1
                
    return leftCount, rightCount

for i in range(n_iter):
    choiceHis=[]
    rewardHis=[]
    comChoice=[]
    minprobList=[]
    for j in range(nTrials):
        sigP=0.05
        minprob=0.5
        rand=numpy.random.rand()
        if j==0:
            rand1=numpy.random.rand()
            if rand1<=0.5:
                choiceHis.append(1)
            else:
                choiceHis.append(2)
            rand2=numpy.random.rand()
            if rand2<=0.5:
                comChoice.append(1) #left
            else:
                comChoice.append(2) #right
        elif j>0 and j<=5:
            rand3=numpy.random.rand()
            if rand3<=0.5:
                comChoice.append(1) #left
            else:
                comChoice.append(2) #right
            if rewardHis[j-1]==1:
                choiceHis.append(choiceHis[j-1]) #if win, stay
            elif rewardHis[j-1]==0:
                if choiceHis[j-1]==1:
                    choiceHis.append(2)
                elif choiceHis[j-1]==2:
                    choiceHis.append(1)
        elif j>5:
            for k in range(5):
                leftcount,rightcount=choice_counting(choiceHis,k)
                p=scipy.stats.binom_test(rightcount, rightcount+leftcount, 0.5, alternative='two-sided')
                if p<sigP:
                    if abs(float(rightcount)/(rightcount+leftcount)-0.5)>abs(minprob-0.5):
                        minprob=float(rightcount)/(rightcount+leftcount)
            minprobList.append(minprob)
            rand=numpy.random.rand()
            if rand<=minprob:
                comChoice.append(1)
            else:
                comChoice.append(2)
            if rewardHis[j-1]==1:
                choiceHis.append(choiceHis[j-1]) #if win, stay
            elif rewardHis[j-1]==0:
                if choiceHis[j-1]==1:
                    choiceHis.append(2)
                elif choiceHis[j-1]==2:
                    choiceHis.append(1)
                    #if lose, switch
      #determine reward
        if choiceHis[j]==comChoice[j]:
           rewardHis.append(1)
        else:
           rewardHis.append(0)
    rewardRate.append(sum(rewardHis)/500.0)
            