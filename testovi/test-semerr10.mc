//OPIS: for petlja-iterator i literal nisu istog tipa
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

  for(int z=1u; z<8; z++)
    razlika=zbir-v;  

  return 0;

}
