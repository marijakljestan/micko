//OPIS: for petlja - izostavljeno uvecanje iteratora
int main() {
  int zbir=0;
  int razlika=0;
 
  for(int i=0; i<10; )
  {
     zbir = zbir + i;
     razlika = razlika++ - i + 2;

    for(int v=0; v<3; v++)
      razlika= zbir- v;  
  }

  for(int z=2; z<6; z++){
   
    if(zbir > razlika)
      razlika = zbir - z;
    else
      zbir = razlika - z;
  }  

  return 0;

}
