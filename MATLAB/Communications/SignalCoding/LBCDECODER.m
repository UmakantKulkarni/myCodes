clc
n=input('enter n:');
k=input('enter k:');
pm=input('enter parity sub matrix:');
H=horzcat(pm.',eye(n-k))
ec1=vertcat(zeros(1,n),eye(n))
ec2=vertcat(zeros(1,n-k),H.')
ec=horzcat(ec1,ec2)
r=input('enter recieved msg')
S=mod(r*H.',2)
if S==zeros(1,n-k)
    display 'no error in received message'
else
display 'error at bit'
d=find(ismember(ec2,S,'rows'));
display(d-1)
r(d-1)=(r(d-1)+1);
display 'corrected code word is'
R=mod(r,2)
End
