//OPIS: Return iskazi u razlicitim tipovima funkcija, void tip funkcije
//RETURN: 0
void foo(){

  int a=1;

  return;
}
 
int foo2(int b){
  
  if(b > 0)
    b = b - 3;
  else
     b = b + 3;
  
  return b;
}

int foo3(){

  int c=3;
  c++;
  return c;
}

unsigned foo4 (unsigned m, int n){

  unsigned p;
  p = m + 5u;

  return p;

}

int main(){
  
  unsigned x;
  x = foo4(5u, -2);
  
  return 0;
}
