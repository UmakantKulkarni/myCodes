
//4) Polynomial addition using array of structure.

#include<stdio.h>
#include<math.h>
#define max 50

typedef struct term
{
	int coeff,power;
}term;

typedef struct polynomial
{
       int degree;
	   //highest power of the x is called degree of the polynomial
       term  polyn[max];//array of terms to store terms
}polynomial;
polynomial create(int );
void PrintPolynomial(polynomial );
polynomial MultiplyPolynomial( polynomial, polynomial );
polynomial AddPolynomial( polynomial , polynomial );
int  Evaluate(polynomial , int );


int main()
{
	int degree1, degree2;
	int value,opt;

	polynomial p1,p2,reasult,Additionreasult;

	clrscr();
	do
	{
		printf("\n1)Create First Polynomial:");
		printf("\n2)Create Second Polynomial:");
		printf("\n3)Print First Polynomial:");
		printf("\n4)Print Second Polynomial:");
		printf("\n5)Add   both Polynomial:");
		printf("\n6)Multiply with other  Polynomial");
		printf("\n7)Evaluate First Polynomial");
		printf("\n8)Evaluate Second PolynomiaSl:");
		printf("\n9)Exit");
		printf("\nEnter Your Choice : ");
		scanf("%d", &opt);

	switch(opt)
	{
		case 1:
			printf("please enter degree of polynomial : ");
			scanf("%d",&degree1);
			p1=create(degree1);
			break;
	    case 2:
			printf("please enter degree of other  polynomial : ");
			scanf("%d",&degree2);
		    p2=create(degree2);
			break;
	    case 3:
			PrintPolynomial(p1);
			printf("\n");
			break;
	    case 4:
			PrintPolynomial(p2);
			printf("\n");
			break;
	    case 5:
			PrintPolynomial(AddPolynomial(p1, p2));
		    break;
	    case 6:
			//Multiplication of polynomial is optional it is not mentioned in programm to do
			//so you can exclude
			PrintPolynomial(MultiplyPolynomial(p1,p2));
			printf("\n");
			break;
	    case 7:
		//evaluation of polynomial is also optional
			printf("\nplease assign value for x  : ");
			scanf("%d", &value);
			printf("The vale is  %d\n",Evaluate(p1, value));
			break;

	    case 8:
			printf("\nplease assign value for x  :  ");
			scanf("%d", &value);
			printf("The vale is  %d\n", Evaluate(p2, value));
			break;
	}

	}while(opt!=9);
	getch();
	return 0;
}
 polynomial create(int degree)
{
       int i;

       polynomial p;
       p.degree = degree;

	   for(i=degree; i>=0; i--)
       {
			term term;
			printf("please enter coeff of x^%d  :",i);
			scanf("%d",&term.coeff);
			term.power = i;
			p.polyn[i] = term;
       }

	   return p;
}

void PrintPolynomial(polynomial poly)
{
		int i;
		for(i = poly.degree; i >= 0; i--)
		{
			if(poly.polyn[i].coeff)
			{
				char sign = '+';//set it default  to plus
				int coeff = poly.polyn[i].coeff;

				if(coeff < 0)
				{
					//but if coeff is minus sign is minus
					sign = '-';
					coeff = -1 * coeff;
					//make the dummy variable coeff plus by multiplying it by 1
					// so that minus sign does not diplay double
				}
				else if (poly.degree==i)
					sign =' ';

				
				if(poly.polyn[i].power)
				{
					//this step only the crux of function
					//all else if conditions you can exclude they are only to display exactly
					printf("  %c %d X^%d ", sign, coeff,poly.polyn[i].power);
				}
				else
				{
					printf("  %c %d ", sign, coeff);
				}
			}
		}
}
// this function is optional
 polynomial MultiplyPolynomial(polynomial p1,  polynomial p2)
{
	int i, j, terms;
	polynomial poly;
	
	/*intialize poly with coeff 0*/
	poly.degree = p1.degree + p2.degree;
	
	for( i = 0; i <= poly.degree; i++)
	{
		poly.polyn[i].power = i;
		poly.polyn[i].coeff = 0;
	}
	
	for( i = 0; i <= p1.degree; i++)
	{
		for(j = 0; j <= p2.degree; j++)
		{
			poly.polyn[i + j].coeff += p1.polyn[i].coeff * p2.polyn[j].coeff;
		}
	}
			
	return poly;
}

