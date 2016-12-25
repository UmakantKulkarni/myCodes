clc
clear all
b=input('Enter Numerator Coefficients')
a=input('Enter Denominator Coefficients')
w=0:0.01:2*pi
h = freqz(b,a,w)
theta = angle(h)

subplot(2,1,1)
plot(w/pi, abs(h))
xlabel('Frequency')
ylabel('Amplitude')
title('Frequency Response')


subplot(2,1,2)
plot(theta)
xlabel('Angle')
ylabel('Amplitude')
title('Phase Response')

