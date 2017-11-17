# -*- coding: utf-8 -*-
"""
Created on Thu Sep 21 16:36:32 2017

@author: Hongli Wang
"""
import matplotlib.pyplot as plt

import scipy.stats


f = open('G:/Algo1test_zscore_10_31.txt')             # 返回一个文件对象
t=0
totalTime=[]
agentchoice=[]
probright=[]
minP=[]
leftChoice=[[0 for x in range(5)] for y in range(400)]
rightChoice=[[0 for x in range(5)] for y in range(400)]
x=0
y=0
for line in f:
    #print line,                 # 后面跟 ',' 将忽略换行符
    # print(line, end = '')　　　# 在 Python 3中使用
    if t!=0:
    
        l=line.split('\t')
    
        print l
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

minPp=[]
prob=[]
leftCountPy=[[0 for x in range(5)] for y in range(400)]
rightCountPy=[[0 for x in range(5)] for y in range(400)]
#pValueMat= [[0 for col in range(400)] for row in range(5)]
#doing the binomial test
for i in range(len(agentchoice)):
    maxP = 1
    probability=0.5
    curChoice=agentchoice[0:i+1]
    for j in range(5):
        left,right = choice_counting(curChoice,j)
        leftCountPy[i][j]=left
        rightCountPy[i][j]=right
        #leftMat[j][i] = left
        #rightMat[j][i] = right
            
        totalN = left+right
        
        pValue =scipy.stats.binom_test(right, totalN, 0.5, alternative='two-sided')
       # pValueMat[j][i] = pValue
            
        if pValue < maxP:
            probability = float(right)/totalN
            maxP=pValue
    minPp.append(maxP)
    prob.append(probability)

minPdyn=[1,1,1,1,1]
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
leftCountPydyn=[[0 for x in range(5)] for y in range(400)]
rightCountPydyn=[[0 for x in range(5)] for y in range(400)]
newChoice=[]
for i in range(len(agentchoice)):
    maxP=1
    prob=0.5
    newChoice.append(agentchoice[i])
    #update dynamic
    if i>=4:
       temp=newChoice[-5:]
       Ind=baseInd(temp)
       print Ind
       print temp
       dyncountlist[Ind]+=1
    
    #count
       for j in range(5):
           if j==0:
               leftCount,rightCount=choice_counting(newChoice, 0)
           else:
               searchSeq=newChoice[-j:]
               basse=BbaseInd(searchSeq)
               print "j=", j
               print searchSeq
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
        
           pValue =scipy.stats.binom_test(rightCount, totalN, 0.5, alternative='two-sided')
       # pValueMat[j][i] = pValue
            
           if pValue < maxP:
               probability = float(right)/totalN
               maxP=pValue
       minPdyn.append(maxP)
       #probdyn.append(probability)