//
//  MEX function nldyn_eqs.c
//
//  MEX file equivalent of nldyn_eqs.m
//
//  Usage: [xd,accel] = nldyn_eqs(p,u,x,c);
//
//  Description:
//
//    Computes the state vector derivatives 
//    and acceleration outputs, using  
//    full nonlinear aircraft dynamics.  
//
//  Input:
//    
//     p = vector of parameter values.
//     u = control vector.
//     x = state vector = [vt,beta,alpha,prad,qrad,rrad,phi,the,psi]'.
//     c = cell structure:
//       c{1} = c.p0oe  = p0oe  = vector of initial parameter values.
//       c{2} = c.ipoe  = ipoe  = index vector to select estimated parameters.
//       c{3} = c.ims   = ims   = index vector to select measured states.
//       c{4} = c.imo   = imo   = index vector to select model outputs.
//       c{5} = c.imc   = imc   = index vector to select non-dimensional 
//                                coefficients to be modeled.
//       c{6} = c.x0    = x0    = initial state vector.
//       c{7} = c.u0    = u0    = initial control vector.
//       c{8} = c.fdata = fdata = standard array of measured flight data, 
//                                geometry, and mass/inertia properties.  
//  Output:
//
//      xd = time derivative of the state vector.
//   accel = vector of acceleration outputs = [ax,ay,az,pdot,qdot,rdot]'.
//
//
//    Calls:
//      None
//
//    Author:  Eugene A. Morelli
//
//    History:
//      07 Oct  2001 - Created and debugged, EAM.
//      14 Oct  2001 - Modified to use numerical integration routines, EAM.
//      23 July 2002 - Added acceleration outputs, EAM.
//      19 Aug  2004 - Added imc, increased accuracy of DTR, EAM.
//      15 Feb  2006 - Modified for SIDPAC 2.0, EAM.
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

#define	XD_OUT	  plhs[0]
#define	ACCEL_OUT	plhs[1]

/* Define MAX and MIN functions */

#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define	MIN(A, B)	((A) < (B) ? (A) : (B))
#endif

#define G 32.174
#define DTR 3.14159265358979/180
#define MAX_NP 70
#define MAX_NS 9
#define MAX_NI 20
#define MAX_FDATA 90


static void massprop(double c[], double mass, double ixx, double iyy, double izz, double ixz, 
                     double xcg, double ycg, double zcg, 
                     double fdata[])
{
  double gam;

//
// Compute mass and inertia properties.  
//
  xcg=fdata[44];
  ycg=fdata[45];
  zcg=fdata[46];
  mass=fdata[47];
  ixx=fdata[48];
  iyy=fdata[49];
  izz=fdata[50];
  ixz=fdata[51];
  gam=ixx*izz-ixz*ixz;
  c[0]=((iyy-izz)*izz-ixz*ixz)/gam;
  c[1]=(ixx-iyy+izz)*ixz/gam;
  c[2]=izz/gam;
  c[3]=ixz/gam;
  c[4]=(izz-ixx)/iyy;
  c[5]=ixz/iyy;
  c[6]=1.0/iyy;
  c[7]=(ixx*(ixx-iyy)+ixz*ixz)/gam;
  c[8]=ixx/gam;
  c[9]=mass;
  c[10]=xcg;
  c[11]=ycg;
  c[12]=zcg;

  return;
}


