#Importing Necessary Functions from Files
from path import *
from sss_generation_functions import sss
from sss_detection_functions import *
from mapping_dictonary import *
import random

errors = 10

N_ID1 = random.randrange(168)
N_ID2 = random.randrange(3)

print 'Transmitted N_ID1 = ',N_ID1
m = NID1_to_m[N_ID1]

print 'Transmitted (m_0, m_1) = ',m

slot0, slot10 = sss(N_ID1, N_ID2)

choice = random.randrange(2)
if (choice==1):
    signal = slot0 + slot10
    subframe = 0
else:
    signal = slot10 + slot0
    subframe = 5

print '\nCurrent Subframe Index = ',subframe

signal = sss_error(signal, errors)

detected = False

one = signal[:len(signal)/2]
two = signal[len(signal)/2:]

print 'Attempting detection in Current Subframe:'
even, odd = deinterleave(one)

even_descramble = descramble_c_0(even, N_ID2)
m_e = detect_m_cir_corr(even_descramble)

if (m_e >= 0):
    print 'Detected m_e = ',m_e
    odd_descramble = descramble_c_1(descramble_z_0(odd, m_e),N_ID2)
    m_o = detect_m_cir_corr(odd_descramble)

    if (m_o >= 0):
        print 'Detected m_o = ',m_o
        if ((m_e,m_o)==m):
            subframe_index = 0
            detected = True
            print 'Detected N_ID1 = ',m_to_NID1[(m_e,m_o)]
            print 'Detected Subframe Index = ',subframe_index
            print '\nDetection Successful'
        elif ((m_o,m_e)==m):
            subframe_index = 5
            detected = True
            print 'Detected N_ID1 = ',m_to_NID1[(m_o,m_e)]
            print 'Detected Subframe Index = ',subframe_index
            print '\nDetection Successful'
            
if not detected:
    print 'Detection Failed in Current Subframe'
    print '\nAttempting detection in next Subframe:'
    even, odd = deinterleave(two)

    even_descramble = descramble_c_0(even, N_ID2)
    m_e = detect_m_cir_corr(even_descramble)

    if (m_e >= 0):
        print 'Detected m_e = ',m_e
        odd_descramble = descramble_c_1(descramble_z_0(odd, m_e),N_ID2)
        m_o = detect_m_cir_corr(odd_descramble)
        
        if (m_o >= 0):
            print 'Detected m_o = ',m_o
            if ((m_e,m_o)==m):
                subframe_index = 0
                detected = True
                print 'Detected N_ID1 = ',m_to_NID1[(m_e,m_o)]
                print 'Detected Subframe Index = ',subframe_index
                print '\nDetection Successful'
            elif ((m_o,m_e)==m):
                subframe_index = 5
                detected = True
                print 'Detected N_ID1 = ',m_to_NID1[(m_o,m_e)]
                print 'Detected Subframe Index = ',subframe_index
                print '\nDetection Successful'

if not detected: print '\nDetection Failed'
