//
//  MEX function adamb3.c
//
//  MEX file equivalent of adamb3.m
//
//  Usage: x = adamb3(deqname,p,u,t,x0,c);
//
//  Description:
//
//	  Integrates the differential equations specified
//    in the file named deqname, using third-order
//    Adams-Bashforth integration with input interpolation.
//
//  Input:
//    
//     deqname = name of the file that computes the state derivatives.
//           p = parameter vector.
//           u = control vector time history.
//           t = time vector.
//          x0 = state vector initial condition.
//           c = vector or data structure of constants.
//
//  Output:
//
//        x = state vector time history.
//
//
//  Calls:
//    None
//
//  Author:  Eugene A. Morelli
//
//  History:  
//    26 Nov 2000 - Created and debugged, EAM.
//    02 Jul 2002 - Corrected name and comments, EAM.
//
//
//  Copyright (C) 2006  Eugene A. Morelli
//
//
//  This program carries no warranty, not even the implied 
//  warranty of merchantability or fitness for a particular purpose.  
//
//  Please email bug reports or suggestions for improvements to:
//
//    e.a.morelli@nasa.gov
//

#include <math.h>
#include "mex.h"


// Input Arguments. 

#define DEQN_IN prhs[0]
#define	P_IN	  prhs[1]
#define	U_IN	  prhs[2]
#define T_IN    prhs[3]
#define	X0_IN	  prhs[4]
#define	C_IN	  prhs[5]


// Output Arguments.

#define	X_OUT	plhs[0]


#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define	MIN(A, B)	((A) < (B) ? (A) : (B))
#endif


