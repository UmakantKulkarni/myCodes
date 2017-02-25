#Importing Necessary Functions from Files
from path import *
from pss_functions import cazac1, pss_error, complex_product
from other_functions import dft, idft, complex_conj, sequence_amplitude
from graphics import PlotAmplitude, PlotComplexSequence
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
PlotComplexSequence(zc_t,1,'Received PSS (with AWGN)')

zc_f = dft(zc_t)

zc_f_conj = complex_conj(zc_f)

zc_f0 = cazac1(u[0], N_ZC)
c0 = complex_product(zc_f_conj, zc_f0)
c0 = idft(c0)
c0 = sequence_amplitude(c0)
PlotAmplitude(c0, 1, 'Product of Received PSS Conjugate with PSS (u = 25)', 'Normalized Amplitude')

zc_f1 = cazac1(u[1], N_ZC) 
c1 = complex_product(zc_f_conj, zc_f1)
c1 = idft(c1)
c1 = sequence_amplitude(c1)
PlotAmplitude(c1, 2, 'Product of Received PSS Conjugate with PSS (u = 29)', 'Normalized Amplitude')

zc_f2 = cazac1(u[2], N_ZC) 
c2 = complex_product(zc_f_conj, zc_f2)
c2 = idft(c2)
c2 = sequence_amplitude(c2)
PlotAmplitude(c2, 3, 'Product of Received PSS Conjugate with PSS (u = 34)', 'Normalized Amplitude')


print choice
