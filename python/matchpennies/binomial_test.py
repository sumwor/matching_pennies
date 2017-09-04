# -*- coding: utf-8 -*-
"""
Created on Tue Aug 22 17:12:07 2017

@author: Hongli Wang
"""

#try to do the binomial test
import scipy.stats #for test

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


p = binomial_test(5, 6, 0.5)
print p

#print binomial_dis(1, 2, 0.5)

p1 = scipy.stats.binom_test(5, 6, 0.5, alternative='two-sided')

print p1

