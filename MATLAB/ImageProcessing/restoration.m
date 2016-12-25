Creating noisy image and filtering using MATLAB. 12



close all;
clc;
a=imread('bwduck.bmp');
a1=imnoise(a,'salt & pepper');
a2=imnoise(a,'gaussian');
figure(1);
subplot(1,3,1);
imshow(a);
title('original image');
subplot(1,3,2);
imshow(a1);
title('salt & pepper noise');
subplot(1,3,3);
imshow(a2);
title('gaussian noise');
i=fspecial('gaussian');
K=imfilter(medfilt2(a2,[3 3]),i);
J=imfilter(medfilt2(a1,[3 3]),i);
figure(2)
subplot(1,2,1);
imshow(K);
title(' Median filtered & Gaussian filtered of a2');
subplot(1,2,2);
imshow(J);
title(' Median filtered & Gaussian filtered of a1');
 

