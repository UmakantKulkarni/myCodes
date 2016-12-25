clc
clear all
close all
F=imread('bitp.bmp');
figure(1);
subplot(4,4,[1 8]);
imshow(F);
title('Original Image')
x=1;
for k=9:16
    subplot(4,4,k);
    imshow(logical(bitget(F,x)));
    title(['Bitplane',num2str(x),'']);
    x=x+1;
end