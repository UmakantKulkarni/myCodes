BANKERS ALGORITHM

#include<stdio.h>
#include<conio.h>
#define true 1
#define false 0

int m,n,i,j,count=0,process,c[10];
int max[10][10],alloc[10][10],need[10][10],avail[10],finish[10];

  void readtable(int t[10][10])
  {
     for(i=0;i<m;i++)
       {
	 for(j=0;j<n;j++)
	 scanf("%d",&t[i][j]);
       }
  }

  void printtable(int t[10][10])
  {
    for(i=0;i<m;i++)
    {
     for(j=0;j<n;j++)
     printf("\t%d",t[i][j]);
     printf("\n");
    }
  }

  void readvector(int v[10])
   {
     for(j=0;j<n;j++)
     scanf("%d",&v[j]);
    }

   void printvector(int v[10])
    {
     for(j=0;j<n;j++)
     printf("\t%d",v[j]);
    }
   void init()
    {
      printf("Enter the no of process\n");
      scanf("%d",&m);
      printf("Enter the no of resources") ;
      scanf("%d",&n);
      printf("Enter the claim table");
      readtable(max);
      printf("Enter the allocation table");
      readtable(alloc);
      printf("Enter the max unit of each resources");
      readvector(c);
      for(i=0;i<n;i++)
      finish[i]=false;
    }

      void findavail()
       {
	 int sum;
	 for(j=0;j<m;j++)
	 {
	   sum=0;
	   for(i=0;i<n;i++)
	     sum=sum+alloc[i][j];
	
	    avail[j]=c[j]-sum;
	   }
	 }

      void findneed()
	{
	   for(i=0;i<m;i++)
	   {
	     for(j=0;j<n;j++)
	      need[i][j]=max[i][j]-alloc[i][j];
	
	    }
	  }

      void selectprocess()
	 {
	   int flag;
	   for(i=0;i<m;i++)
	   {
	     for(j=0;j<n;j++)
	     {
	       if(need[i][j]<=avail[j])
	       flag=1;
	       else
	       {
		flag=0;
		break;
	       }
	     }
	     if((flag==1)&&(finish[i]==false))
	     {
	       process=i;
	       count++;
	       break;
	   }
	 }
	   printf("current status is\n");
	   printtable(alloc);
	   if(flag==0)
	     printf("system is in unsafe state\n");
	   
	    printf("system is in safe state");
	 }

     void executeprocess(int p)
	 {
	   printf("executing process is %d",p);
	   printtable(alloc);
	 }

     void releaseresource()
	  {
	    for(j=0;j<n;j++)
	    avail[j]=avail[j]+alloc[process][j];
	    for(j=0;j<n;j++)
	     {
	       alloc[process][j]=0;
	       need[process][j]=0;
	       }
	  }
	     
void main()
{

	     init();
	     findavail();
	     findneed();
	     do
	     {
	       selectprocess();
	       finish[process]=true;
	       executeprocess(process);
	       releaseresource();
	      }
	      while(count<m);
	      printf("\n all process executed correctly");
}
