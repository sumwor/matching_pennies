# -*- coding: utf-8 -*-
"""
Created on Tue Nov 07 10:33:31 2017

@author: Hongli Wang
"""

# -*- coding: utf-8 -*-
"""
Created on Thu Sep 21 16:36:32 2017

@author: Hongli Wang
"""
import matplotlib.pyplot as plt

import scipy.stats


f = open('E:/data/matching_pennies/Algo2test_1_18.txt')             # 返回一个文件对象
t=0
totalTime=[]
agentchoice=[]
rewardChoice=[]
probright=[]
minP=[]
leftChoice=[[0 for x in range(5)] for y in range(500)]
rightChoice=[[0 for x in range(5)] for y in range(500)]
leftChoiceChoice=[[0 for x in range(5)] for y in range(500)]
rightChoiceChoice=[[0 for x in range(5)] for y in range(500)]
x=0
y=0
w=0
v=0
for line in f:
    #print line,                 # 后面跟 ',' 将忽略换行符
    # print(line, end = '')　　　# 在 Python 3中使用
    if t!=0:
    
        l=line.split('\t')
    
        #print l
        if t%5==1:
            agentchoice.append(l[0])
            rewardChoice.append(int(l[2])+2)
            probright.append(l[3])
            totalTime.append(l[4])
        elif t%5==2:
            leftChoice[x][:]=l
            x+=1
        elif t%5==3:
            rightChoice[y][:]=l
            y+=1
        elif t%5==4:
            leftChoiceChoice[w][:]=l
            w+=1
        elif t%5==0:
            print l
            rightChoiceChoice[v][:]=l
            v+=1
            
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


#test dynamic programming
IndNeed=[0, 4, 8, 12, 16, 20, 24, 28]
Ind1=[0, 4, 8, 12, 16, 20, 24, 28]
for i in range(8):
    Ind1[i]+=64
IndNeed+=Ind1
temp=[0 for x in range(16)]
for i in range(16):
    temp[i]=IndNeed[i]+128
IndNeed+=temp
temp2=[0 for x in range(32)]
for i in range(32):
    temp2[i]=IndNeed[i]+256
IndNeed+=temp2

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
minPdyn=[0.05,0.05,0.05,0.05,0.05]
probdyn=[]
minProb=0.5
dyncountlist=[0 for x in range(512)]
dyncountlist1=[0 for x in range(32)]
leftCountPydyn=[[0 for x in range(5)] for y in range(500)]
rightCountPydyn=[[0 for x in range(5)] for y in range(500)]
leftCountPydyn1=[[0 for x in range(5)] for y in range(500)]
rightCountPydyn1=[[0 for x in range(5)] for y in range(500)]
newChoice=[]
newReward=[]
for i in range(len(agentchoice)-1):
    maxP=0.05
    probability=0.5
    minProb=0.5
    if agentchoice[i]!='0':
        newChoice.append(agentchoice[i])
        newReward.append(rewardChoice[i])
    #update dynamic
    if i>=4 and agentchoice[i]!='0':
       temp=newReward[-5:-1]
       temp+=newChoice[-5:]
       Ind=baseInd(temp)
       print Ind
       print temp
       dyncountlist[Ind]+=1
       
       temp1=newChoice[-5:]
       Ind1=baseInd(temp1)
       print Ind1
       print temp1
       dyncountlist1[Ind1]+=1
    
    
    #count
    if i>=4:
       for j in range(5):
           leftCount=0
           rightCount=0
           if j==0:
               leftCount=0
               rightCount=0
               leftCount1,rightCount1=choice_counting(newChoice, 0)
           else:
               searchSeq=newReward[-j:]
               for x in range(4-j):
                   searchSeq.append(2)
               searchSeq+=newChoice[-j:]
               basse=BbaseInd(searchSeq)
               
               searchSeq1=newChoice[-j:]
               basse1=BbaseInd(searchSeq1)
               print "j=", j
               print searchSeq
               if j==4:
                   leftCount=dyncountlist[basse]
                   rightCount=dyncountlist[basse+1]
                   leftCount1=dyncountlist1[basse1]
                   rightCount1=dyncountlist1[basse1+1]
               elif j==3:
                   leftCount1=dyncountlist1[basse1]+dyncountlist1[basse1+16]
                   rightCount1=dyncountlist1[basse1+1]+dyncountlist1[basse1+17]
                   leftCount=dyncountlist[basse]+dyncountlist[basse+16]+dyncountlist[basse+256]+dyncountlist[basse+272]
                   rightCount=dyncountlist[basse+1]+dyncountlist[basse+17]+dyncountlist[basse+257]+dyncountlist[basse+273]
               elif j==2:
                   leftCount1=dyncountlist1[basse1]+dyncountlist1[basse1+16]+dyncountlist1[basse1+8]+dyncountlist1[basse1+24]
                   rightCount1=dyncountlist1[basse1+17]+dyncountlist1[basse1+1]+dyncountlist1[basse1+9]+dyncountlist1[basse1+25]
