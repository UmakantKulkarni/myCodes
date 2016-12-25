subplot(2,2,1)
t=0:0.001:10
y=square(t,50)
plot(t,y)
xlabel('time')
ylabel('Amplitude')
title('C.T.Square waveform')

subplot(2,2,2)
t=0:1:10
y=square(t,50)
stem(t,y)
xlabel('time')
ylabel('Amplitude')
title('D.T.Square waveform')

subplot(2,2,3)
t=0:0.1:10
y=exp(t)
plot(t,y)
xlabel('time')
ylabel('Amplitude')
title('C.T.Exponential waveform')

subplot(2,2,4)
t=0:1:10
y=exp(t)
stem(t,y)
xlabel('time')
ylabel('Amplitude')
title('D.T.Exponential waveform')





