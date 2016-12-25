clear all;
u=input('Enter the values');
v=input('Enter the values');
x=conv(u,v)
subplot(2,1,1)
plot(x)
title('C.T. Convolution')

subplot(2,1,2)
stem(x)
title('D.T. Convolution')


