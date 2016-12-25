#include<conio.h>
#include<stdio.h>
#include<math.h>

void main()
{
  char msg[15];
  float prob[15],selfinf[15];
  float msglen,h,r,brate;
  int i,j;
 clrscr();

   printf("\nenter the message:");
   gets(msg);
   msglen=strlen(msg);

  //for calculation of probability of bit
  for(i=0;i<msglen;i++)
  {  prob[i]=0;
     for(j=0;j<msglen;j++)
       if(strcmp(msg[i],msg[j]))  prob[i]++;

    prob[i]=1-(prob[i]/msglen);
    printf("\nprob of char %d is :%f",i,prob[i]);
  }

   //for calculation of selfinf of bit
  for(i=0;i<msglen;i++)
  {
    selfinf[i]=log10(1/prob[i])/0.301;
    printf("\nselfinf of char %d is :%f bits",i,selfinf[i]);
  }

   //for calculation of entropy
  h=0;
  for(i=0;i<msglen;i++)
    h=h+selfinf[i]*prob[i];

    printf("\nentropy is :%f bits/symbol",h);

   //for calculation of bitrate
   printf("\nenter msg rate in symbols/sec:");
   scanf("%f",&r);

   brate=r*h;
   printf("\nbit rate is :%f bps",brate);

 getch();
}




