//OPIS: for petlja-redefinicija iteratora
int main() {
  int zbir=0;
  int razlika=0;
 
  for(int i=0; i<10; i++)
  {
     zbir=zbir+i;
     razlika=razlika-i;

    for(int v=0; v<3; v++)
      razlika=zbir-v;  
  }

  for(int v=1; v<5; v++)
    razlika=zbir-v;  

  return 0;

}
