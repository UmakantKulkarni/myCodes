clc
clear all
fs=100
t=0:0.001:2
fc=15
p=sin(2*pi*fc*t)
fm=1
x=sin(2*pi*fm*t)
subplot(3,1,2)
plot(t,x)
title('Information Signal')
dev=10
y=sin((2*pi*fc*t)+((dev*sin((2*pi*fm*t)+(3*pi/2)))/fm))
subplot(3,1,3)
plot(t,y)
title('Modulated Signal')
subplot(3,1,1)
plot(t,p)
title('Carrier Signal')