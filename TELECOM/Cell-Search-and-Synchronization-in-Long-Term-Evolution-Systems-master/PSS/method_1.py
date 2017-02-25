#Importing Necessary Functions from Files
from path import *
from pss_functions import cazac1, pss_error
from other_functions import dft, idft, lin_corr, sequence_amplitude
from graphics import PlotCorrelation, PlotComplexSequence
import random

N_ZC = 63 
u = [25, 29, 34]
standard_deviation = 0.1

choice = random.choice(u) #Selecting u Randomly

zc_f = cazac1(choice, N_ZC)
PlotComplexSequence(zc_f,1,'Generated PSS')

zc_t = idft(zc_f)
PlotComplexSequence(zc_t,2,'Transmitted PSS in Time Domain')


zc_t = pss_error(zc_t, standard_deviation)
PlotComplexSequence(zc_t,3,'Received PSS (with AWGN)')

zc_f0 = cazac1(u[0], N_ZC) #Selecting u = 25
zc_t0 = idft(zc_f0)
zc_f1 = cazac1(u[1], N_ZC) #Selecting u = 29
zc_t1 = idft(zc_f1)
zc_f2 = cazac1(u[2], N_ZC) #Selecting u = 34
zc_t2 = idft(zc_f2)


c1 = lin_corr(zc_t,zc_t0)
c1 = sequence_amplitude(c1)
PlotCorrelation(c1, 4, 'Circular Correlation of Received PSS signal with PSS (u = 25)', 'Circular Correlation')

c2 = lin_corr(zc_t,zc_t1)
c2 = sequence_amplitude(c2)
PlotCorrelation(c2, 5, 'Circular Correlation of Received PSS signal with PSS (u = 29)', 'Circular Correlation')

c3 = lin_corr(zc_t,zc_t2)
c3 = sequence_amplitude(c3)
PlotCorrelation(c3, 6, 'Circular Correlation of Received PSS signal with PSS (u = 34)', 'Circular Correlation')

print choice
