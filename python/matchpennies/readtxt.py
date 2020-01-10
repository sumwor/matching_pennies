# -*- coding: utf-8 -*-
"""
Created on Thu Sep 21 16:36:32 2017

@author: Hongli Wang
"""
import matplotlib.pyplot as plt

import scipy.stats


# f = open('E:/data/matching_pennies/Algo2test_1_18.txt')             # 返回一个文件对象
f = open('E:\labcode\matching_penniess\python\matchpennies\\test\Algo2_baisedtest_12_10.txt')
t=0
# totalTime=[]
agentchoice=[]
agentreward=[]
probright=[]
minP=[]
leftChoice=[[0 for x in range(5)] for y in range(100)]
rightChoice=[[0 for x in range(5)] for y in range(100)]
x=0
y=0
#for algotithm1
"""
for line in f:
    #print line,                 # 后面跟 ',' 将忽略换行符
    # print(line, end = '')　　　# 在 Python 3中使用
    if t!=0:
    
        l=line.split('\t')
    
        print(l)
        if t%3==1:
            agentchoice.append(l[0])
            probright.append(l[3])
            totalTime.append(l[4])
        elif t%3==2:
            leftChoice[x][:]=l
            x+=1
        elif t%3==0:
            rightChoice[y][:]=l
            y+=1
            
    t+=1
    """
#for algorithm2two
for line in f:
    #print line,                 # 后面跟 ',' 将忽略换行符
    # print(line, end = '')　　　# 在 Python 3中使用
    if x<100:
        if t!=0:
    
            l=line.split('\t')
    
            print(l)
            if t%5==1:
                agentchoice.append(l[0])
                agentreward.append(l[2])
                probright.append(l[3])
            # totalTime.append(l[4])
            elif t%5==2:
                leftChoice[x][:]=l
                x+=1
            elif t%5==0:
                rightChoice[y][:]=l
                y+=1
            
        t+=1
    else:
        break


f.close()

def choice_counting(choiceHistory, num):
     
    leftCount=0
    rightCount=0
    
    if num==0:
        for i in range(len(choiceHistory)):
            if choiceHistory[i] == '2':
                leftCount+=1
            else:
                rightCount+=1
    else:   
        comb=choiceHistory[-num:]
      
    
        for i in range(len(choiceHistory)-num):
            if choiceHistory[i:i+num] == comb:
                if choiceHistory[i+num] == '2':
                    leftCount+=1
                else:
                    rightCount+=1
                
    return leftCount, rightCount

def choicereward_counting(choiceHistory, rewardHistory, num):

    leftCount=0
    rightCount=0

    if num==0:
        for i in range(len(choiceHistory)):
            if choiceHistory[i] == 2:
                leftCount+=1
            elif choiceHistory[i]==3:
                rightCount+=1
    else:
        comb=choiceHistory[-num:]
        combre=rewardHistory[-num:]


        for i in range(len(choiceHistory)-num):
            if choiceHistory[i:i+num] == comb:
                if rewardHistory[i:i+num] == combre:
                    if choiceHistory[i+num] == 2:
                        leftCount+=1
                    elif choiceHistory[i+num]==3:
                        rightCount+=1

    return leftCount, rightCount

minPp=[]

