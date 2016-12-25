Sobel Filter

clc;
clear all;
close all;
F=double(imread('BWDUCK.BMP'));
H=F;
I=F;
J=F;
[rows cols]=size(F);
Sx=[-1,-2,-1;0,0,0;1,2,1];
Sy=Sx';
Sxy=Sy+Sx;

G1=zeros(3,3);
G2=zeros(3,3);
G3=zeros(3,3);
for i=2:1:rows-1
for j=2:1:cols-1
    
    for k=-1:1
        for l=-1:1
            G1(k+2,l+2)=F(i+k,j+l)*Sx(k+2,l+2);
            G2(k+2,l+2)=F(i+k,j+l)*Sy(k+2,l+2);
            G3(k+2,l+2)=F(i+k,j+l)*Sxy(k+2,l+2);
        end
    end
    H(i,j)=sum(sum(G1));
    I(i,j)=sum(sum(G2));
    J(i,j)=sum(sum(G3));
end
end
H=uint8(round(H-1));
I=uint8(round(H-1));
J=uint8(round(H-1));
figure()
subplot(2,2,1);
imshow(uint8(F));
title('Original image');

subplot(2,2,2);
imshow(H);
title('Sobel horizontal');

subplot(2,2,3);
imshow(I);
title('Sobel vertical');

subplot(2,2,4);
imshow(J);
title('Sobel combined');


