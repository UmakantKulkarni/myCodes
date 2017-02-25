import sys
l = len(sys.path[0])
sys.path.insert(0, sys.path[0][:(l-4)]+'\\functions')
