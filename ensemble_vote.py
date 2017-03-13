# -*- coding: utf-8 -*-
"""
Created on Mon Aug 15 11:30:25 2016

@author: zhal
"""

import sys
import operator

predicts = []
for j in range(1, len(sys.argv)):
    f_predicts = open(sys.argv[j],'r')
    predicts.append(f_predicts.readlines())
    f_predicts.close()
    
for i in range(len(predicts[0])):
    dic_p = {}
    for predict in predicts:
        key_ = predict[i]
        if key_ not in dic_p:
            dic_p[key_] = 1
        else:
            dic_p[key_] += 1
    print sorted(dic_p.items(), key=operator.itemgetter(1))[-1][0].strip()
