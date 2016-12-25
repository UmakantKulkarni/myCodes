Roberts Edge Detector

clc;
clear all;
close all;
I=imread('BWDUCK.bmp');
I=im2double(I);
J=zeros(size(I));
K=J;
L=J;
hx=[+1 0;0 -1];
hy=[0 +1;-1 0];
hxy=hx+hy;
[rows cols]=size(I);
for i=1:rows-1
    for j=1:cols-1

G1=zeros(2,2);
G2=zeros(2,2);
G3=zeros(2,2);


    
    for k=1:2
        for l=1:2
            G1(k,l)=hx(3-k,3-l).*I(i+k-1,j+l-1);
            J(i,j)=sum(sum(G1));
            
            G2(k,l)=hy(3-k,3-l).*I(i+k-1,j+l-1);
            K(i,j)=sum(sum(G2));
            
            G3(k,l)=hxy(3-k,3-l).*I(i+k-1,j+l-1);
            L(i,j)=sum(sum(G3));
        end;
    end;
    end;
end;
            
   
    

figure()
subplot(2,2,1);
imshow(I);
title('Original image');

subplot(2,2,2);
imshow(J);
title('roberts mask hx=[1 0;0 -1]');

subplot(2,2,3);
imshow(K);
title('roberts mask hy=[0,1;-1 0]');



subplot(2,2,4);
imshow(L);
title('roberts mask hxy=hx+hy=[1,1,-1,-1]');

