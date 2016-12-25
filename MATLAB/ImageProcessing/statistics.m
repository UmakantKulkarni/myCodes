Study of statistical properties
clc
clear all
close all
f = imread('golf.bmp');
[rows col] = size(f);
graylevels = 256;
nk = zeros (graylevels,1);
for a =0:graylevels-1
    nk(a+1) = numel(find(f==a));
end;
prof_row=52;
prof = f(prof_row,:);
figure();
subplot(2,2,1);
imshow(f);
title('Input image');
hold on;
line( [1 col],[prof_row,prof_row], 'Linewidth',2,'LineStyle','--');
hold off;
subplot (2,2,2);
plot(prof);
axis([0,col+5,0,260]);
title(sprintf('profile at line %d',prof_row));
subplot (2,2,[3 4]);
bar (nk);
axis([0 numel(nk)+10 0 max(nk)+50]);
title('Histogram of an Image');
% mean variance and sta dev are calculated using probabilistic method
zk=0:1:graylevels-1;
zk=zk';
pzk=nk./sum(nk);
m=sum(zk.*pzk);
var=sum(((zk-m).^2).*pzk);
stddev=sqrt(var);
statistical_parameters=struct('Mean',m,'Varience',var,'Standard_Deviation',stddev);
display(statistical_parameters)
