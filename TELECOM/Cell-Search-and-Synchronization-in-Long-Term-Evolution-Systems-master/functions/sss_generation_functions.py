from mapping_dictonary import *

def sss(N_ID1, N_ID2):
    slot0 = [ ]
    slot10 = [ ]
    (m_0, m_1) = NID1_to_m[N_ID1]
    s_0, s_1 = get_s(m_0, m_1)
    c_0, c_1 = get_c(N_ID2)
    z_0, z_1 = get_z(m_0, m_1)
    for i in range(31):
        slot0.append(s_0[i]*c_0[i])
        slot0.append(s_1[i]*c_1[i]*z_0[i])
        slot10.append(s_1[i]*c_0[i])
        slot10.append(s_0[i]*c_1[i]*z_1[i])
    return slot0, slot10

def get_s(m_0, m_1):
    s = generate_s()
    s_0, s_1 = [ ], [ ]
    for n in range(31):
        s_0.append(s[(n + m_0) % 31])
        s_1.append(s[(n + m_1) % 31])
    return s_0, s_1

def generate_s():
    s = [ ]
    x = [0,0,0,0,1]
    for i in range(0,26):
        x.append((x[i+2] + x[i]) % 2)
    for j in range(len(x)):
        s.append(1 - 2*x[j])
    return s

def get_c(N_ID2):
    c = generate_c()
    c_0, c_1 = [ ], [ ]
    for n in range(31):
        c_0.append(c[(n + N_ID2) % 31])
        c_1.append(c[(n + N_ID2 + 3) % 31])
    return c_0, c_1

def generate_c():
    c = [ ]
    x = [0,0,0,0,1]
    for i in range(0,26):
        x.append((x[i+3] + x[i]) % 2)
    for j in range(len(x)):
        c.append(1 - 2*x[j])
    return c

def get_z(m_0, m_1):
    z = generate_z()
    z_0, z_1 = [ ], [ ]
    for n in range(31):
        z_0.append(z[(n + (m_0 % 8)) % 31])
        z_1.append(z[(n + (m_1 % 8)) % 31])
    return z_0, z_1

def generate_z():
    z = [ ]
    x = [0,0,0,0,1]
    for i in range(0,26):
        x.append((x[i+4] + x[i+2] + x[i+1] + x[i]) % 2)
    for j in range(len(x)):
        z.append(1-2*x[j])
    return z