#                   leftCount=dyncountlist[basse]+dyncountlist[basse+8]+dyncountlist[basse+16]+dyncountlist[basse+24]+dyncountlist[basse+128]+dyncountlist[basse+136]+dyncountlist[basse+144]+dyncountlist[basse+152]+dyncountlist[basse+256]+dyncountlist[basse+264]+dyncountlist[basse+272]+dyncountlist[basse+280]+dyncountlist[basse+384]+dyncountlist[basse+392]+dyncountlist[basse+400]+dyncountlist[basse+408]
#                   rightCount=dyncountlist[basse+1]+dyncountlist[basse+16+1]+dyncountlist[basse+8+1]+dyncountlist[basse+24+1]+dyncountlist[basse+128+1]+dyncountlist[basse+136+1]+dyncountlist[basse+144+1]+dyncountlist[basse+152+1]+dyncountlist[basse+256+1]+dyncountlist[basse+264+1]+dyncountlist[basse+272+1]+dyncountlist[basse+280+1]+dyncountlist[basse+384+1]+dyncountlist[basse+392+1]+dyncountlist[basse+400+1]+dyncountlist[basse+408+1]
                   leftCount=dyncountlist[0+basse]+dyncountlist[8+basse]+dyncountlist[16+basse]+dyncountlist[24+basse]+dyncountlist[128+basse]+dyncountlist[136+basse]+dyncountlist[144+basse]+dyncountlist[152+basse]+dyncountlist[256+basse]+dyncountlist[264+basse]+dyncountlist[272+basse]+dyncountlist[280+basse]+dyncountlist[384+basse]+dyncountlist[392+basse]+dyncountlist[400+basse]+dyncountlist[408+basse]
                   rightCount=dyncountlist[1+basse]+dyncountlist[9+basse]+dyncountlist[17+basse]+dyncountlist[25+basse]+dyncountlist[129+basse]+dyncountlist[137+basse]+dyncountlist[145+basse]+dyncountlist[153+basse]+dyncountlist[257+basse]+dyncountlist[265+basse]+dyncountlist[273+basse]+dyncountlist[281+basse]+dyncountlist[385+basse]+dyncountlist[393+basse]+dyncountlist[401+basse]+dyncountlist[409+basse]
               elif j==1:
                   leftCount1=dyncountlist1[basse1]+dyncountlist1[basse1+4]+dyncountlist1[basse1+8]+dyncountlist1[basse1+12]+dyncountlist1[basse1+16]+dyncountlist1[basse1+20]+dyncountlist1[basse1+24]+dyncountlist1[basse1+28]
                   rightCount1=dyncountlist1[basse1+1]+dyncountlist1[basse1+5]+dyncountlist1[basse1+9]+dyncountlist1[basse1+13]+dyncountlist1[basse1+17]+dyncountlist1[basse1+21]+dyncountlist1[basse1+25]+dyncountlist1[basse1+29]
                   for ind in IndNeed:
                       leftCount+=dyncountlist[basse+ind]
                       rightCount+=dyncountlist[basse+1+ind]
           leftCountPydyn[i+1][j]=leftCount
           rightCountPydyn[i+1][j]=rightCount
           leftCountPydyn1[i+1][j]=leftCount1
           rightCountPydyn1[i+1][j]=rightCount1
           totalN = leftCount+rightCount
           totalN1=leftCount1+rightCount1
        
           pValue =scipy.stats.binom_test(rightCount, totalN, 0.5, alternative='two-sided')
       # pValueMat[j][i] = pValue
            
           if pValue < maxP:
               probability = float(rightCount)/totalN
               if abs(probability-0.5)>abs(minProb-0.5):
                   minProb=probability
           pValue1 =scipy.stats.binom_test(rightCount1, totalN1, 0.5, alternative='two-sided')
           if pValue1<maxP:
               probability = float(rightCount1)/totalN1
               if abs(probability-0.5)>abs(minProb-0.5):
                   minProb=probability
       minPdyn.append(maxP)
       probdyn.append(minProb)
