from sss_generation_functions import get_s, generate_s, get_c, generate_c
from sss_generation_functions import get_z, generate_z
from other_functions import circular_left_shift, lin_corr_real, cir_corr_real, cir_corr_real_half, lin_corr_real_half
import random

def deinterleave(signal):
    even = [ ]
    odd = [ ]
    sig_len = len(signal)
    i = 0
    while (i < sig_len):
        even.append(signal[i])
        if i==(sig_len-1): break
        odd.append(signal[i+1])
        i = i + 2
    return even, odd

def descramble_c_0(signal, N_ID2):
    output = [ ]
    c_0, c_1 = get_c(N_ID2)
    for i in range(len(signal)):
        output.append(signal[i]/c_0[i])
    return output

def descramble_z_0(signal, m_0):
    output = [ ]
    z_0, z_1 = get_z(m_0, 0)
    for i in range(len(signal)):
        output.append(signal[i]/z_0[i])
    return output

def descramble_c_1(signal, N_ID2):
    output = [ ]
    c_0, c_1 = get_c(N_ID2)
    for i in range(len(signal)):
        output.append(signal[i]/c_1[i])
    return output

def sss_error(sequence, n):
    seq = sequence[:]
    sample = range(len(seq))
    while n>0:
        n = n - 1
        index = random.choice(sample)
        sample.remove(index)
        if seq[index]<0: seq[index] = 1
        else: seq[index] = -1
    return seq

def sss_attenuate(sequence):
    seq = []
    for val in sequence:
        alpha = random.randrange(1, 31)/float(100)
        seq.append(val*alpha)        
    return seq

def sign_filter(sequence):
    seq = []
    for val in sequence:
        if (val<=0): seq.append(-1)
        else: seq.append(1)
    return seq

################################## Method 1 ##################################

def detect_m(signal):
    s = generate_s()
    if (s==signal): return 0
    else:
        for detected_m in range(1,32):
            s = circular_left_shift(s, 1)
            if (s==signal):
                return detected_m
    return -1

################################## Method 2 ##################################

def detect_m_lin_corr(signal):
    s = generate_s()
    for detected_m in range(32):
        cor = lin_corr_real(s, signal)
        if (cor[30]==max(cor)):
            return detected_m
        s = circular_left_shift(s, 1)
    return -1

################################## Method 3 ##################################

def detect_m_cir_corr(signal):
    s = generate_s()
    for detected_m in range(32):
        cor = cir_corr_real(s, signal)
        if (cor[30]==max(cor)):
            return detected_m
        s = circular_left_shift(s, 1)
    return -1

################################## Method 4 ##################################

def detect_m_pattern_offset(sequence, pattern):
    pattern_length = len(pattern)
    seq = sequence[:] + sequence[:pattern_length]
    value = 0
    while(len(seq) >= pattern_length):
        if pattern == seq[:len(pattern)]:
            if (value == 0): return value
            return (31 - value)
        value = value + 1
        seq.pop(0)
    return -1

################################## Method 5 ##################################

def detect_m_cir_corr_fast(signal, title):
    s = generate_s()
    cor = cir_corr_real_half(s, signal)
    val = max(cor)
    for i in range(len(cor)):
        if cor[i]==val: return i

################################## Method 6 ##################################

def detect_m_lin_corr_fast(signal, title):
    s = generate_s()
    cor = lin_corr_real_half(s, signal)
    val = max(cor)
    for i in range(len(cor)):
        if cor[i]==val: return i
