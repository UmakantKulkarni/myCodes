#Importing Necessary Functions from Files
from path import *
from sss_generation_functions import sss
from sss_detection_functions import *
from mapping_dictonary import *
from graphics import PlotSubcarrierIndex
import random

N_ID1 = random.randrange(168)
N_ID2 = random.randrange(3)

print 'Transmitted N_ID1 = ',N_ID1

print 'Transmitted (m_0, m_1) = ',NID1_to_m[N_ID1]

slot0, slot10 = sss(N_ID1, N_ID2)
PlotSubcarrierIndex(slot0,1,'Transmitted SSS (in slot 0)')
PlotSubcarrierIndex(slot10,1,'Transmitted SSS (in slot 10)')

slot0_attenuate = sss_attenuate(slot0)
PlotSubcarrierIndex(slot0_attenuate,1,'Received SSS (in slot 0)')

PlotSubcarrierIndex(slot0,1,'$y_{sss}(n)$')

even, odd = deinterleave(slot0)
PlotSubcarrierIndex(even,1,'$y_{sss}(2n)$')
PlotSubcarrierIndex(odd,1,'$y_{sss}(2n+1)$')

even_descramble = descramble_c_0(even, N_ID2)
PlotSubcarrierIndex(even_descramble,1,'$S_{0}(n)$')
m_e = detect_m(even_descramble)

if m_e >= 0:
    print '\nDetected m_e = ', m_e

    odd_descramble = descramble_c_1(descramble_z_0(odd, m_e),N_ID2)
    PlotSubcarrierIndex(odd_descramble,1,'$S_{1}(n)$')
    m_o = detect_m(odd_descramble)
    
    if m_o >=0:
        print 'Detected m_o = ', m_o
        
        if ((m_e,m_o)==NID1_to_m[N_ID1]):
            print '\nDetected N_ID1 = ',m_to_NID1[(m_e,m_o)]
                        
    else: print '\nDetection of m_1 Failed'
else: print '\nDetection of m_0 Failed'

