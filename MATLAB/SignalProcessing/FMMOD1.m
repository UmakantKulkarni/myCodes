clc
clear all
fs=100
t=0:0.01:2
fc=12
p=sin(2*pi*fc*t)
fm=1
x=sin(2*pi*fm*t)
subplot(3,1,2)
plot(t,x)
title('Information Signal')
dev=5
y = fmmod(x,fc,fs,dev)
subplot(3,1,3)
plot(t,y)
title('Modulated Signal')
subplot(3,1,1)
plot(t,p)
title('Carrier Signal')