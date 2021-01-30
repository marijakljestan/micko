//OPIS: inc_statement
//RETURN: 11

int a;

int main(int p) {
    int k, b;
    k = 2;
    b = 3;
    a = 5 + k++ + b;
    a++;
    return a;
}

