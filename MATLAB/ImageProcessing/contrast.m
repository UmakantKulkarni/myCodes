Contrast stretching
clc
clear all
close all
f = imread('BITP.bmp');
[rows col] = size(f);
t1 = input ('Enter value of t1: ')
t2 = input ('Enter value of t2: ')
s1 = input ('Enter value of slope-1: ')
s2 = input ('Enter value of slope-2: ')
s3 = input ('Enter value of slope-3: ')
coefft1 = s1.*t1
coefft2 = s2.*(t2-t1)+coefft1
for i = 1:rows
    for j = 1:col
        if(f(i,j)<t1)
            g(i,j)=floor(s1.*f(i,j));
        elseif (f(i,j)>t1 && f(i,j)<t2)
            g(i,j)=floor(s2.*f(i,j)+coefft1);
        elseif(f(i,j)>t2)
                g(i,j)=floor(s3.*f(i,j)-t2+coefft2);
        end;
    end;
end;
figure(1);
subplot(2,1,1);
imshow(f);
title('Original Image');
subplot(2,1,2);
imshow(g);
text=sprintf('result of contrast stretching with t1=%d,t2=%d,s1=%1.1f,s2=%1.1f,s3=%1.1f,t1,t2,s1,s2,s3');
title('text');
figure(2);
subplot(2,1,1);
imshow(f);
title('Histogram of original Image');
subplot(2,1,2);
imhist(g);
text1 = sprintf('Histogram of contrast stretching with t1=%d,t2=%d,s1=%1.1f,s2=%1.1f,s3=%1.1f,t1,t2,s1,s2,s3');
title('text1');

