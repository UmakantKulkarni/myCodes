Prewitt's Operator
 
clear all;
clc;
im=imread('C:\\Documents and Settings\\Administrator\\Desktop\\IMAGES\\highcont.bmp');
a=double(im);
[row col]=size(a);
w1=[-1 0 1 ; -1 0 1 ; -1 0 1];
w2=[-1 -1 -1 ; 0 0 0 ; 1 1 1];
for x=2:1:row-1
    for y=2:1:col-1
        a1(x,y)=0;
        a2(x,y)=0;
        for i=-1:1 
            for j=-1:1
                a1(x,y)=a1(x,y)+w1(i+2,j+2)*a(x+i,y+j);
                a2(x,y)=a2(x,y)+w2(i+2,j+2)*a(x+i,y+j);
            end
        end
    end
end
a3=a1+a2;
figure(1)
imshow(uint8(im))
title('original image');
figure(2)
imshow(uint8(a1))
title('X-Gradient image using Prewitts Mask_1');
figure(3)
imshow(uint8(a2))
title('Y-Gradient image using Prewitts Mask_2');
figure(4)
imshow(uint8(a3))
title('Final Gradient Image');
 