static void nldyn_eqs(double	xd[], double accel[], 
                      double p[], double u[], double x[], 
                      double p0oe[], double ipoe[], double ims[], 
                      double imc[], double x0[], double u0[], 
                      double fdata[])
{
  const int XINDX[9]={ 1, 2, 3, 4, 5, 6, 7, 8, 9};
  const int UINDX[3]={ 13, 14, 15};
  int i, j;
  double poe[MAX_NP], xl[MAX_NS];
  double sarea, bspan, cbar, heng;
  double mass, ixx, iyy, izz, ixz, xcg, ycg, zcg, ci[13];
  double vt, beta, alpha, prad, qrad, rrad, phat, qhat, rhat;
  double phi, the, psi;
  double el, ail, rdr;
  double mach, qbar, thrust;
  double cx, cy, cz, c1, cm, cn;
  double cb, ub, vb, wb, sth, cth, sph, cph, sps, cps;
  double qs, qsb, udot, vdot, wdot;

/* Initialize the parameters. */

  j=0;
  for (i=0;i<MAX_NP;i++) {
//  mexPrintf("\n Element %i of p0oe is %f \n", i, p0oe[i]);
    if (ipoe[i]) {
      poe[i] = p[j];
      j++;
    } 
    else {
      poe[i] = p0oe[i];
    } 
  }
//
// Substitute measured states. 
//
// Use a local copy of x, called xl, 
// to avoid overwriting the input vector x.
//
  for (i=0;i<MAX_NS;i++) {
    xl[i] = x[i];
    if (ims[i]) {
      xl[i] = fdata[XINDX[i]];
      if (XINDX[i] != 1 ) { 
  	    xl[i]=xl[i]*DTR;
      } 
    }
  }

//
// Constants in the nonlinear dynamic equations. 
//
  sarea=fdata[76];
  bspan=fdata[77];
  cbar=fdata[78];
  heng=0;

//
//  Mass property calculations work even when 
//  the input fdata matrix has only one row, 
//  as in this case.  
//
  massprop(ci,mass,ixx,iyy,izz,ixz,xcg,ycg,zcg,fdata);

//
//  Assign state and control variables.
//
  vt=xl[0];
  beta=xl[1];
  alpha=xl[2];
  prad=xl[3];
  qrad=xl[4];
  rrad=xl[5];
//  phat=prad*bspan/(2*vt);  
//  qhat=qrad*cbar/(2*vt);  
//  rhat=rrad*bspan/(2*vt);  
  phat=fdata[70];
  qhat=fdata[71];
  rhat=fdata[72];
  phi=xl[6];
  the=xl[7];
  psi=xl[8];
  el=u[0];
  ail=u[1];
  rdr=u[2];

//
//  Air data.
//
  mach=fdata[27];
  qbar=fdata[26];

//
//  Engine thrust.
//
  thrust=fdata[37]+fdata[38];

//
//  Aerodynamic force and moment coefficient models.
//

/*  CX  */

  if (imc[0]==0) {
    cx=fdata[60];
  } 
  else {
    cx=poe[0]*(vt-x0[0])/x0[0] + poe[1]*(alpha-x0[2]) + poe[2]*qhat 
       + poe[3]*(el-u0[0]) + poe[8];
//    cx=poe[0]*vt/x0[0] + poe[1]*alpha + poe[2]*qhat 
//       + poe[3]*el + poe[8];
  } 

/*  CY  */

  if (imc[1]==0) {
    cy=fdata[61];
  } 
  else {
//    cy=poe[10]*(beta-x0[1]) + poe[11]*phat + poe[12]*rhat 
//       + poe[13]*(ail-u0[1]) + poe[14]*(rdr-u0[2]) + poe[18];
    cy=poe[10]*beta + poe[11]*phat + poe[12]*rhat 
       + poe[13]*ail + poe[14]*rdr + poe[18];
  } 

/*  CZ  */

  if (imc[2]==0) {
    cz=fdata[62];
  } 
  else {
    cz=poe[20]*(vt-x0[0])/x0[0] + poe[21]*(alpha-x0[2]) + poe[22]*qhat 
       + poe[23]*(el-u0[0]) + poe[28];
//    cz=poe[20]*vt/x0[0] + poe[21]*alpha + poe[22]*qhat 
//       + poe[23]*el + poe[28];
  } 

/*  C1  */

  if (imc[3]==0) {
    c1=fdata[63];
  } 
  else {
//    c1=poe[30]*(beta-x0[1]) + poe[31]*phat + poe[32]*rhat 
//       + poe[33]*(ail-u0[1]) + poe[34]*(rdr-u0[2]) + poe[38];
    c1=poe[30]*beta + poe[31]*phat + poe[32]*rhat 
       + poe[33]*ail + poe[34]*rdr + poe[38];
  } 

/*  Cm  */

  if (imc[4]==0) {
    cm=fdata[64];
  } 
  else {
    cm=poe[40]*(vt-x0[0])/x0[0] + poe[41]*(alpha-x0[2]) + poe[42]*qhat 
       + poe[43]*(el-u0[0]) + poe[48];
//    cm=poe[40]*vt/x0[0] + poe[41]*alpha + poe[42]*qhat 
//       + poe[43]*el + poe[48];
  } 

/*  Cn  */

  if (imc[5]==0) {
    cn=fdata[65];
  } 
  else {
//    cn=poe[50]*(beta-x0[1]) + poe[51]*phat + poe[52]*rhat 
//       + poe[53]*(ail-u0[1]) + poe[54]*(rdr-u0[2]) + poe[58];
    cn=poe[50]*beta + poe[51]*phat + poe[52]*rhat 
       + poe[53]*ail + poe[54]*rdr + poe[58];
  } 

//
//  Compute quantities used often in the state equations. 
//
  cb=cos(beta);
  ub=vt*cos(alpha)*cb;
  vb=vt*sin(beta);
  wb=vt*sin(alpha)*cb;
  sth=sin(the);  cth=cos(the);
  sph=sin(phi);  cph=cos(phi);
  sps=sin(psi);  cps=cos(psi);
  qs=qbar*sarea; qsb=qs*bspan;

//
//  Translational acceleration, ft/sec2.
//
  accel[0]=(qs*cx + thrust)/ci[9];
  accel[1]=qs*cy/ci[9];
  accel[2]=qs*cz/ci[9];
//
//  Force equations.
//
  udot=rrad*vb - qrad*wb - G*sth + accel[0];
  vdot=prad*wb - rrad*ub + G*cth*sph + accel[1];
  wdot=qrad*ub - prad*vb + G*cth*cph + accel[2];

/*  vt equation.  */

  xd[0]=(ub*udot+vb*vdot+wb*wdot)/vt + poe[9];

/*  beta equation.  */

  xd[1]=(vt*vdot-vb*xd[0])/(cb*vt*vt) + poe[19];

/*  alpha equation.  */

  xd[2]=(wdot*ub-wb*udot)/(ub*ub+wb*wb) + poe[29];

//
//  Moment equations.
//

/*  p equation.  */

  xd[3]=(ci[1]*prad+ci[0]*rrad+ci[3]*heng)*qrad + qsb*(ci[2]*c1+ci[3]*cn) + poe[39];

/*  q equation.  */

  xd[4]=(ci[4]*prad-ci[6]*heng)*rrad + ci[5]*(rrad*rrad-prad*prad) + qs*cbar*ci[6]*cm + poe[49];

/*  r equation.  */

  xd[5]=(ci[7]*prad-ci[1]*rrad+ci[8]*heng)*qrad + qsb*(ci[3]*c1 + ci[8]*cn) + poe[59];

//
//  Kinematic equations.
//

/*  psi equation.  */

  xd[8]=(qrad*sph+rrad*cph)/cth + poe[62];

/*  phi equation.  */

  xd[6]=prad + sth*xd[8] + poe[60];

/*  the equation.  */

  xd[7]=qrad*cph-rrad*sph + poe[61];

//
//  Translational acceleration, g.
//
  accel[0]=accel[0]/G + poe[63];
  accel[1]=accel[1]/G + poe[64];
  accel[2]=accel[2]/G + poe[65];
//
//  Rotational acceleration.
//
  accel[3]=xd[3] + poe[66];
  accel[4]=xd[4] + poe[67];
  accel[5]=xd[5] + poe[68];

  return;
}


