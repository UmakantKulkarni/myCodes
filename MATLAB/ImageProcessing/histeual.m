HISTOGRAM EQUALISATION
% Histogram Equalization
clc;
clear all;
close all;
F=imread('HIGHCONT.BMP');
[rows cols]= size(F);
G=F;

%Histogram array
myhist=zeros(256,1);
for k=0:255
    for i=1:cols
        for j=1:rows
            if(F(i,j)==k)
                myhist(k+1)=myhist(k+1)+1;
            end
        end
    end
end


% Calculate CDF
cdf=zeros(256,1);
cdf(1)=myhist(1);
for k=2:256
    cdf(k)=cdf(k-1)+myhist(k);
end

%Cumulative probability
cumprob=cdf/(rows.*cols);

equhist=floor((cumprob).*255);
for i=1:cols
    for j=1:rows
        for m=0:255
            if(F(i,j)==m)
                G(i,j)=equhist(m+1);
            end
        end
    end
end

myequhist=zeros(256,1);
for i=1:cols
    for j=1:rows
        for m=0:255
            if(G(i,j)==m)
                myequhist(m+1)=myequhist(m+1)+1;
            end
        end
    end
end

%plots & figures

figure(1);
subplot(2,1,1);
imshow(F);
title('input image');
subplot(2,1,2);
bar(myhist);
title('Histogram');


figure(2);
subplot(2,1,1);
imshow(G);
title('Equalized histogram image');
subplot(2,1,2);
bar(myequhist);
title('Equalized Histogram');
