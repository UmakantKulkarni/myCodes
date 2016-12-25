DCT IDCT

clc;
clear all;
A=imread('guitar.bmp');
B=dct2(A);
C=B;
th=30;
C(abs(C)<th)=0;
D=idct2(C);
D=uint8(D);
figure()
subplot(2,2,1)
imshow(A)
title('Original Image')
subplot(2,2,2)
imshow(C)
title(sprintf('DCT Coefficient Thresholded at %D',th ));
subplot(2,2,3)
imshow(D)
title('IDCT of image afther thresholding smaller coefficient');


