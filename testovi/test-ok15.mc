//OPIS: ugnjezdena for petlja
//RETURN: 10
int main() {

  int zbir, razlika;
  zbir=0;
  razlika=0;
 
  for(int i=0; i<5; i++)
  {
     zbir = zbir + i;
	
	for(int j = 1; j <= 3; j++) {
		
           razlika = razlika + j;
	}
  }

  return zbir;

}
