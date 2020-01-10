# -*- coding: utf-8 -*-
"""
Created on Tue Oct 31 10:40:29 2017

@author: Hongli Wang
"""

#generate binomial-test cheat sheet


import scipy.stats

pValueList=[[] for x in range(500)]
f = open('binomialtest_biased_cheatsheet.txt', 'w')
for i in range(500):
    for j in range(500-i):
        pValueList[i].append(scipy.stats.binom_test(i, i+j, 0.666666667, alternative='two-sided'))
        f.write(str(pValueList[i][j])+' ')
    f.write('\n')
        
f.close()