polynomial AddPolynomial( polynomial p1, polynomial p2)
{
		int i;
		polynomial poly;
		
		poly.degree = p1.degree < p2.degree ? p2.degree : p1.degree;
		
		for(i = 0; i <= poly.degree; i++)
		{
			poly.polyn[i].power = i;
			poly.polyn[i].coeff = 0;
			
			if( i <= p1.degree)
				poly.polyn[i].coeff += p1.polyn[i].coeff;
			
			if( i <= p2.degree)
				poly.polyn[i].coeff += p2.polyn[i].coeff;
		}
		
		return poly;
}
int  Evaluate(polynomial poly, int value)
{
	int i, sum = 0;
	
	for(i = poly.degree ; i>=0; i--)
	{
		sum += pow(value, i) * poly.polyn[i].coeff;
	}
	
	return sum;
}
/*



E:\Programming\c\se-entc>gcc 4-structpoly.c

E:\Programming\c\se-entc>rename a.exe 4-polynomial.exe

E:\Programming\c\se-entc> 4-polynomial.exe

1)Create First Polynomial:
2)Create Second Polynomial:
3)Print First Polynomial:
4)Print Second Polynomial:
5)Add   both Polynomial:
6)Multiply with other  Polynomial
7)Evaluate First Polynomial
8)Evaluate Second PolynomiaSl:
9)Exit
Enter Your Choice : 1
please enter degree of polynomial : 3
please enter coeff of x^3  : 1
please enter coeff of x^2  :2
please enter coeff of x^1  :3
please enter coeff of x^0  :4

1)Create First Polynomial:
2)Create Second Polynomial:
3)Print First Polynomial:
4)Print Second Polynomial:
5)Add   both Polynomial:
6)Multiply with other  Polynomial
7)Evaluate First Polynomial
8)Evaluate Second PolynomiaSl:
9)Exit
Enter Your Choice : 2
please enter degree of other  polynomial :  3
please enter coeff of x^3  : 4
please enter coeff of x^2  :3
please enter coeff of x^1  :2
please enter coeff of x^0  : -1

1)Create First Polynomial:
2)Create Second Polynomial:
3)Print First Polynomial:
4)Print Second Polynomial:
5)Add   both Polynomial:
6)Multiply with other  Polynomial
7)Evaluate First Polynomial
8)Evaluate Second PolynomiaSl:
9)Exit
Enter Your Choice : 3
    1 X^3   + 2 X^2   + 3 X^1   + 4

1)Create First Polynomial:
2)Create Second Polynomial:
3)Print First Polynomial:
4)Print Second Polynomial:
5)Add   both Polynomial:
6)Multiply with other  Polynomial
7)Evaluate First Polynomial
8)Evaluate Second PolynomiaSl:
9)Exit
Enter Your Choice : 4
    4 X^3   + 3 X^2   + 2 X^1   - 1

1)Create First Polynomial:
2)Create Second Polynomial:
3)Print First Polynomial:
4)Print Second Polynomial:
5)Add   both Polynomial:
6)Multiply with other  Polynomial
7)Evaluate First Polynomial
8)Evaluate Second PolynomiaSl:
9)Exit
Enter Your Choice : 5
    5 X^3   + 5 X^2   + 5 X^1   + 3
1)Create First Polynomial:
2)Create Second Polynomial:
3)Print First Polynomial:
4)Print Second Polynomial:
5)Add   both Polynomial:
6)Multiply with other  Polynomial
7)Evaluate First Polynomial
8)Evaluate Second PolynomiaSl:
9)Exit
Enter Your Choice : 6
    4 X^6   + 11 X^5   + 20 X^4   + 28 X^3   + 16 X^2   + 5 X^1   - 4

1)Create First Polynomial:
2)Create Second Polynomial:
3)Print First Polynomial:
4)Print Second Polynomial:
5)Add   both Polynomial:
6)Multiply with other  Polynomial
7)Evaluate First Polynomial
8)Evaluate Second PolynomiaSl:
9)Exit
Enter Your Choice : 7

please assign value for x  : 1
The vale is  10

1)Create First Polynomial:
2)Create Second Polynomial:
3)Print First Polynomial:
4)Print Second Polynomial:
5)Add   both Polynomial:
6)Multiply with other  Polynomial
7)Evaluate First Polynomial
8)Evaluate Second PolynomiaSl:
9)Exit
Enter Your Choice : 8

please assign value for x  :  2
The vale is  47

1)Create First Polynomial:
2)Create Second Polynomial:
3)Print First Polynomial:
4)Print Second Polynomial:
5)Add   both Polynomial:
6)Multiply with other  Polynomial
7)Evaluate First Polynomial
8)Evaluate Second PolynomiaSl:
9)Exit
Enter Your Choice : 9

E:\Programming\c\se-entc>

*/