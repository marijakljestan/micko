//OPIS: return- void funkcija ne smije imati povratnu vrijednost

void foo(int a){
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
 
    m = foo2(2u, e, 1u);
    g = foo3(-5, 3u, e, 6u);
    
}
