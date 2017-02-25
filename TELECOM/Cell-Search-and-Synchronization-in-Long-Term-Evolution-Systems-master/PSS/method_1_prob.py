#Importing Necessary Functions from Files
from path import *
from pss_functions import cazac1, pss_error
from other_functions import dft, idft, lin_corr, sequence_amplitude
import random

def method_1(num_trials, standard_deviation):
    count = 0
    N_ZC = 63 
    u = [25, 29, 34]
    
    for iteration in xrange(num_trials):
        choice = random.choice(u)
        zc_f = cazac1(choice, N_ZC)
        zc_t = idft(zc_f)

        zc_t = pss_error(zc_t, standard_deviation)
        
        zc_f0 = cazac1(u[0], N_ZC) 
        zc_t0 = idft(zc_f0)
        cor1 = lin_corr(zc_t,zc_t0)
        cor1 = sequence_amplitude(cor1)
        if ((max(cor1)==cor1[62])and(choice==u[0])):
            count = count + 1
            continue
        
        zc_f1 = cazac1(u[1], N_ZC) 
        zc_t1 = idft(zc_f1)
        cor2 = lin_corr(zc_t,zc_t1)
        cor2 = sequence_amplitude(cor2)
        if ((max(cor2)==cor2[62])and(choice==u[1])):
            count = count + 1
            continue
        
        zc_f2 = cazac1(u[2], N_ZC)
        zc_t2 = idft(zc_f2)
        cor3 = lin_corr(zc_t,zc_t2)
        cor3 = sequence_amplitude(cor3)
        if ((max(cor3)==cor3[62])and(choice==u[2])):
            count = count + 1
            continue
        
    return count/float(num_trials)
