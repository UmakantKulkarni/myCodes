clc;
clear all;
close all;
p=input('Enter the probabilites')
n=length(p);
a=0;
for i=1:n
    a=a+p(i)
end
fprintf('%d',a)
n=length(p);
[psort pord]=sort(p)
q=p;
for i=1:n-1
    [q l]=sort(q)
    m(i,:)=[l(1:n-i+1),zeros(1,i-1)]
    q=[q(1)+q(2),q(3:end)]
end
cword=blanks(n^2)
cword(n)='0'
cword(2*n)='1'
for i1=1:n-2
    ctemp=cword
    idx0=find(m(n-i1,:)==1)*n
    cword(1:n)=[ctemp(idx0-n+2:idx0) '0']
    cword(n+1:2*n)=[cword(1:n-1) '1']
    for i2=2:i1+1
        idx2=find(m(n-i1,:)==i2)
        cword(i2*n+1:(i2+1)*n)=ctemp(n*(idx2-1)+1:n*idx2)
    end
end
for i=1:n
    idx1=find(m(1,:)==i)
    huffcode(i,1:n)=cword(n*(idx1-1)+1:idx1*n)
end
%calculate entropy
entropy=0;
for i=1:n
    entropy=-[p(i)*log2(p(i))]+entropy;
end
display(['symbol','-->','codeword','','  probability']);
for i=1:n
    codeword_length(i)=n-length(find(abs(huffcode(i,:))==32));
    display(['x',num2str(i),'-->',huffcode(i,:),'          ',num2str(p(i))]);
end
avg_length=0;
for i=1:n
    avg_length=avg_length+(p(i)*codeword_length(i));
end
display(['entropy=',num2str(entropy),'bits/symbol'])
 display(['average code word length=',num2str(avg_length),'bits/symbol'])
