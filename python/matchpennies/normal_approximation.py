# -*- coding: utf-8 -*-
"""
Created on Thu Sep 07 08:24:45 2017

@author: Hongli Wang
"""

#normal approximation of binomial test
#miu=np, sigma=sqrt(np(1-p))

import math
import scipy.stats

pi=3.141592653589793

def p_normal(x, miu, var):
    return 1.0/math.sqrt(2*pi*var) * math.exp(-(x-miu)**2/(2*float(var)))


def normal_appro(x, n, p, step):
    #only for two-tailed, p=0.5 binomial test
    #rectangle integration
    #no integration
    miu=n*p
    var=n*p*(1-p)
    sum=0
    
    if x<n-x:
        lower=x
        higher=n-x
    else:
        lower=n-x
        higher=x
        
    for i in range(0,(lower+1)*1000,int(step*1000)):
        sum+=p_normal(i/1000.0,miu,var)*step
        
    for j in range((higher)*1000, (n)*1000,int(step*1000)):
        sum+=p_normal(j/1000.0,miu,var)*step
        
    if sum>1:
        return 1.0
    else:
        return sum

#def normal_appro_integ(x, miu,var):
def normal_appro_tixing(x, n, p, step):
    #only for two-tailed, p=0.5 binomial test
    #tixing integration
    #no integration
    miu=n*p
    var=n*p*(1-p)
    sum=0
    
    if x<n-x:
        lower=x
        higher=n-x
    else:
        lower=n-x
        higher=x
        
    for i in range(0,(lower+1)*1000,int(step*1000)):
        sum+=0.5*(p_normal(i/1000.0,miu,var)+p_normal((i+1)/1000.0, miu,var))*step
        
    for j in range((higher)*1000, (n)*1000,int(step*1000)):
        sum+=0.5*(p_normal(j/1000.0,miu,var)+p_normal((j+1)/1000.0,miu,var))*step
        
    if sum>1:
        return 1.0
    else:
        return sum
    
#def normal_appro_integ(x, miu,var):
def normal_appro_simpson(x, n, p, N):
    #only for two-tailed, p=0.5 binomial test
    #tixing integration
    #no integration
    miu=n*p
    var=n*p*(1-p)
    sum=0
    
    if x<n-x:
        lower=x
        higher=n-x
    else:
        lower=n-x
        higher=x
        
    hlow=(lower)/float(2*N)
    hhigh=(n-higher)/float(2*N)
        
    for i in range(N):
        sum+=2*hlow/6*(p_normal(hlow*(2*i-2),miu,var)+4*p_normal((hlow*(2*i-1)), miu,var)+p_normal((hlow*2*i), miu, var))
        
    for j in range(N):
       sum+=2*hhigh/6*(p_normal(higher+hhigh*(2*j-2),miu,var)+4*p_normal((higher+hhigh*(2*j-1)), miu,var)+p_normal((higher+hhigh*2*j), miu, var))
        
    if sum>1:
        return 1.0
    else:
        return sum



#test, while n>30

p1=normal_appro(50, 200, 0.5, 0.001)

p1_1=normal_appro_tixing(50, 200, 0.5, 0.001)

p1_2 = normal_appro_simpson(50, 200, 0.5, 25000)
p2=scipy.stats.binom_test(50, 200, 0.5, alternative='two-sided')

print p1

print p1_1

print p1_2

print p2