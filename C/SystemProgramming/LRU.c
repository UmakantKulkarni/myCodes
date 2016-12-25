#include<stdio.h>
#include<conio.h>
void main()
{
  int a[5],b[20],p=0,q=0,m=0,h,i,k,q1=1,j,u,n;
  char f='F';
  clrscr();
  printf("Enter the no of pages");
  scanf("%d",&n);
  printf("Enter %d no of pages",n);
  for(i=0;i<n;i++)
  scanf("%d",&b[i]);
  for(i=0;i<n;i++)
  {
   if(p==0)
   {
     if(q>=3)
     q=0;
     a[q]=b[i];
     q++;
     if(q1<3)
     {
       q1=q;
       }
       }
       printf("\n%d",b[i]);
       printf("\t");
       for(h=0;h<q1;h++)
       printf("%d",a[h]);
       if((p==0)&&(q<=3))
       {
	 printf("-->%c",f);
	 m++;
	 }
	 p=0;
	 if(q1==3)
	 {
	   for(k=0;k<q1;k++)
	   {
	     if(b[i+1]==a[k])
	     p=1;
	     }
	     for(j=0;j<q1;j++)
	     {
	      u=0;
	      k=i;
	      while(k>=(i-1)&&(k>=0))
	      {
	       if(b[k]==a[j])
	       u++;
	       k--;
	       }
	       if(u==0)
	       q=j;
	       }
	       }
	       else
	       {
	       for(k=0;k<q;k++)
	       {
		if(b[i+1]==a[k])
		p=1;
		}
		}
		}
		printf("\n no of faults:%d",m);
		getch();
		}

/*
       OUTPUT
Enter the no of pages7
Enter 7 no of pages 1 2 3 4 2 3 1

1       1-->F
2       12-->F
3       123-->F
4       423-->F
2       423
3       423
1       123-->F
 no of faults:5
		       */



                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
