#Importing Necessary Functions from Files
from path import *
from sss_generation_functions import sss, generate_s, NID1_to_m
from sss_detection_functions import *
from other_functions import dtft, sequence_amplitude, normalize, lin_corr_real_half, cir_corr_real_half
from graphics import PlotSSSPSD
import random
import numpy as np


errors = 15

N_ID1 = random.randrange(168)
N_ID2 = random.randrange(3)

m = NID1_to_m[N_ID1]

slot0, slot10 = sss(N_ID1, N_ID2)

signal = sss_error(slot0, errors)

x = np.linspace(-180,180,360)

###############################################LINEAR###############################################

even, odd = deinterleave(signal[:])

even_descramble = descramble_c_0(even, N_ID2)
s = generate_s()
cor = lin_corr_real_half(s, even_descramble)
y_cplx = dtft(cor, x[:])
y1 = normalize(sequence_amplitude(y_cplx))
val = max(cor)
for i in range(len(cor)):
    if cor[i]==val:
        m_e = i
        break

odd_descramble = descramble_c_1(descramble_z_0(odd, m_e),N_ID2)
s = generate_s()
cor = lin_corr_real_half(s, odd_descramble)
x = np.linspace(-180,180,360)
y_cplx = dtft(cor, x[:])
y2 = normalize(sequence_amplitude(y_cplx))
val = max(cor)
for i in range(len(cor)):
    if cor[i]==val:
        m_o = i
        break
    
title = 'PSD Linear Correlation (BER = '+str(round(float(100*errors)/len(slot0),1))+'%) m = '+str(m)
legend = ['$m_0$ = '+str(m_e),'$m_1$ = '+str(m_o)]
PlotSSSPSD(y1, y2, x[:], title, legend)

##############################################CIRCULAR##############################################

even, odd = deinterleave(signal[:])

even_descramble = descramble_c_0(even, N_ID2)
s = generate_s()
cor = cir_corr_real_half(s, even_descramble)
y_cplx = dtft(cor, x[:])
y1 = normalize(sequence_amplitude(y_cplx))
val = max(cor)
for i in range(len(cor)):
    if cor[i]==val:
        m_e = i
        break

odd_descramble = descramble_c_1(descramble_z_0(odd, m_e),N_ID2)
s = generate_s()
cor = cir_corr_real_half(s, odd_descramble)
x = np.linspace(-180,180,360)
y_cplx = dtft(cor, x[:])
y2 = normalize(sequence_amplitude(y_cplx))
val = max(cor)
for i in range(len(cor)):
    if cor[i]==val:
        m_o = i
        break
    
title = 'PSD Circular Correlation (BER = '+str(round(float(100*errors)/len(slot0),1))+'%) m = '+str(m)
legend = ['$m_0$ = '+str(m_e),'$m_1$ = '+str(m_o)]
PlotSSSPSD(y1, y2, x[:], title, legend)
