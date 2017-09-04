# -*- coding: utf-8 -*-
"""
Created on Tue Aug 22 16:58:51 2017

@author: Hongli Wang
"""

import scipy.stats #for test
import numpy.random
import matplotlib.pyplot as plt

def choice_counting(choiceHistory, num):
     
    leftCount=0
    rightCount=0
    
    if num==0:
        for i in range(len(choiceHistory)):
            if choiceHistory[i] == 0:
                leftCount+=1
            else:
                rightCount+=1
    else:   
        comb=choiceHistory[-num:]
      
    
        for i in range(len(choiceHistory)-num):
            if choiceHistory[i:i+num] == comb:
                if choiceHistory[i+num] == 0:
                    leftCount+=1
                else:
                    rightCount+=1
                
    return leftCount, rightCount
    


#c = [0,1,0,1,0,0,0,1,0,1,0,1,0,1,1,0,1,1,1,0]

#left,right=choice_counting(c,3)

#print "left ", left, " right ", right


#try to do the binomial test


def factorial(n):
    if n==0:
        factorial = 1
    else:
        factorial = 1
        for i in range(n):
            factorial *= (i+1)
    return factorial


def binomial_dis(x, n, p):
    #before do the stats test, first calculate the distribution
    prob = factorial(n) / (factorial(n-x)*factorial(x)) * (p ** x) * ((1-p) ** (n-x))
    
    return prob



def binomial_test(n, N, p):

    #now do the two-tailed binomial test
    #this only works for p=0.5
    
    
    sum = 0
    #mean=N * p
    
    #the integration interval
    
    if n < N-n:
        lower_inter = n
        higher_inter = N-n
    else:
         lower_inter = N-n
         higher_inter = n
    
    for i in range(lower_inter+1):
        sum += binomial_dis(i, N, p)
        
    for j in range(higher_inter, N+1):
        sum += binomial_dis(j, N, p)
    
    if sum>1:
        return 1.0
    else:
        return sum



                
"""now run the algorithm"""

#generate a random 100 choice list
#0: left
#1: right
agentChoice=[]
comChoice = []
reward=[]

pValueMat= [[0 for col in range(400)] for row in range(5)]
leftMat=[[0 for col in range(400)] for row in range(5)]
rightMat=[[0 for col in range(400)] for row in range(5)]
randMat=[0]*400
probMat=[0]*400

for i in range(400):
    
    #agent's choice
    
        
    
    #now the computer's choice
    if i<=4:
        rand =numpy.random.uniform(0,1)
        if rand <= 0.5:
            comChoice.append(0)
        else:
            comChoice.append(1)
        randMat[i]=rand
        probMat[i]=0.5
    else:
        maxP = 0.05
        probability=0.5
        for j in range(5):
            left,right = choice_counting(agentChoice,j)
            leftMat[j][i] = left
            rightMat[j][i] = right
            
            totalN = left+right
        
            pValue = binomial_test(right, totalN, 0.5)
            pValueMat[j][i] = pValue
            
            if pValue < maxP:
                probability = right/totalN
                maxP=pValue
        
        if probability==0.5:
            rand =numpy.random.uniform(0,1)
            randMat[i]=rand
            probMat[i]=probability
            if rand <= 0.5:
                comChoice.append(0)
            else:
                comChoice.append(1)
        else:
            rand=numpy.random.uniform(0,1)
            randMat[i]=rand
            probMat[i]=1-probability
            if rand >=1-probability:
                comChoice.append(0)
            else:
                comChoice.append(1)
                
    rand =numpy.random.uniform(0,1)
    if rand <= 0.5:
        agentChoice.append(0)
    else:
        agentChoice.append(1)
                
    #determine the reward
    if agentChoice[i] == comChoice[i]:
        reward.append(1)
    else:
        reward.append(0)
        
#print "agentChoice: ", agentChoice
#print "comChoice: ", comChoice
#print "reward: ", reward
            
#print "pValue Matrix:\n", pValueMat
#print "left matrix:\n", leftMat
#print "right matrix:\n", rightMat

    
 #try to plot the data

   
    
xAxis = [i for i in range(400)]
plt.plot(xAxis, agentChoice, xAxis ,comChoice)


plt.plot(xAxis, reward)

    
    
    
    
    
    
    
    
    
    
    
    
    