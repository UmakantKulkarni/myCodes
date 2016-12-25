clc
n=input('enter n:');
k=input('enter k:');
pm=input('enter parity sub matrix:');
dmin=n;
p=n-k;
id=eye(k);
C=zeros(1,n); 
for j=1:2^k-1
c1=0;
c2=0;
m= de2bi(j,k,'left-msb')
c1=m*id;
c2=m*pm;
for i=1:(n-k)
    c2(1,i)=mod(c2(1,i),2);
 end
    
 c=horzcat(c1,c2);
 
 hw=0;
 for i=1:n
     if(c(1,i)~=0) 
         hw=hw+1;
     end
 end
 
 display(hw);
 
 if(dmin>hw)
     dmin=hw;
 end
 C=vertcat(C,c);
end
 display 'the code set and min dist is'
 display(C)
 display(dmin)
 display 'detectable errors'
 Ed=dmin-1
 display 'correctable errors'
 Ec=(dmin-1)/2

