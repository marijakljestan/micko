//OPIS: fje sa vise parametara- pogresan broj argumenata za foo2 i neodgovarajuci tipovi argumenata za foo3

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
   y = m + p - 5;

   return y;
}

int main() {
    int e, f, g;
    unsigned m;
 
    e = foo(2);
    m = foo2(2u, e);
    g = foo3(-5, 3u, e, 6);
    
}
