//OPIS: Sanity check za miniC gramatiku

int k;

int f(int x) {
    int y;
    return x + 2 - y;
}

unsigned f2() {
    return 2u;
}

unsigned ff(unsigned x) {
    unsigned y;
    return x + f2() - y;
}

void foo() {
  int x=7;
  return;		        			
}

int foo2(int y, unsigned z, int x) {	        	
   int p;
   p = y + x++ - 2;
   return p;					
}

int main() {
    int a;
    int b;
    int aa, bb;
    int c, d = 3;
    int cc, dd=1;		
    unsigned u;
    unsigned w;
    unsigned uu, uuu;
    unsigned ww, www, wwww;    

    //poziv funkcije
    a = f(3);
   
    //if iskaz sa else delom
    if (a < b)  //1
        a = 1;
    else
        a = -2;

    if (a + c == b + d - 4) //2
        a = 1;
    else
        a = 2;

    if (u == w) {   //3
        u = ff(1u);
        a = f(11);
    }
    else {
        w = 2u;
    }
    if (a + c == b - d - -4) {  //4
        a = 1;
    }
    else
        a = 2;
    a = f(42);

    if (a + (aa-c) - d < b + (bb-a))    //5
        uu = w - u + uu;
    else
        d = aa + bb - c;

    //if iskaz bez else dela
    if (a < b)  //6
        a = 1;

    if (a + c == b - +4)    //7
        a = 1;

    a = c - dd++ + d; 
    d = (a < c) ? 0 : -8;    

    for(int i=0; i<10; i++)
    {
	d = d + i + c++;
	
	for(unsigned j=1u; j<=5u; j++)
	{
	   dd++;
	}
    }

    for(unsigned k=1u; k<5u; k++)
    	uu= uu + k;

   foo();
   
   b = foo2(-1, 2u, 150);

   branch[a; 1,3,5]
   one a = a + 1;
   two a = a + 3;
   three a = a + 5; 
   other a = a - 3;

   return 0;
}

