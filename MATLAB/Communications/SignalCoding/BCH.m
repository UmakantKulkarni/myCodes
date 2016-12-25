clc
n=input('enter n:')
m=log(n+1)/log(2);
k=input('enter k:');
 
[genpoly,t]=bchgenpoly(n,k);
 
display('generator polynomial is');
display(genpoly)
 
display('error correction capability is');
display(t)
 
msg=input('enter msg:');
msg=gf(msg);
 
%encode
code=bchenc(msg,n,k)
 
 
%decode
%corrupt 2 bits
coded=[0 1 0 0 0 1 1 1 0 1 0 1 0 1 0]
coded=gf(coded);
[newmsg,err,ccode]=bchdec(coded,n,k)















