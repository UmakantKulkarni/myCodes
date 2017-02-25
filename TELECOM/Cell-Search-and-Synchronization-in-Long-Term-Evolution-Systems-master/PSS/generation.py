#Importing Necessary Functions from Files
from path import *
from other_functions import idft
from pss_functions import cazac1
from graphics import PlotComplexSequence

N_ZC = 63
u = [25, 29, 34]
approximation = 3

zc_f = cazac1(u[0], N_ZC, approximation) #Selecting u = 25
zc_t = idft(zc_f)
PlotComplexSequence(zc_f, 1, 'PSS Signal in Frequency Domain (u = 25)')

zc_f = cazac1(u[1], N_ZC, approximation) #Selecting u = 29
zc_t = idft(zc_f)
PlotComplexSequence(zc_f, 3, 'PSS Signal in Frequency Domain (u = 29)')

zc_f = cazac1(u[2], N_ZC, approximation) #Selecting u = 34
zc_t = idft(zc_f)
PlotComplexSequence(zc_f, 4, 'PSS Signal in Frequency Domain (u = 34)')