dyncountlist=[0 for x in range(32)]
leftCountPydyn1=[[0 for x in range(5)] for y in range(500)]
rightCountPydyn1=[[0 for x in range(5)] for y in range(500)]
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
           leftCountPydyn1[i][j]=leftCount
           rightCountPydyn1[i][j]=rightCount
#dyncountlist=[0 for x in range(512)]
#leftCountPydyn=[[0 for x in range(5)] for y in range(500)]
#rightCountPydyn=[[0 for x in range(5)] for y in range(500)]
#newChoice=[]
#newReward=[]
#for i in range(len(agentchoice)):
#    maxP=1
#    prob=0.5
#    newChoice.append(agentchoice[i])
#    newReward.append(rewardChoice[i])
#    #update dynamic
#        
#    if i>=4:
#       temp=newReward[-5:-1]
#       temp+=newChoice[-5:]
#       Ind=baseInd(temp)
#       print Ind
#       print temp
#       dyncountlist[Ind]+=1
#    
#    #count
#       for j in range(5):
#           leftCount=0
#           rightCount=0
#           if j==0:
#               leftCount=0
#               rightChouce=0
#           else:
#               searchSeq=newReward[-j:]
#               for i in range(4-j):
#                   searchSeq.append(2)
#               searchSeq+=newChoice[-j:]
#               basse=BbaseInd(searchSeq)
#               print "basse", basse
#               print "j=", j
#               print searchSeq
#               if j==4:
#                   leftCount=dyncountlist[basse]
#                   rightCount=dyncountlist[basse+1]
#               elif j==3:
#                   leftCount=dyncountlist[basse]+dyncountlist[basse+16]+dyncountlist[basse+256]+dyncountlist[basse+272]
#                   rightCount=dyncountlist[basse+1]+dyncountlist[basse+17]+dyncountlist[basse+257]+dyncountlist[basse+273]
#               elif j==2:
#                   leftCount=dyncountlist[basse]+dyncountlist[basse+16]+dyncountlist[basse+8]+dyncountlist[basse+24]+dyncountlist[basse+128]+dyncountlist[basse+136]+dyncountlist[basse+144]+dyncountlist[basse+152]+dyncountlist[basse+256]+dyncountlist[basse+264]+dyncountlist[basse+272]+dyncountlist[basse+280]+dyncountlist[basse+384]+dyncountlist[basse+392]+dyncountlist[basse+400]+dyncountlist[basse+408]
#                   rightCount=dyncountlist[basse+1]+dyncountlist[basse+16+1]+dyncountlist[basse+8+1]+dyncountlist[basse+24+1]+dyncountlist[basse+128+1]+dyncountlist[basse+136+1]+dyncountlist[basse+144+1]+dyncountlist[basse+152+1]+dyncountlist[basse+256+1]+dyncountlist[basse+264+1]+dyncountlist[basse+272+1]+dyncountlist[basse+280+1]+dyncountlist[basse+384+1]+dyncountlist[basse+392+1]+dyncountlist[basse+400+1]+dyncountlist[basse+408+1]
#               elif j==1:
#                   for ind in IndNeed:
#                       leftCount+=dyncountlist[basse+ind]
#                       print basse+ind
#                       print dyncountlist[basse+ind]
#                       rightCount=dyncountlist[basse+ind+1]
#                   print leftCount
#           leftCountPydyn[i][j]=leftCount
#           rightCountPydyn[i][j]=rightCount
#           
#           totalN = leftCount+rightCount
#        
#           pValue =scipy.stats.binom_test(rightCount, totalN, 0.5, alternative='two-sided')
#       # pValueMat[j][i] = pValue
#            
#           if pValue < maxP:
#               probability = float(right)/totalN
#               maxP=pValue
#       minPdyn.append(maxP)
       #probdyn.append(probability)