# -*- coding: utf-8 -*-
"""
Created on Mon Jan 08 14:25:29 2018

@author: Hongli Wang
"""
import math
ChoiceList=[]
RewardList=[]
VRList=[]
VLList=[]
PRlist=[]
valueR=0
valueL=0
alpha=0
deltaWin=0
deltaLose=0

for i in range(len(ChoiceList)):
    if ChoiceList[i]==1:  #left
        if RewardList[i]==1:
            valueR=alpha*valueR+0
            valueL=alpha*valueL+deltaWin
            prob=math.e**(valueR-valueL)/(1+math.e**(valueR-valueL))
            PRlist.append(prob)
        else:
            valueR=alpha*valueR+0
            valueL=alpha*valueL+deltaLose
            prob=math.e**(valueR-valueL)/(1+math.e**(valueR-valueL))
            PRlist.append(prob)
    else:
        if RewardList[i]==1:
            valueR=alpha*valueR+deltaWin
            valueL=alpha*valueL+0
            prob=math.e**(valueR-valueL)/(1+math.e**(valueR-valueL))
            PRlist.append(prob)
        else:
            valueR=alpha*valueR+deltaLose
            valueL=alpha*valueL+0
            prob=math.e**(valueR-valueL)/(1+math.e**(valueR-valueL))
            PRlist.append(prob)
