clear all

t=0:0.01:1
x=4*sin(2*pi*5*t)
y=4*sin(2*pi*5*t+(pi/2))
z=xcorr(x,y)

subplot(3,2,1)
plot(x)
title('sine wave C.T.')

subplot(3,2,2)
plot(y)
title('cosine wave C.T.')

subplot(3,2,3)
stem(x)
title('sine wave D.T.')

subplot(3,2,4)
stem(y)
title('cosine wave D.T.')

subplot(3,2,5)
plot(z)
title('crosscorrelated wave C.T.')

subplot(3,2,6)
stem(z)
title('crosscorrelated wave D.T.')