#include<stdio.h>
#include<conio.h>
#include<math.h>
#include<string.h>

void sort(int);
void divide(int,int);
void eff(int);
int check(int);

struct shanfan
{
	char symbol[10];
	float prob;
	char code[10];
	int count;
}a[25];
char input[30];
void main()
{
	int i,j,ctr,si,l,c,k=0,cnt=0,n=0;
	char temp1[]={' ','\0'};
	float p;
	clrscr();

	printf("Enter the string: ");
	gets(input);
	l=strlen(input);
	printf("The stringlength: %d",l);

	for(i=0;i<l;i++)
	{
		ctr=0;
		c=check(i);
		if(c==0)
			cnt++;
		for(j=0;j<l;j++)
		{	if(c==0)
			{	if(input[i]==input[j])
					ctr++;
			}
			else if(c==1)
			break;
		}
		if(c==0);
		{
			p=ctr/(float)l;
			a[n].prob=p;
			a[n].symbol[k]=input[i];
			strcpy(a[n].code,temp1);
			n++;
		}

	 }
	 sort(cnt);
	 for(i=0;i<cnt;i++)
		a[i].count=0;
	 i=0;
	 getch();
	 divide(i,cnt);
	 printf("\n\nThe required code using shanon fano's algorithm is");
	 printf("\nsymbol \t probability \t code");
	 for(i=0;i<cnt;i++)
		printf("\n %s \t %f \t%s",a[i].symbol,a[i].prob,a[i].code);
	 eff(cnt);
	 getch();
}

	void sort(int n)
	{
		int i,j;
		struct shanfan temp;
		for(i=0;i<n;i++)
			for(j=0;j<n-i-1;j++)
				if(a[j].prob<a[j+1].prob)
				{
					temp=a[j];
					a[j]=a[j+1];
					a[j+1]=temp;
				}


	}

	void divide(int i,int n)
	{
		char temp1[]={'0','\0'};
		char temp2[]={'1','\0'};
		float p=0,p1;
		int j,k,l;
		if((n-i>=2))
		{
			for(j=i;j<n;j++)
				p=p+a[j].prob;
			p1=p/2-p/10;
			p=0;
			for(j=i;j<n;j++)
			{
				p=p+a[j].prob;
				if(p>=p1)
					break;
			}
			for(k=i;k<=j;k++)
			{
				strcat(a[k].code,temp1);
				a[k].count++;
			}
			for(k=j+1;k<n;k++)
			{
				strcat(a[k].code,temp2);
				a[k].count++;
			}
			l=i;
			divide(l,j+1);
			divide(j+1,n);
	} }
	  void eff(int n)
	       {
		int p,q,b[10];
		float r=0.00,ef,hx=0.00;
		for(p=0;p<n;p++)
		{
			hx=hx-1*a[p].prob*(log10(a[p].prob)/log10(2));
			r=r+a[p].count*a[p].prob;
		}
		printf("\n\nh(x)=%0.3f bits/symbol\nrbar= %0.3f bits/symbol",hx,r);
		ef=hx/r;
		printf("\nThe efficiency for above code is %0.2f%",ef*100);
	}

 int check(int i)
	{
		int k;
		for (k=0;k<i;k++)
		{
			if(input[k]==input[i])
			return 1;
		}
			return 0;
     }
