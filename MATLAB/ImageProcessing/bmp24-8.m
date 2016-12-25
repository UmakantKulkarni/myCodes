Study of BMP file format and Conversion of 24 bit color image to 8 bit image

clc
clear all
close all
f = imread('uk2.bmp')
[m n] = size(f)
whos f
p = size(f,2)
figure
imshow(f)
title('Original 24 bit Image')
bw = rgb2gray(f);
figure
imshow(bw)
title('Gray Scale Image')
pk = im2bw(f)
figure
imshow(pk)
title('8 bit Image')

