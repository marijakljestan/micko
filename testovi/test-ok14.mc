//OPIS: Parametri i funkcije
//RETURN: 11

int x;

int func(int b , int c) {
	int a;
	b = b + 1;
	return b;
}

void func2() {
}

int main() {
	int a, b;
	int c;
	unsigned d;

	a = 9;
	b = 1;
	c = func(a , b);
	func2();

	c = c + 1;
 	return c;
}
