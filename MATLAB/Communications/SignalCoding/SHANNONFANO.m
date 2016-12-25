
%Program to code and decode the given message using shannon fano coding

clc;
clear all;
close all;
s=struct('messages','probability')
ln=input('Enter the number of symbols')
for i=1:ln
     s(i).messages=input('Enter the name')
     s(i).probability=input('Enter probability')
end
p=0;
for i=1:1:ln
    p=s(i).probability+p
end
if(p~=1)
        fprintf('The probabilites are not valid')
        break;
else
   for i=1:1:ln-1
        for j=2:1:ln
            k=j-1;
            if(s(j).probability>s(k).probability)
                m=s(j);
                s(j)=s(k);
                s(k)=m;
            end
        end
   end   
   for i=1:ln
    fprintf('\n%s has probability of%d',s(i).messages,s(i).probability)
   end
   num5=1;
   num4=ln-1;
while(num5<=(ln-1))
arr=ones(1,num4);
k=0;
l=1;
    for i=num5:ln-1
        k=s(i).probability+k;
        sum=0;
        for j=i+1:ln
            sum=sum+s(j).probability;
        end
            if((sum-k)<0)
                x=k-sum;
            else
                x=sum-k;
            end
        arr(l)=x;
        l=l+1;
    end
a=min(arr);
for i=1:ln-1
    if(arr(i)==a)
        num3=i;
    end
end
tf=isfield(s,'code');
if(tf==0)
    for j=1:num3
        s(j).code=0;
        s(j).lengthc=1;
    end
    for j=num3+1:ln
        s(j).code=1;
        s(j).lengthc=1;
    end
else
    for j=num5:num5+num3-1
        s(j).code=((s(j).code)*2)+0;
        s(j).lengthc=(s(j).lengthc)+1;
    end
    for j=num3+num5:ln
        s(j).code=((s(j).code)*2)+1;
        s(j).lengthc=(s(j).lengthc)+1;
    end
end
num6=num5
num5=num5+num3
if((num3>1))
    arr=ones(1,num4);
k=0;
l=1;
    
    for i=num6:num6+num3-2
        k=s(i).probability+k;
        sum=0;
        for j=i+1:num5-1
            sum=sum+s(j).probability;
        end
            if((sum-k)<0)
                x=k-sum;
            else
                x=sum-k;
            end
        arr(l)=x;
        l=l+1;
    end
a=min(arr);
for i=1:ln-1
    if(arr(i)==a)
        num7=i;
    end
end
    for j=num6:num6+num7-1
        s(j).code=((s(j).code)*2)+0;
        s(j).lengthc=(s(j).lengthc)+1;
    end
    for j=num6+num7:num5-1
        s(j).code=((s(j).code)*2)+1;
        s(j).lengthc=(s(j).lengthc)+1;
    end
end
end
end
i=1;
    while(i<ln)
    j=i+1 ;
    if(s(i).code==s(j).code)
       s(i).code=((s(i).code)*2)+0;
       s(i).lengthc=(s(i).lengthc)+1;
       s(j).code=((s(j).code)*2)+1;
       s(j).lengthc=(s(j).lengthc)+1;    
    end
    i=i+2;
    end
for i=1:ln
    fprintf('\n%d\t%d',s(i).code,s(i).lengthc)
end
for i=1:ln
    j=s(i).lengthc;
    while(j>=1)
        s(i).codeb(j)=mod((s(i).code),2);
        s(i).code=floor((s(i).code)/2);
    j=j-1;
    end
end
for i=1:ln
      fprintf('\n%sis coded as ',s(i).messages')
    for j=1:s(i).lengthc
        fprintf('%d',s(i).codeb(j))
    end
end

%finding  source entropy
h=0;
for i=1:ln
    h=h-((s(i).probability)*log2(s(i).probability));
end
fprintf('\nThe source entropy is%f bits/symbol',h)
l=0;
for i=1:ln
    l=l+((s(i).probability)*(s(i).lengthc));
end
fprintf('\nThe average code word length is%f bits/symbol',l)
e=((h)/l)*100;
fprintf('\nEfficiency is%f',e)


%Decoder for shannon fano code
fprintf('\n');
seq=input('Enter the bit stream')
fprintf('\n');
i=1;
 decode=seq(i);
while (i<=length(seq))
    for j=1:length(s)
        if(decode==bi2de(s(j).codeb,'left-msb'))
        fprintf('\n%s',s(j).messages)
        decode=0;
        break;
        end
    end
        if(i>=length(seq))
        break;
        end
        decode=(2*decode+seq(i+1))
i=i+1;
end

%Output:
% m2is coded as 0
% m7is coded as 100
% m1is coded as 101
% m3is coded as 1100
% m5is coded as 1101
% m6is coded as 1110
% m4is coded as 1111
% The source entropy is2.362103 bits/symbol
% The average code word length is2.400000 bits/symbol
% Efficiency is98.420962
% Enter the bit stream[0 1 0 0 1 1 0 0]
%Decoded sequence:
% m2
% m7
% m3
        
    


