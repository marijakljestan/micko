//OPIS: for petlja, ugnjezdena for petlja i if iskaz
//RETURN: 0
int main() {
  int zbir=0;
  int razlika=0;
 
  for(int i=0; i<10; i++)
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

    if(zbir == razlika)
	razlika = zbir + 1;
    else
	zbir = razlika + 2;
  }  

  return 0;

}
