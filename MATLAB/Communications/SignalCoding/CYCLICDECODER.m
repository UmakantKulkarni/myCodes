clc
n=input('enter n:')
k=input('enter k:')
G=input('enter generator:')
 
ec=zeros(1,n);
ec1=eye(n);
 
for i=1:(2^(n-k)-1)
 
 M=ec1(i,:);
 
 cpoly = gf(M);
 xpoly = gf(G);
 [otherpol,remd2] = deconv(cpoly,xpoly);
 ec=vertcat(ec,remd2);
 
end
 
ec1=vertcat(zeros(1,n),ec1);
display 'error correction table is'
ecfinal=horzcat(ec1,ec(:,k+1:n));
 
display(ecfinal);
  
r=input('enter received msg');
 
 cpoly = gf(r);
 xpoly = gf(G);
 [otherpol,S] = deconv(cpoly,xpoly);
 
 display 'syndrome is'
 display(S);
 
 if S==zeros(1,n)
    display 'no error in received message'
 
 else
    for j=1:n
        if(isequal(S,ec(j,:)))
           display 'error at bit'
           d=j;
           display(d-1)
           r(d-1)=(r(d-1)+1);
        end
    end
display 'corrected code word is'
R=mod(r,2)
end