void mexFunction( int nlhs, mxArray *plhs[], 
            		  int nrhs, const mxArray *prhs[] )
     
{ 
  double *xd, *accel; 
  double *p, *u, *x; 
  mxArray *cell_ptr;
  double *p0oe, *ipoe, *ims, *imc, *x0, *u0;
  double fdata[MAX_FDATA];
  int ndim = 2;
  int subs[2];
  int index, j;
  unsigned int m, n;
  int ns, np, ni, ti; 
    
/* Check for proper number of arguments */
    
  if (nrhs != 4) { 
	  mexErrMsgTxt("Four input arguments required."); 
  } 
  else if (nlhs > 2) {
	  mexErrMsgTxt("Too many output arguments."); 
  } 
    
/*  Check the dimensions of x.  */
/*  Legal dimensions are (MAX_NS x 1) or (1 x MAX_NS). */

  m = mxGetM(X_IN); 
  n = mxGetN(X_IN);
  if (!mxIsDouble(X_IN) || mxIsComplex(X_IN) || 
	   (MAX(m,n) != MAX_NS) || (MIN(m,n) != 1)) { 
	  mexErrMsgTxt(" Input x must be a properly sized real vector."); 
  } 
  ns = MAX(m,n);
    
/* Create matrices for the return arguments */ 
  XD_OUT = mxCreateDoubleMatrix(ns, 1, mxREAL); 
  ACCEL_OUT = mxCreateDoubleMatrix(6, 1, mxREAL); 

    
/*  Check the dimensions of p.  */
  m = mxGetM(P_IN); 
  n = mxGetN(P_IN);
  if (!mxIsDouble(P_IN) || mxIsComplex(P_IN) || 
	   (MAX(m,n) > MAX_NP) || (MIN(m,n) != 1)) { 
	  mexErrMsgTxt(" Input p must be a real vector."); 
  } 
  np = MAX(m,n);

/*  Check the dimensions of u.  */
/*  Input u includes fdata.  */
  m = mxGetM(U_IN); 
  n = mxGetN(U_IN);
  if (!mxIsDouble(U_IN) || mxIsComplex(U_IN) || 
	   (MAX(m,n) > MAX_NI+MAX_FDATA) || (MIN(m,n) != 1)) { 
	  mexErrMsgTxt(" Input u must be a real vector."); 
  } 
  ni = MAX(m,n)-MAX_FDATA;

/* Assign pointers to the various parameters */ 
  xd = mxGetPr(XD_OUT);
  accel = mxGetPr(ACCEL_OUT);
  
  p = mxGetPr(P_IN); 
  u = mxGetPr(U_IN); 
  x = mxGetPr(X_IN);

/* Access the elements of the cell structure */

/*  p0oe  */
  subs[0]=0;
  subs[1]=0;
  index = mxCalcSingleSubscript(C_IN, ndim, subs);
  cell_ptr = mxGetCell(C_IN, index);
  p0oe = mxGetPr(cell_ptr);

/*  ipoe  */
  subs[0]=1;
  subs[1]=0;
  index = mxCalcSingleSubscript(C_IN, ndim, subs);
  cell_ptr = mxGetCell(C_IN, index);
  ipoe = mxGetPr(cell_ptr);

/*  ims  */
  subs[0]=2;
  subs[1]=0;
  index = mxCalcSingleSubscript(C_IN, ndim, subs);
  cell_ptr = mxGetCell(C_IN, index);
  ims = mxGetPr(cell_ptr);

/*  skip imo  */  

/*  imc  */
  subs[0]=4;
  subs[1]=0;
  index = mxCalcSingleSubscript(C_IN, ndim, subs);
  cell_ptr = mxGetCell(C_IN, index);
  imc = mxGetPr(cell_ptr);

/*  x0  */
  subs[0]=5;
  subs[1]=0;
  index = mxCalcSingleSubscript(C_IN, ndim, subs);
  cell_ptr = mxGetCell(C_IN, index);
  x0 = mxGetPr(cell_ptr);
        
/*  u0  */
  subs[0]=6;
  subs[1]=0;
  index = mxCalcSingleSubscript(C_IN, ndim, subs);
  cell_ptr = mxGetCell(C_IN, index);
  u0 = mxGetPr(cell_ptr);
        
//  Skip the fdata contained in c, because fdata was appended  
//  to u to accommodate the numerical integration.  
        
/*  fdata has been appended to u.  */
  for (j=ni;j<ni+MAX_FDATA;j++) {
    fdata[j-ni] = u[j];
  }
        
/*  Do the actual computations in a function subroutine  */
  nldyn_eqs(xd,accel,p,u,x,p0oe,ipoe,ims,imc,x0,u0,fdata); 

  return;
}
