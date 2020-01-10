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
import matplotlib.pyplot as plt

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

agentProb = []
agentReward = []
agentChoice = []

fpath='E:\labcode\matching_penniess\python\matchpennies\\test\Algo2_baisedtest_12_10.txt'

f=open(fpath)
t = 0
x = 0
for line in f:
    # print line,                 # 后面跟 ',' 将忽略换行符
    # print(line, end = '')　　　# 在 Python 3中使用
    if x < 100:
        if t != 0:

            l = line.split('\t')

            print(l)
            if t % 5 == 1:
                agentChoice.append(l[0])
                agentReward.append(l[2])
                agentProb.append(l[3])
                x += 1
            # totalTime.append(l[4])
            # elif t % 5 == 2:
            #    leftChoice[x][:] = l
            #    x += 1
            # elif t % 5 == 0:
            #    rightChoice[y][:] = l
            #    y += 1
        t += 1
    else:
        break

f.close()

agent=[]
reward=[]

pValueMat= [[0 for col in range(400)] for row in range(5)]

probMat=[0]*100

pValueMat= [[0 for col in range(100)] for row in range(5)]

for i in range(100):
    agent.append(agentChoice[i])
    reward.append(agentReward[i])
    if i<=4:
        probMat[i]=0.67
    else:
        maxP=0.05
        prob=0.67
        for j in range(5):
            left, right=choice_counting(agent,reward,j)
            totalN=left+right
            pValue=binomial_test(left,totalN,0.67)
            pValueMat[j][i]=pValue
            if pValue<maxP:
                prob=float(left)/totalN
                maxP=pValue
        probMat[i]=prob
        
plt.plot(agentProb)
plt.plot(probMat)
plt.show()