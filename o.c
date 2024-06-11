
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "cgen.h"
#include"lambdalib.h"
int a, b;
int cube (int i) {
return i * i * i;

}
int add (int n, int k) {
int j;
j = (-100 - n) + cube(k);
writeInteger(j);
return j;

}
int main ( ) {
a = readInteger();
b = readInteger();
add(a, b);
};