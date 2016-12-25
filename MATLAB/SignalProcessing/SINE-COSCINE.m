subplot(2,2,1)
f=6
t= 0:0.001:1
y=sin(2*pi*f*t)
plot(t,y)
xlabel('time')
ylabel('amplitude')
title('C.T. sinewave')

subplot(2,2,2)
f=6
t= 0:0.01:1
y=sin(2*pi*f*t)
stem (t,y)
xlabel('time')
ylabel('amplitude')
title('D.T. sinewave')

subplot(2,2,3)
f=6
t= 0:0.001:1
y=cos(2*pi*f*t)
plot(t,y)
xlabel('time')
ylabel('amplitude')
title('C.T. cosinewave')

subplot(2,2,4)
f=6
t= 0:0.01:1
y=cos(2*pi*f*t)
stem(t,y)
xlabel('time')
ylabel('amplitude')
title('D.T. cosinewave')