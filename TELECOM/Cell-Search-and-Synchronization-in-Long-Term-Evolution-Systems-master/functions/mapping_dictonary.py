def indices(N_ID1):
    q_dash = N_ID1/30
    q = (N_ID1 + q_dash*(q_dash + 1)/2)/30
    m_dash = N_ID1 + q*(q + 1)/2
    m_0 = m_dash % 31
    m_1 = (m_0 + (m_dash/31) + 1) % 31
    return m_0, m_1

m_to_NID1 = { }
NID1_to_m = { }

for i in range(168):
    m_0, m_1 = indices(i)
    m_to_NID1[(m_0, m_1)] = i
    NID1_to_m[i] = (m_0, m_1)




