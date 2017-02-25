from path import *
from method_1_prob import method_1
from method_2_prob import method_2
from method_3_prob import method_3
from graphics import PlotPSSProbabilityDetection, PlotPSSProbabilityFailure

sd = [0.1, 0.125, 0.15, 0.175, 0.2, 0.225, 0.25, 0.275, 0.3, 0.325, 0.35, 0.375, 0.4, 0.45]
p1 = []
p2 = []
p3 = []

for value in sd:
    print 'processing = ',value
    p1.append(method_1(10000,value))
    p2.append(method_2(10000,value))
    p3.append(method_3(10000,value))


legend = ['Linear Correlation Scheme','Circular Correlation Scheme','Product Scheme']
title = 'Probability of PSS Detection'
PlotPSSProbabilityDetection(p1, p2, p3, sd, 1, title, legend)
PlotPSSProbabilityFailure(p1, p2, p3, sd, 2, title, legend)


##sd = [0.1, 0.125, 0.15, 0.175, 0.2, 0.225, 0.25, 0.275, 0.3, 0.325, 0.35, 0.375, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65]
##p1 = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.999, 0.9974, 0.991, 0.9854, 0.9637, 0.9468, 0.8747, 0.7954, 0.7079, 0.6218, 0.5516]
##p2 = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.9996, 0.9967, 0.9899, 0.9659, 0.9369, 0.8868, 0.8435, 0.7309, 0.595, 0.4849, 0.4003, 0.3238]
##p3 = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.9998, 0.9983, 0.9956, 0.9807, 0.9632, 0.9299, 0.9001, 0.794, 0.6844, 0.5897, 0.4932, 0.4099]

##sd = [0.1, 0.125, 0.15, 0.175, 0.2, 0.225, 0.25, 0.275, 0.3, 0.325, 0.35, 0.375, 0.4, 0.45]
##p1 = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.999, 0.9974, 0.991, 0.9854, 0.9637, 0.9468, 0.8747]
##p2 = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.9996, 0.9967, 0.9899, 0.9659, 0.9369, 0.8868, 0.8435, 0.7309]
##p3 = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.9998, 0.9983, 0.9956, 0.9807, 0.9632, 0.9299, 0.9001, 0.794]
