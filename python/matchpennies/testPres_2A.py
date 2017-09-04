# -*- coding: utf-8 -*-
"""
Created on Thu Aug 31 16:44:18 2017

@author: Hongli Wang
"""

# -*- coding: utf-8 -*-
"""
Created on Wed Aug 30 15:56:47 2017

@author: Hongli Wang
"""

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

def binomial_test1(n, N, p):

    #now do the two-tailed binomial test
    #this only works for p=0.5
    
    
    sum = 0
    #mean=N * p
    
    #the integration interval
    mean = N*p
    if n < mean:
        lower_inter = 0
        higher_inter = n
    else:
        higher_inter = N
        lower_inter = n

    
    for i in range(lower_inter,higher_inter+1):
        sum += binomial_dis(i, N, p)
    if sum*2 > 1:
        return 1
    else:
        return sum*2
    
def choice_counting(choiceHistory, rewardHistory, num):

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


fpath='C:/Users/Hongli Wang/Documents/PythonScripts/matchpennies/test/Algo2test1.txt'

f=open(fpath)


line=[]

for ll in f:
    line.append(ll)
    

agentChoice=[]
agentReward=[]

for x in line[1:]:
    
    agentChoice.append((float(x[0])))
    agentReward.append((float(x[4])))
agent=[]
reward=[]

pValueMat= [[0 for col in range(400)] for row in range(5)]

probMat=[0]*40

pValueMat= [[0 for col in range(40)] for row in range(5)]

for i in range(40):
    agent.append(agentChoice[i])
    reward.append(agentReward[i])
    if i<=4:
        probMat[i]=0.5
    else:
        maxP=0.05
        prob=0.5
        for j in range(5):
            left, right=choice_counting(agent,reward,j)
            totalN=left+right
            pValue=binomial_test(right,totalN,0.5)
            pValueMat[j][i]=pValue
            if pValue<maxP:
                prob=float(right)/totalN
                maxP=pValue
        probMat[i]=prob
        
