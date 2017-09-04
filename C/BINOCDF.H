#ifndef _BINODCDF_H_
#define _BINODCDF_H_


#define MAXIT 100
#define EPS 3.0e-7
#define FPMIN 1.0e-30

double betai(double a, double b, double x);
double binocdf(double x, double n, double p);
double betacf(double a, double b, double x);
double gammln(double xx);

#endif