void mexFunction( int nlhs, mxArray *plhs[], 
            		  int nrhs, const mxArray *prhs[] )
{
  double *x;
  char *deqn;
  double *p,*u,*t,*x0,*c; 
  int buflen, status;
  int m, n;
  int npts, ns, ni;
  mxArray *XI, *UI, *XDP;
  double *xi, *ui, *xdp;
  double *xd1, *xd2;
  double dt;
  double k[3]={23.0/12.0, -16.0/12.0, 5.0/12.0};
  int i, j;
  mxArray *out_array[2], *in_array[4];
  int num_in, num_out;

// Check for proper number of arguments. 
  if (nrhs != 6) 
    { mexErrMsgTxt("Six input arguments required."); 
      return; 
    } 
  else if (nlhs > 1) 
    { mexErrMsgTxt("Too many output arguments."); 
      return;
    } 
    
// First input must be a string. 
  if ( mxIsChar(DEQN_IN) != 1)
      mexErrMsgTxt("First input must be a string.");

// First input must be a row vector. 
  if (mxGetM(DEQN_IN)!=1)
    mexErrMsgTxt("First input must be a row vector.");    

// Get the length of the input string. 
  buflen = (mxGetM(DEQN_IN) * mxGetN(DEQN_IN)) + 1;

// Allocate memory for input string. 
  deqn = mxCalloc(buflen, sizeof(char));

// Copy the string data from prhs[0] into a C string deqn. 
  status = mxGetString(DEQN_IN, deqn, buflen);
  if(status != 0) 
    mexWarnMsgTxt("Not enough space. String is truncated.");

// Check the dimensions of x0.  
  m = mxGetM(X0_IN); 
  n = mxGetN(X0_IN);
  ns = MAX(m,n);
  if (!mxIsDouble(X0_IN) || mxIsComplex(X0_IN) || (MIN(m,n) != 1)) 
    { mexErrMsgTxt(" Input x0 must be a real vector."); 
      return; 
    } 
    
// Check the dimensions of t. 
  m = mxGetM(T_IN); 
  n = mxGetN(T_IN);
  npts = MAX(m,n);
  if (!mxIsDouble(T_IN) || mxIsComplex(T_IN) || (MIN(m,n) != 1)) 
    { mexErrMsgTxt(" Input t must be a real vector."); 
      return;
    } 

// Check the dimensions of u. 
  m = mxGetM(U_IN); 
  n = mxGetN(U_IN);
  ni = MIN(m,n);
  if (!mxIsDouble(U_IN) || mxIsComplex(U_IN) || (MAX(m,n) != npts)) 
    { mexErrMsgTxt(" Input u must have same length as t."); 
      return;
    } 

// Create a matrix for the return argument. 
  X_OUT = mxCreateDoubleMatrix(npts, ns, mxREAL); 
    
// Create an intermediate state vector.
  XI = mxCreateDoubleMatrix(ns, 1, mxREAL);

// Create an intermediate control vector.
  UI = mxCreateDoubleMatrix(ni, 1, mxREAL);

// Create a state derivative vector.
  XDP = mxCreateDoubleMatrix(ns, 3, mxREAL);

// Assign pointers to the various parameters. 
  x = mxGetPr(X_OUT);
    
  p = mxGetPr(P_IN); 
  u = mxGetPr(U_IN);
  t = mxGetPr(T_IN);
  x0 = mxGetPr(X0_IN);
  c = mxGetPr(C_IN);
        
  xi = mxGetPr(XI);
  ui = mxGetPr(UI);
  xdp = mxGetPr(XDP);

//
// Do the actual computations. 
//

// Initial state vector. 
  for (j=0;j<ns;j++) {
    x[j*npts]=x0[j];
    xi[j]=x0[j];
//    mexPrintf("\n Element %i of x0 is %f \n", j, x0[j]);
  }

// Initialize the time step.
  dt=t[1]-t[0];

//  mexPrintf("\n The value of deqn is %s \n", deqn);

//
// Initialize input and output parameters for the 
// Matlab file containing the differential equations.  
//
  num_in = 4;
  in_array[0] = P_IN;
  in_array[1] = UI;
  in_array[2] = XI;
  in_array[3] = C_IN;
  num_out = 1;
//
// Start-up Runge-Kutta loop.
//
  for (i=0;i<2;i++) {

// State vector.
    for (j=0;j<ns;j++) {
      xi[j]=x[i+j*npts];
    }

// Control vector.
    for (j=0;j<ni;j++) {
      ui[j]=u[i+j*npts];
    }

//
// Compute the state vector derivative at the current time.
// Must use mxGetPr to locate the output.
//
    mexCallMATLAB(num_out,out_array,num_in,in_array,deqn);
    xd1=mxGetPr(out_array[0]);

// Update state vector derivative matrix.
    for (j=0;j<ns;j++) {
      xdp[j+2*ns]=xdp[j+ns];
      xdp[j+ns]=xdp[j];
      xdp[j]=xd1[j];
    }

//
// Print the result.
//    num_in = 1;
//    in_array[0] = out_array[0];
//    num_out = 0;
//    mexCallMATLAB(num_out,out_array,num_in,in_array,"disp");

// Update the state vector.
    for (j=0;j<ns;j++) {
      xi[j] = xi[j] + dt*xd1[j]/2;
    }

// Update the control vector.
    for (j=0;j<ni;j++) {
      ui[j] = (ui[j] + u[i+1+j*npts])/2;
    }

//
// Compute the state vector derivative at the intermediate time.
// Must use mxGetPr to locate the output.
//
    mexCallMATLAB(num_out,out_array,num_in,in_array,deqn);
    xd2=mxGetPr(out_array[0]);

// Store the output.
    for (j=0;j<ns;j++) {
      x[i+1+j*npts] = x[i+j*npts] + dt*xd2[j];
    }
  }
//
// Main Adams-Bashforth integration loop.
//
  for (i=2;i<npts-1;i++) {

// State vector.
    for (j=0;j<ns;j++) {
      xi[j]=x[i+j*npts];
    }

// Control vector.
    for (j=0;j<ni;j++) {
      ui[j]=u[i+j*npts];
    }

//
// Compute the state vector derivative at the current time.
// Must use mxGetPr to locate the output.
//
    mexCallMATLAB(num_out,out_array,num_in,in_array,deqn);
    xd1=mxGetPr(out_array[0]);


// Update state vector derivative matrix.
    for (j=0;j<ns;j++) {
      xdp[j+2*ns]=xdp[j+ns];
      xdp[j+ns]=xdp[j];
      xdp[j]=xd1[j];
    }
//
// Print the result.
//    num_in = 1;
//    in_array[0] = out_array[0];
//    num_out = 0;
//    mexCallMATLAB(num_out,out_array,num_in,in_array,"disp");

// Compute and store the output.
    for (j=0;j<ns;j++) {
      x[i+1+j*npts] = x[i+j*npts] + dt*(xdp[j]*k[0]  
                      + xdp[j+ns]*k[1] + xdp[j+2*ns]*k[2]);
//      if (i==2 && j<3)
//        mexPrintf("\n Element %i of k is %f \n", j, k[j]);
    }
  }
  return;
}