prob=[]
leftCountPy=[[0 for x in range(5)] for y in range(500)]
rightCountPy=[[0 for x in range(5)] for y in range(500)]
#pValueMat= [[0 for col in range(400)] for row in range(5)]
#doing the binomial test
for i in range(len(agentchoice)):
    minprob = 0.67
    maxP = 0.05
    probability=0.67
    curChoice=agentchoice[0:i+1]
    curReward=agentreward[0:i+1]
    for j in range(5):
        left,right = choice_counting(curChoice,j)
        leftCountPy[i][j]=left
        rightCountPy[i][j]=right
        #leftMat[j][i] = left
        #rightMat[j][i] = right
            
        totalN = left+right
        
        pValue =scipy.stats.binom_test(left, totalN, 0.67, alternative='two-sided')
       # pValueMat[j][i] = pValue
            
        if pValue < maxP:
            probability = float(left)/totalN
            if abs(probability - 0.67) > abs(minprob - 0.67):
                minprob = probability
            maxP=pValue

    for k in range(5):
        left, right = choicereward_counting(curChoice, curReward, k)
        totalN = left + right
        pValue = scipy.stats.binom_test(left, totalN, 0., alternative='two-sided')

        if pValue < maxP:
            probability = float(left)/totalN
            if abs(probability - 0.67) > abs(minprob - 0.67):
                minprob = probability
            maxP=pValue

    minPp.append(maxP)
    prob.append(minprob)

minProbdyn=[0.67,0.67,0.67,0.67,0.67]
probdyn=[]
#test dynamic programming
def baseInd(seq):
    base=0
    for i in range(len(seq)):
        base+=(int(seq[i])-2)*2**(len(seq)-i-1)
    return base

def BbaseInd(seq):
    base=0
    for i in range(len(seq)):
        base+=(int(seq[i])-2)*2**(len(seq)-i)
    return base
dyncountlist=[0 for x in range(32)]
leftCountPydyn=[[0 for x in range(5)] for y in range(500)]
rightCountPydyn=[[0 for x in range(5)] for y in range(500)]
newChoice=[]
for i in range(len(agentchoice)):
    maxP=0.05
    minprob=0.67
    if agentchoice[i]!='0':
        newChoice.append(agentchoice[i])
    #update dynamic
    if i>=4 and agentchoice[i]!='0':
       temp=newChoice[-5:]
       Ind=baseInd(temp)
       print(Ind)
       print(temp)
       dyncountlist[Ind]+=1
    
    #count
       for j in range(5):
           if j==0:
               leftCount,rightCount=choice_counting(newChoice, 0)
           else:
               searchSeq=newChoice[-j:]
               basse=BbaseInd(searchSeq)
               # print("j=", j)
               # print(searchSeq)
               if j==4:
                   leftCount=dyncountlist[basse]
                   rightCount=dyncountlist[basse+1]
               elif j==3:
                   leftCount=dyncountlist[basse]+dyncountlist[basse+16]
                   rightCount=dyncountlist[basse+1]+dyncountlist[basse+17]
               elif j==2:
                   leftCount=dyncountlist[basse]+dyncountlist[basse+16]+dyncountlist[basse+8]+dyncountlist[basse+24]
                   rightCount=dyncountlist[basse+17]+dyncountlist[basse+1]+dyncountlist[basse+9]+dyncountlist[basse+25]
               elif j==1:
                   leftCount=dyncountlist[basse]+dyncountlist[basse+4]+dyncountlist[basse+8]+dyncountlist[basse+12]+dyncountlist[basse+16]+dyncountlist[basse+20]+dyncountlist[basse+24]+dyncountlist[basse+28]
                   rightCount=dyncountlist[basse+1]+dyncountlist[basse+5]+dyncountlist[basse+9]+dyncountlist[basse+13]+dyncountlist[basse+17]+dyncountlist[basse+21]+dyncountlist[basse+25]+dyncountlist[basse+29]
           leftCountPydyn[i][j]=leftCount
           rightCountPydyn[i][j]=rightCount
           
           totalN = leftCount+rightCount
        
           pValue =scipy.stats.binom_test(leftCount, totalN, 0.67, alternative='two-sided')
       # pValueMat[j][i] = pValue
            
           if pValue < maxP:
               probability = float(leftCount)/totalN
               if abs(probability-0.67)>abs(minprob-0.67):
                   minprob=probability
       minProbdyn.append(minprob)
       #probdyn.append(probability)
    elif agentchoice[i]=='0':
       minProbdyn.append(minProbdyn[-1])


plt.plot(probright)
plt.plot(prob)
plt.show()
print('stop')