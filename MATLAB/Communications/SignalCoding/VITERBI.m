clc
msg=input('enter msg:');
%generator in octal
trellis = poly2trellis(3,[6 7])
trellis.nextStates(1:3,:)

display(' Convolution code for ip msg:') 
[code,finalstate] = convenc(msg,trellis)
catastrophic=iscatastrophic(trellis)
 
tblen=3;
 
display('correct i/p recieved:')
codev=[1 1 1 1 0 1 1 1 0 0];
decoded = vitdec(codev,trellis,tblen,'trunc','hard')
 
display('corrupted i/p recieved (1 error bit):')
codev=[1 0 1 1 0 1 1 1 0 0] 
decoded = vitdec(codev,trellis,tblen,'trunc','hard')
 
display('corrupted i/p recieved (2 error bit):')
codev=[1 1 1 1 0 0 1 1 0 1] 
decoded = vitdec(codev,trellis,tblen,'trunc','hard')

















