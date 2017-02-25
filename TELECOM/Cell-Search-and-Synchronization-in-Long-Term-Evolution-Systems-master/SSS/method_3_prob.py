#Importing Necessary Functions from Files
from path import *
from sss_generation_functions import sss
from sss_detection_functions import *
from mapping_dictonary import *
import random

def method_3_prob(errors,trials):
    count = 0
    for trial in range(trials):
        N_ID1 = random.randrange(168)
        N_ID2 = random.randrange(3)

        subframe = 0

        m = NID1_to_m[N_ID1]

        slot0, slot10 = sss(N_ID1, N_ID2)

        choice = random.randrange(2)
        if (choice==1):
            signal = slot0 + slot10
        else:
            signal = slot10 + slot0
            subframe = 5

        signal = sss_error(signal, errors)

        detected = False

        one = signal[:len(signal)/2]
        two = signal[len(signal)/2:]

        even, odd = deinterleave(one)

        even_descramble = descramble_c_0(even, N_ID2)

        m_e = detect_m_cir_corr(even_descramble)

        if (m_e >= 0):
            odd_descramble = descramble_c_1(descramble_z_0(odd, m_e),N_ID2)

            m_o = detect_m_cir_corr(odd_descramble)
            
            if (m_o >= 0):
                if ((m_e,m_o)==m)or((m_0,m_e)==m):
                    detected = True
                    count = count + 1
        if not detected:
            even, odd = deinterleave(two)

            even_descramble = descramble_c_0(even, N_ID2)

            m_e = detect_m_cir_corr(even_descramble)

            if (m_e >= 0):
                odd_descramble = descramble_c_1(descramble_z_0(odd, m_e),N_ID2)

                m_o = detect_m_cir_corr(odd_descramble)
                
                if (m_o >= 0):
                    if ((m_e,m_o)==m)or((m_0,m_e)==m):
                        detected = True
                        count = count + 1
    probability = float(count)/trials
    return probability
