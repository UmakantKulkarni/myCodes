#Importing Necessary Functions from Files
from path import *
from pss_functions import cazac1, pss_error
from other_functions import dft, idft, lin_corr, sequence_amplitude, dtft, cir_corr
from graphics import PlotPSSPSD
import random
import numpy as np

N_ZC = 63 
u = [25, 29, 34]
standard_deviation = 0.1

choice = random.choice(u) #Selecting u Randomly
choice = u[2]
zc_f = cazac1(choice, N_ZC)

zc_t = idft(zc_f)

zc_t = pss_error(zc_t, standard_deviation)

zc_f0 = cazac1(u[0], N_ZC) #Selecting u = 25
zc_t0 = idft(zc_f0)
zc_f1 = cazac1(u[1], N_ZC) #Selecting u = 29
zc_t1 = idft(zc_f1)
zc_f2 = cazac1(u[2], N_ZC) #Selecting u = 34
zc_t2 = idft(zc_f2)

c1 = lin_corr(zc_t,zc_t0)
c1 = sequence_amplitude(c1)
c2 = lin_corr(zc_t,zc_t1)
c2 = sequence_amplitude(c2)
c3 = lin_corr(zc_t,zc_t2)
c3 = sequence_amplitude(c3)

x = np.linspace(-180,180,360)
sd1 = dtft(c1,x)
sd2 = dtft(c2,x)
sd3 = dtft(c3,x)    
z1 = sequence_amplitude(sd1)
z2 = sequence_amplitude(sd2)
z3 = sequence_amplitude(sd3)


l = ['u = 25', 'u = 29', 'u = 34']
t = 'PSD for PSS (u = '+str(choice)+')'

PlotPSSPSD(z1, z2, z3, x, title = t, lege = l)

