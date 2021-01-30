//OPIS: zarez ispred prvog parametra

int foo(, int c, int d){
  c++;
  return c;
}

int main() {

    int a,b;
    a = foo (2, 5);
    return 0;
}
