Median Filter
clc;
clear all;
close all;
path='IC.JPG';
I=imread(path);
H=I;
x=imfinfo(path);
cols=x.Width;
rows=x.Height;
mask_size=input('enter the value of mask size \n value must be an odd integer between 3 & 25:=');
if(mask_size<=25 && mod(mask_size,2)==1 && mask_size>=3)
    midx=floor(mask_size/2);
    for i=1+midx:rows-midx
        for j=1+midx:cols-midx
            G=zeros(mask_size,mask_size);
            for k=-midx:midx
                for l=-midx:midx
                    G(midx+k+1,midx+l+1)=I(i+k,j+l);
                end
            end
            G=reshape(G,mask_size*mask_size,1);
            H(i,j)=median(G);
        end
    end
    figure();
    subplot(1,2,1);
    imshow(I);
    title('input image');
    subplot(1,2,2);
    imshow(H);
    title(sprintf('output image with mask_size=%d',mask_size));
else
    display('invalid');
end
