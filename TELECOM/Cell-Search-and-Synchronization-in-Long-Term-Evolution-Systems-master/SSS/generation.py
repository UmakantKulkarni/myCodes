#Importing Necessary Functions from Files
from path import *
from sss_generation_functions import sss
from graphics import PlotSubcarrierIndex
import random

N_ID1 = random.randrange(168)
N_ID2 = random.randrange(3)

slot0, slot10 = sss(N_ID1, N_ID2)

PlotSubcarrierIndex(slot0,1,'Slot 0 SSS with ${N_{ID}}^{(1)}$ = '+str(N_ID1)+' and ${N_{ID}}^{(2)}$ = '+str(N_ID2))
PlotSubcarrierIndex(slot10,2,'Slot 10 SSS with ${N_{ID}}^{(1)}$ = '+str(N_ID1)+' and ${N_{ID}}^{(2)}$ = '+str(N_ID2))
