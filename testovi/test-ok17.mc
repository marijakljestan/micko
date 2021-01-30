//OPIS: dekrement, if iskaz, visestruka dodjela
//RETURN: 9
int foo(int i) {
  int a, b, m = 5 ;
  int c, g = 2;
  int f;
  int d;
  int e;
  unsigned h = 2u;
 
  h--;
  b--;
  e--;
  e = f + d;

  if(i < 0)
    m = b - i;
  else 
    m = i++;

  return m;
}

int main() {
  return foo(-5);
}
