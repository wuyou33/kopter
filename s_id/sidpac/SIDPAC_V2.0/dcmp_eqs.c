//
//  MEX function dcmp_eqs.c
//
//  MEX file equivalent of dcmp_eqs.m
//
//  Usage: xd = dcmp_eqs(p,u,x,c);
//
//  Description:
//
//    Computes the state vector derivatives 
//    for data compatibility analysis.  
//
//  Input:
//    
//      p = vector of parameter values.
//      u = input vector = [ax,ay,az,p,q,r]'.
//      x = state vector = [u,v,w,phi,the,psi]'.
//      c = cell structure:
//          c.{1} = c.p0c = p0c = vector of initial parameter values.
//          c.{2} = c.ipc = ipc = index vector to select estimated parameters.
//          c.{3} = c.ims = ims = index vector to select measured states.
//          c.{4} = c.imo = imo = index vector to select model outputs.
//
//  Output:
//
//     xd = time derivative of the state vector.
//
//
//    Calls:
//      None
//
//    Author:  Eugene A. Morelli
//
//    History:  
//      10 Nov 2000 - Created and debugged, EAM.
//
//  Copyright (C) 2006  Eugene A. Morelli
//
//  This program carries no warranty, not even the implied 
//  warranty of merchantability or fitness for a particular purpose.  
//
//  Please email bug reports or suggestions for improvements to:
//
//      e.a.morelli@nasa.gov
//

#include <math.h>
#include "mex.h"

/* Input Arguments */

#define	P_IN	prhs[0]
#define	U_IN	prhs[1]
#define	X_IN	prhs[2]
#define	C_IN	prhs[3]


/* Output Arguments */

#define	XD_OUT	plhs[0]

/* Define MAX and MIN functions */

#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define	MIN(A, B)	((A) < (B) ? (A) : (B))
#endif

#define G 32.174
#define MAX_NP 18
#define MAX_NS 6
#define MAX_NC 6

static void dcmp_eqs(double	xd[], 
                     double p[], double u[], double x[], 
                     double p0c[], double ipc[], double ims[], double imo[])
{
  double pc[MAX_NP];
  int i, j;

/* Initialize the parameters. */

  j=0;
  for (i=0;i<MAX_NP;i++) {
//  mexPrintf("\n Element %i of p0c is %f \n", i, p0c[i]);
    if (ipc[i]) {
      pc[i] = p[j];
      j++;
    } 
    else {
      pc[i] = p0c[i];
    } 
  }

/* Substitute measured states. */

  for (i=0;i<MAX_NS;i++) {
    if (ims[i]) {
      x[i] = u[i+MAX_NC];
    }
  }

/* u equation. */ 
  xd[0] = (u[5]+pc[5])*x[1] - (u[4]+pc[4])*x[2] 
          - G*sin(x[4]) + u[0] + pc[0];

/* v equation. */
  xd[1] = -(u[5]+pc[5])*x[0] + (u[3]+pc[3])*x[2] 
          + G*cos(x[4])*sin(x[3]) + u[1] + pc[1];

/* w equation. */
  xd[2] = (u[4]+pc[4])*x[0] - (u[3]+pc[3])*x[1] 
          + G*cos(x[4])*cos(x[3]) + u[2] + pc[2];

/* psi equation. */
  xd[5] = (sin(x[3])*(u[4]+pc[4]) + cos(x[3])*(u[5]+pc[5]))/cos(x[4]);

/* phi equation. */
  xd[3] = (u[3]+pc[3]) + sin(x[4])*xd[5];

/* the equation. */
  xd[4] = cos(x[3])*(u[4]+pc[4]) - sin(x[3])*(u[5]+pc[5]); 

    return;
}

void mexFunction( int nlhs, mxArray *plhs[], 
            		  int nrhs, const mxArray *prhs[] )
     
{ 
  double *xd; 
  double *p, *u, *x; 
  mxArray *cell_ptr;
  double *p0c, *ipc, *ims, *imo;
  int ndim=2;
  int subs[2];
  int index;
  unsigned int m, n;
  int ns,np; 
    
/* Check for proper number of arguments */
    
  if (nrhs != 4) { 
	  mexErrMsgTxt("Four input arguments required."); 
  } 
  else if (nlhs > 1) {
	  mexErrMsgTxt("Too many output arguments."); 
  } 
    
/*  Check the dimensions of x.  */
/*  Legal dimensions are 6x1 or 1x6. */

  m = mxGetM(X_IN); 
  n = mxGetN(X_IN);
  if (!mxIsDouble(X_IN) || mxIsComplex(X_IN) || 
	   (MAX(m,n) != 6) || (MIN(m,n) != 1)) { 
	  mexErrMsgTxt(" Input x must be a 6x1 real vector."); 
  } 
  ns = MAX(m,n);
    
/* Create a matrix for the return argument */ 
  XD_OUT = mxCreateDoubleMatrix(ns, 1, mxREAL); 
    
/*  Check the dimensions of p.  */
  m = mxGetM(P_IN); 
  n = mxGetN(P_IN);
  if (!mxIsDouble(P_IN) || mxIsComplex(X_IN) || 
	   (MAX(m,n) > 18) || (MIN(m,n) != 1)) { 
	  mexErrMsgTxt(" Input p must be a real vector."); 
  } 
  np = MAX(m,n);

/* Assign pointers to the various parameters */ 
  xd = mxGetPr(XD_OUT);
    
  p = mxGetPr(P_IN); 
  u = mxGetPr(U_IN); 
  x = mxGetPr(X_IN);

/* Access the elements of the cell structure */

/*  p0c  */
  subs[0]=0;
  subs[1]=0;
  index = mxCalcSingleSubscript(C_IN, ndim, subs);
  cell_ptr = mxGetCell(C_IN, index);
  p0c = mxGetPr(cell_ptr);

/*  ipc  */
  subs[0]=1;
  subs[1]=0;
  index = mxCalcSingleSubscript(C_IN, ndim, subs);
  cell_ptr = mxGetCell(C_IN, index);
  ipc = mxGetPr(cell_ptr);

/*  ims  */
  subs[0]=2;
  subs[1]=0;
  index = mxCalcSingleSubscript(C_IN, ndim, subs);
  cell_ptr = mxGetCell(C_IN, index);
  ims = mxGetPr(cell_ptr);

/*  imo  */
  subs[0]=3;
  subs[1]=0;
  index = mxCalcSingleSubscript(C_IN, ndim, subs);
  cell_ptr = mxGetCell(C_IN, index);
  imo = mxGetPr(cell_ptr);
        
/* Do the actual computations in a subroutine */
  dcmp_eqs(xd,p,u,x,p0c,ipc,ims,imo); 
    
  return;
}
