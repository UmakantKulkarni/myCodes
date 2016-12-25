Negation
clc
clear all
close all
f=rgb2gray(imread ('ukvt2.jpg'));
c=input('Enter the value of C')
gamma=input('Enter the value of Gamma')
G=256-f
H=uint8(c.*log(double(1+f)));
I=uint8(c.*(double(f)).^gamma);
subplot(2,2,1)
imshow(f)
title('Original image');
subplot(2,2,2)
imshow(G)
title('Negative image');
subplot(2,2,3)
imshow(H)
logtext=sprintf('logarithmic operator for c=%2.1f and gamma=%0.2f',c,gamma');
title(logtext);
subplot(2,2,4)
imshow(I)
powtext=sprintf('power law operator for c=%2.1f and gamma=%0.2f',c,gamma);
title('powtext');
% output
% Enter the value of C50
% Enter the value of Gamma.2
