//OPIS: fje sa vise parametara
//RETURN: 0

int foo(int a){
   a++;
   return a;
}

unsigned foo2(unsigned b, int c, unsigned d){
   b = 3u + d++;
   return b;
}

int foo3(int m, unsigned n, int p, unsigned t){
  
   unsigned x;
   int y;

   x = n + t++ - 1u;
   y = m + (p - 5);

   return y;
}

void foo4(int m, unsigned n, int p, unsigned t){
  
   unsigned x;
   int y;

   x = n + t++ - 1u;
   y = m + (p - 5);
}

unsigned foo5(int a, unsigned b, unsigned c, int d){

   unsigned retVal;
   retVal = b + 4u - c++;
   return retVal;

}

int main() {
    int e, f, g;
    unsigned m, n;
 
    e = foo(2);
    m = foo2(2u, e, 10u);
    g = foo3(-5, 3u, e, 6u);
    n = foo5(e, m, 2u, 0);

    return 0;
    
}
