import pylab, math
import numpy as np

##    color codes-
##    b: blue
##    g: green
##    r: red
##    c: cyan
##    m: magenta
##    y: yellow
##    k: black
##    w: white

def circle(center, rad):
    axes = pylab.axes()
    circle = pylab.Circle((center[0], center[1]), radius=rad, color='b',fill=False,ls='dashed')
    axes.add_patch(circle)
    

def PlotComplexSequence(seq, plot_number = 1, title = ''):
    x = [ ]
    y = [ ]
    for i in seq:
        x.append(i.real)
        y.append(i.imag)

    pylab.figure(plot_number)
    pylab.scatter(x,y, color = 'r', marker = 'o')
    circle((0,0),1)
    pylab.grid()
    pylab.title(title)
    pylab.xlabel('Real Part')
    pylab.ylabel('Imaginary Part')
    pylab.show()

def PlotSubcarrierIndex(seq, plot_number = 1, title = ''):
    N_ZC = len(seq)
    y = [ ]
    for i in seq:
        y.append(i)
    pylab.figure(plot_number)
    z = pylab.linspace(0,N_ZC-1,N_ZC)
    y_zero=[ ]
    for val in z:
        y_zero.append(0)
    pylab.scatter(z, y, marker = 'o', color='b')
    pylab.vlines(z,y_zero,y, color='b')
    pylab.plot([0, N_ZC-1],[0, 0], color='k')
    pylab.plot([0, 0] ,[-1, 1], color='k')
    pylab.grid()
    pylab.title(title)
    pylab.xlabel('SubCarrier Index')
    pylab.ylabel('Amplitude')
    pylab.show()

def PlotCorrelation(seq, plot_number = 1, title = '', y_label = ''):
    max_val = float(max(seq))
    min_val = min(seq)
    x = [ ]
    y = [ ]
    val = -(len(seq)/2)
    for i in seq:
        x.append(val)
        y.append(i/max_val)
        val = val + 1
    pylab.figure(plot_number)
    pylab.scatter(x,y, color = 'r', marker = 'o')
    pylab.plot([-len(x)/2,len(x)/2],[0,0], color='b')           #Axes
    pylab.plot([0,0],[1,0], color='b') 
    pylab.grid()
    pylab.title(title)
    pylab.xlabel('Time Lag')
    pylab.ylabel(y_label)
    pylab.show()

def PlotCorrelationNew(seq, plot_number = 1, title = '', y_label = ''):
    max_val = float(max(seq))
    min_val = min(seq)
    x = [ ]
    y = [ ]
    for i in range(len(seq)):
        x.append(i)
        y.append(seq[i]/max_val)
    pylab.figure(plot_number)
    pylab.scatter(x,y, color = 'r', marker = 'o')
    pylab.plot([0,len(x)],[0,0], color='b')           #Axes
    pylab.plot([0,0],[1,min(y)], color='b') 
    pylab.grid()
    pylab.title(title)
    pylab.xlabel('Time Lag')
    pylab.ylabel(y_label)
    pylab.show()

def PlotAmplitude(seq, plot_number = 1, title = '', y_label = ''):
    max_val = float(max(seq))
    min_val = min(seq)
    x = [ ]
    y = [ ]
    val = 0
    for i in seq:
        x.append(val)
        y.append(i/max_val)
        val = val + 1
    pylab.figure(plot_number)
    pylab.scatter(x,y, color = 'r', marker = 'o')
    pylab.plot([0,len(x)],[0,0], color='b')           #Axes
    pylab.plot([0,0],[1,0], color='b') 
    pylab.grid()
    pylab.title(title)
    pylab.xlabel('Time Argument')
    pylab.ylabel(y_label)
    pylab.show()

def PlotSSSProbability(p1, p2, p3, indices, plot_number = 1, title = '', lege = []):
    pylab.figure(plot_number)
    pylab.plot(indices, p1, color = 'b', marker = 'o')
    if len(p2)!=0: pylab.plot(indices, p2, color = 'r', marker = '*')
    if len(p3)!=0: pylab.plot(indices, p3, color = 'g', marker = '.')
    if len(lege)!=0: pylab.legend(lege,3)
    #pylab.plot([0],[1.001], color = 'w')
    pylab.grid()
    pylab.title(title)
    pylab.xlabel('Bit Error Rate (Percentage)')
    pylab.ylabel('Probability of Detection')
    pylab.show()

def PlotPSSProbabilityDetection(p1, p2, p3, indices, plot_number = 1, title = '', lege = []):
    x = []
    pylab.figure(plot_number)
    for i in indices:
        x.append(10*math.log10(1/float(i)))
    pylab.plot(x, p1, color = 'b', marker = 'o')
    if len(p2)!=0: pylab.plot(x, p2, color = 'r', marker = '*')
    if len(p3)!=0: pylab.plot(x, p3, color = 'g', marker = '.')
    #pylab.plot([max(x)], [1.01], color = 'w')
    if len(lege)!=0: pylab.legend(lege,4)
    pylab.grid()
    pylab.title(title)
    pylab.xlabel('SNR (dB)')
    pylab.ylabel('Probability of Detection')
    pylab.show()

def PlotPSSProbabilityFailure(p1, p2, p3, indices, plot_number = 1, title = '', lege = []):
    x = []
    y1 = []
    y2 = []
    y3 = []
    pylab.figure(plot_number)
    for i in range(len(indices)):
        x.append(10*math.log10(1/float(indices[i])))
        y1.append(1-p1[i])
        if len(p2)!=0: y2.append(1-p2[i])
        if len(p3)!=0: y3.append(1-p3[i])
    pylab.plot(x, y1, color = 'b', marker = 'o')
    if len(p2)!=0: pylab.plot(x, y2, color = 'r', marker = '*')
    if len(p3)!=0: pylab.plot(x, y3, color = 'g', marker = '.')
    if len(lege)!=0: pylab.legend(lege,1)
    pylab.grid()
    pylab.title(title)
    pylab.xlabel('SNR (dB)')
    pylab.ylabel('Probability of Failure')
    pylab.show()

def PlotPSSPSD(sd1, sd2, sd3, x = np.linspace(-180,180,360), title = 'PSD', lege = ''):
    pylab.plot(x,sd1, color = 'b')
    pylab.plot(x,sd2, color = 'r')
    pylab.plot(x,sd3, color = 'g')
    if len(lege)!=0: pylab.legend(lege)
    pylab.grid()
    pylab.title(title)
    pylab.xlabel('Angular Frequency')
    pylab.ylabel('Amplitude')
    pylab.show()

def PlotSSSPSD(y1, y2, x = np.linspace(-180,180,360), title = 'PSD', lege = ''):
    pylab.plot(x,y1)
    pylab.plot(x,y2)
    pylab.scatter([0],[1.1],color = 'w')
    if len(lege)!=0: pylab.legend(lege,'')
    pylab.grid()
    pylab.title(title)
    pylab.xlabel('Angular Frequency')
    pylab.ylabel('Normalized Amplitude')
    pylab.show()
