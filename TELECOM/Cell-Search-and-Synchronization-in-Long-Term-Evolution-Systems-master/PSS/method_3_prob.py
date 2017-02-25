#Importing Necessary Functions from Files
from path import *
from pss_functions import cazac1, pss_error, complex_product
from other_functions import dft, idft, complex_conj, sequence_amplitude
import random

def method_3(num_trials, standard_deviation):
    count = 0
    N_ZC = 63 
    u = [25, 29, 34]
    
    for iteration in range(num_trials):
        choice = random.choice(u)
        zc_f = cazac1(choice, N_ZC)
        zc_t = idft(zc_f)

        zc_t = pss_error(zc_t, standard_deviation)

        zc_f = dft(zc_t)
        zc_f_conj = complex_conj(zc_f)
        
        zc_f0 = cazac1(u[0], N_ZC) 
        c0 = complex_product(zc_f_conj, zc_f0)
        c0 = idft(c0)
        c0 = sequence_amplitude(c0)
        if ((max(c0)==c0[0])and(choice==u[0])):
            count = count + 1
            continue
        
        zc_f1 = cazac1(u[1], N_ZC) 
        c1 = complex_product(zc_f_conj, zc_f1)
        c1 = idft(c1)
        c1 = sequence_amplitude(c1)
        if ((max(c1)==c1[0])and(choice==u[1])):
            count = count + 1
            continue
        
        zc_f2 = cazac1(u[2], N_ZC)
        c2 = complex_product(zc_f_conj, zc_f2)
        c2 = idft(c2)
        c2 = sequence_amplitude(c2)
        if ((max(c2)==c2[0])and(choice==u[2])):
            count = count + 1
            continue
        
    return count/float(num_trials)
