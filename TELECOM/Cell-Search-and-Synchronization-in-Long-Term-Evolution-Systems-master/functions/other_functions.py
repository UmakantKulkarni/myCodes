#Importing Default Math and Complex Math files
import cmath, math, random
import numpy as np

def mod(val):
    if val>=0: return val
    else: return (-1)*val

def str_replace_index(st, i, ch):
    return (st[:i] + ch + st[i+len(ch):])

def indexof(sequence, ch):
    seq = sequence[:]
    for i in range(len(seq)):
        if seq[i]==ch: return i

def complex_conj(sequence):
    seq = sequence[:]
    ans = [ ]
    for i in seq:
        ans.append(complex(i.real,(-1)*i.imag))
    return ans

def sequence_amplitude(sequence):
    seq = sequence[:]
    return_value = [ ]
    for i in seq:
        return_value.append((i.imag*i.imag + i.real*i.real)**0.5)
    return return_value

def normalize(seq, r = 4):
    s = seq[:]
    ans = []
    m = float(max(s))
    for i in s:
        ans.append(round((i/m),r))
    return ans

def dft(seq, sign=-1): #Function to find DFT of sequence
    x = seq[:]
    N, W = len(x), [ ]
    for i in range(N):
        W.append(cmath.exp(sign*2j*cmath.pi*i/N))
    X = [ ]
    for n in range(N):
        ans = 0
        for k in range(N):
            ans = ans + W[n * k % N] * x[k]
        ans = complex(ans.real,ans.imag)
        X.append(ans)
    return X

def idft(seq): #Function to find IDFT of sequence
    X = seq[:]
    N, x = len(X), dft(X, sign=1)
    for i in range(N):
        x[i] = x[i] / float(N)
    return x

def dtft_function(x, fs=1, t0=0):
    return lambda f: np.sum(x*np.exp(-2j*np.pi*f/fs*(np.arange(len(x))-t0)))

def dtft(sequence, x = np.linspace(-180,180,360)):
    seq = sequence[:]
    dtft_fn = dtft_function(seq)
    ans = [ ]    
    for i in x:
        ans.append(dtft_fn(i))
    return ans

################################## CORRELATON ##################################

def lin_corr(seq1,seq2): #Function for Linear Correlation of two complex sequences
    x=seq1[:]
    h=seq2[:]
    ans = [ ]
    l = len(x)
    p = len(h)
    for i in range(p-1):
        x.insert(0,0)
        x.append(0)
    while (len(x)>=p):
        val = 0
        for i in range(p):
            h[i] = complex(h[i].real,(-1)*h[i].imag)
            val = val + x[i]*h[i]
        ans.append(val)
        x.pop(0)
    return ans

def cir_corr(seq1,seq2): #Function for Circular Correlation of two complex sequences
    x=seq1[:]
    y=seq1[:]
    h=seq2[:]
    ans = [ ]
    N = len(x)
    for i in range(N-1):
        x.insert(0,y[-i-1])
        x.append(y[i])
    while (len(x)>=N):
        val = 0
        for i in range(N):
            h[i] = complex(h[i].real,(-1)*h[i].imag)
            val = val + x[i]*h[i]
        ans.append(val)
        x.pop(0)
    return ans

def lin_corr_real(seq1,seq2): #Function for Linear Correlation of two real sequences
    x=seq1[:]
    h=seq2[:]
    ans = [ ]
    l = len(x)
    p = len(h)
    for i in range(p-1):
        x.insert(0,0)
        x.append(0)
    while (len(x)>=p):
        val = 0
        for i in range(p):
            val = val + x[i]*h[i]
        ans.append(val)
        x.pop(0)
    return ans

def cir_corr_real(seq1, seq2): #Function for Circular Correlation of two real sequences
    x=seq1[:]
    y=seq1[:]
    h=seq2[:]
    ans = [ ]
    N = len(x)
    for i in range(N-1):
        x.insert(0,y[-i-1])
        x.append(y[i])
    while (len(x)>=N):
        val = 0
        for i in range(N):
            val = val + x[i]*h[i]
        ans.append(val)
        x.pop(0)
    return ans

def cir_corr_real_half(seq1, seq2): #Function for Circular Correlation of two real sequences half output
    x=seq1[:]
    y=seq1[:]
    h=seq2[:]
    ans = [ ]
    N = len(x)
    for i in range(N-1):
        x.append(y[i])
    while (len(x)>=N):
        val = 0
        for i in range(N):
            val = val + x[i]*h[i]
        ans.append(val)
        x.pop(0)
    return ans

def lin_corr_real_half(seq1, seq2): #Function for Linear Correlation of two real sequences half output
    x=seq1[:]
    h=seq2[:]
    ans = [ ]
    p = len(h)
    for i in range(p-1):
        x.append(0)
    while (len(x)>=p):
        val = 0
        for i in range(p):
            val = val + x[i]*h[i]
        ans.append(val)
        x.pop(0)
    return ans

################################## DECIMAL TO BINARY ##################################

def dec2bin(number, precision = 3):
    if (number == 1)or(number == -1):
        st = '0.'
        for i in range(precision):
            st = st[:] + '1'
        if number == 1: return('+' + st[:])
        return('-' + st[:])
    f = mod(number)
    if f >= 1:
        g = int(math.log(f, 2))
    else:
        g = -1
    h = g + 1
    ig = math.pow(2, g)
    st = ''    
    while f > 0 or ig >= 1: 
        if f < 1:
            if len(st[h:]) >= precision:
                   break
        if f >= ig:
            st += '1'
            f -= ig
        else:
            st += '0'
        ig /= 2
    st = st[:h] + '.' + st[h:]
    if st[0]=='.': st = '0' + st[:]
    if st[-1]=='.': st = st[:] + '0'
    if len(st) < (precision + 2):
        for i in range(precision + 2 - len(st)):
            st = st[:] + '0'
    if number  >= 0: st = '+' + st[:]
    else: st = '-' + st[:]
    return st 

def bin2dec(binary):
    b = binary[1:]
    f = b.split('.')
    val = 0.0
    integer = f[0]
    l_int = len(integer)
    for i in range(l_int):
        val = val + int(integer[i])*2**(l_int -i -1)
    fraction = f[1]
    l_frac = len(fraction)
    for i in range(l_frac):
        val = val + float(fraction[i])*2.0**(-i -1)
    if binary[0]=='+': return round(val,3)
    else: return (-1)*round(val,3)

def circular_left_shift(sequence,n):
    seq = sequence[:]
    for i in range(n):
        temp = seq.pop(0)
        seq.append(temp)
    return seq

def circular_right_shift(sequence,n):
    seq = sequence[:]
    for i in range(n):
        temp = seq.pop()
        seq.insert(0,temp)
    return seq
