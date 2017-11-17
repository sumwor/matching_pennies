# -*- coding: utf-8 -*-
"""
Created on Mon Sep 18 11:54:48 2017

@author: Hongli Wang
"""

#generate a z-score - p-value cheat sheet

from scipy.stats import norm

zscore=[0]*800
pvalue=[0]*1000
f = open('zscore_pvalue_cheatsheet.txt', 'w')
for i in xrange(800):
    zscore[i]=i/100.0
    pvalue[i]=(1-norm.cdf(i/100.0))*2  #two-tailed test
    f.write(str(pvalue[i])+' ')
    if i%5==4:
        f.write('\n')

    

f.close()
