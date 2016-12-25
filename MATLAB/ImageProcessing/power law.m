Power law

clc
clear all
close all
F=imread('ukvt2.jpg');
f1=rgb2gray(F);
c=input('enter the value of c');
gamma1=input('enter the value of gamma')
gamma2=input('enter the value of gamma')
gamma3=input('enter the value of gamma')
gamma4=input('enter the value of gamma')
G=256-f1;
h=uint8(c.*log(double(1+f1)));
subplot(2,2,1)
 i1=uint8(c.*(double(f1)).^gamma1);
 imshow(i1);
powtext=sprintf('power law operator for c=%2.1f & gamma=%0.2f',c,gamma1);
title('powtext');
subplot(2,2,2)
i2=uint8(c.*(double(f1)).^gamma2);
imshow(i2);
powtext=sprintf('power law operator for c=%2.1f & gamma=%0.2f',c,gamma2);
title('powtext');
subplot(2,2,3)
i3=uint8(c.*(double(f1)).^gamma3);
imshow(i3);

powtext=sprintf('power law operator for c=%2.1f & gamma=%0.2f',c,gamma3);
title('powtext');
subplot(2,2,4)
i4=uint8(c.*(double(f1)).^gamma4);
imshow(i4);
powtext=sprintf('power law operator for c=%2.1f & gamma=%0.2f',c,gamma4);
title('powtext');




