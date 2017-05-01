/* Modified From http://www.voidware.com/cordic.htm */
#include <stdio.h>
//#include <math.h>
/* working with IEEE doubles, means there are 53 bits
 * of mantissa
 */
#define MAXBITS         23
/* define this to perform all (non 2power) multiplications
 * and divisions with the cordic linear method.
 */
//#define CORDIC_LINEARx
/* these are the constants needed */
static float invGain2;
/*
static float atanhTable[MAXBITS] = {0.549306,
				     0.255413,
				     0.125657,
				     0.062582,
				     0.031260,
				     0.015626,
				     0.007813,
				     0.003906,
				     0.001953,
				     0.000977,
				     0.000488,
				     0.000244,
				     0.000122,
				     0.000061,
				     0.000031,
				     0.000015,
				     0.000008,
				     0.000004,
				     0.000002,
				     0.000001,
				     0.000000,
				     0.000000,
				     0.000000
				   

};
*/
static long int atanhTable[MAXBITS] = {
  35999,
  16738,
  8235,
  4101,
  2048,
  1024,
  512,
  255,
  127,
  64,
  31,
  15,
  7,
  3,
  2,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0
};
//static double gain2Cordic();
//float gain = 1.207534;
long int gain = 79136;
void cordic(long int* x0, long int* y0, long int* z0)
{
  /* here's the hyperbolic methods. its very similar to
   * the circular methods, but with some small differences.
   *
   * the `x' iteration have the opposite sign.
   * iterations 4, 7, .. 3k+1 are repeated.
   * iteration 0 is not performed.
   */
 
  long int x, y, z;
  int i;
  int i_plus = 1;
  //t = .5;
  x =  (*x0); y = (*y0); z = (*z0);
  int k = 3;
  
  
  for (i = 0; i < MAXBITS; ++i) {
    float x1;
    
    if (z >= 0) {
	x1 = x + (y>> i_plus);
        y = y + (x >> i_plus);
	z = z - atanhTable[i];
      }
      else {
	x1 = x - (y >> i_plus);
        y = y - (x >> i_plus);
	
	z = z + atanhTable[i];

      }
    i_plus ++;

    x = x1;

  }  
  *x0 = x;
  *y0 = y;
  *z0 = z;
}

/** hyperbolic features ********************************************/

float sinhcoshCordic(long int a, long int* coshp)
{
  
  long int y;
  *coshp = gain;
  y = 0;
  cordic(coshp, &y, &a);
  return y;
}

float expCordic(long int a)
{
  long int sinhp, coshp;
  coshp = gain;
  sinhp = 0;
  cordic(&coshp, &sinhp, &a);
  return sinhp + coshp;
}
int main()
{
  /* just run a few tests */
  long int v;
  long int x;
  long int c;

  // .88 * 2^16
  x = 57671;
  
  v = sinhcoshCordic(x, &c);
  
  printf("sinh %ld = %.18e\n", x, v/65536.0);
  printf("cosh %ld = %.18e\n", x, c/65536.0);
  
  x = 57671;
  v = expCordic(x);
  
  printf("exp %ld = %.18e\n", x, v/65536.0);
  
  return 0;
}
