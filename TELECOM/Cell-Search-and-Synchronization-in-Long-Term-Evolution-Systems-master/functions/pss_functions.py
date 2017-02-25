#Importing Default Math and Complex Math files
import cmath, math, random
from other_functions import dec2bin, bin2dec, str_replace_index


################################## Generation Functions ##################################

def cazac(u, N_ZC): #Function to Generate CAZAC sequence
    ans = [ ]
    for n in range(N_ZC):
        r = 1
        phi = cmath.pi*u*n*(n+1)/N_ZC
        phi = -1*phi
        val = cmath.rect(r,phi)
        ans.append(val)
    return ans

def cazac1(u, N_ZC = 63, r = 3): #Function to Round off CAZAC sequence
    ans = [ ]
    seq = cazac(u, N_ZC)
    for i in seq:
        ans.append(complex(round(i.real,r),round(i.imag,r)))
    return ans


################################## Generation Functions ##################################

def pss_error(sequence, standard_deviation=0):
    standard_deviation = round(standard_deviation,2)
    sd = int(standard_deviation*100)
    seq = []
    for val in sequence:
        x = random.randrange(-sd, sd+1)/float(100)
        y = random.randrange(-sd, sd+1)/float(100)        
        seq.append(val + complex(x,y))
    return seq

def pss_filter(sequence):
    seq = []
    for val in sequence:
        mod = math.sqrt(val.real**2 + val.imag**2)
        seq.append(complex(round(val.real/mod,2), round(val.imag/mod,2)))
    return seq

def complex_product(sequence1, sequence2):
    seq1 = sequence1[:]
    seq2 = sequence2[:]
    return_value = [ ]
    l = len(seq1)
    for i in range(l):
        return_value.append(seq1[i]*seq2[i])
    return return_value

def pss_error_bin(sequence,num):
    seq = []
    for i in sequence:
        binary = i.split('j')
        seq.append([binary[0][3:],binary[1][3:]])
    for errors in range(num):
        a = random.randrange(63)
        b = random.randrange(2)
        c = random.randrange(3)
        if seq[a][b][c] == '0': seq[a][b] = str_replace_index(seq[a][b],c,'1')
        else: seq[a][b] = str_replace_index(seq[a][b],c,'0')
    ans = []
    for i in range(len(sequence)):
        val = str_replace_index(sequence[i], 3, seq[i][0])
        ans.append(str_replace_index(val, 22, seq[i][1]))
    return ans

def complex2bin(sequence):
    seq = sequence[:]
    ans = [ ]
    for i in seq:
        ans.append(dec2bin(i.real)+'j'+dec2bin(i.imag))
    return ans

def bin2complex(sequence):
    seq = sequence[:]
    ans = [ ]
    for i in seq:
        c = i.split('j')
        ans.append(complex(bin2dec(c[0]),bin2dec(c[1])))
    return ans
