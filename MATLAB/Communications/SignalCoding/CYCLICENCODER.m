clc
n=input ('enter n:')
k=input('enter k:')
G=input('enter generator:')
dmin =n;
 
C=zeros(1,n);
 
for i=1:(2^(k)-1)
 
M=de2bi(i,k,'left-msb');
apoly = gf([1,zeros(1,n-k)]);
bpoly = gf(M);
xpoly = gf(G);
 
cpoly = conv(apoly,bpoly);
 
[otherpol,remd2] = deconv(cpoly,xpoly);
 
c=cpoly+remd2;
C=vertcat(C,c);
 
 hw=0;
 for i=1:n
     if(c(1,i)~=0) 
         hw=hw+1;
     end
 end
 
 if(dmin>hw)
     dmin=hw;
 end
 
end
 
display 'the code set and min dist is'
display(C)
display(dmin)
 
 display 'detectable errors'
 Ed=dmin-1
 display 'correctable errors'
 Ec=(dmin-1)/2


