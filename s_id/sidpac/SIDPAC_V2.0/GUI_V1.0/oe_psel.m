function coe = oe_psel(fdata,runopt,dopt,p0,ip,ims,imo,x0,u0,plab)
%
%  OE_PSEL  Implements settings for output-error parameter estimation.  
%
%  Usage: coe = oe_psel(fdata,runopt,dopt,p0,ip,ims,imo,x0,u0,plab);
%
%  Description:
%
%    Initializes and selects the states, outputs,
%    and dynamic model parameters to be estimated  
%    for output-error parameter estimation. 
%
%  Input:
%    
%   fdata = flight data array in standard configuration.
%  runopt = dynamic model flag (optional):
%           = 1 for longitudinal dynamics (default)
%           = 2 for lateral dynamics
%   dopt  = dimensional parameters flag:
%           = 1 for dimensional parameters (default) 
%           = 2 for non-dimensional parameters
%      p0 = initial values for the estimated 
%           parameter vector poe (optional).  
%      ip = index vector indicating which parameters 
%           are to be estimated (optional).  
%     ims = index vector indicating which states 
%           will use measured values (optional).
%     imo = index vector indicating which model outputs
%           will be calculated (optional).
%      x0 = initial state vector.
%      u0 = initial control vector.
%    plab = labels for the model parameters.
%
%  Output:
%
%     coe = cell structure:
%           coe.p0     = p0     = vector of initial parameter values.
%           coe.ip     = ip     = index vector to select estimated parameters.
%           coe.ims    = ims    = index vector to select measured states.
%           coe.imo    = imo    = index vector to select model outputs.
%           coe.x0     = x0     = initial state vector.
%           coe.u0     = u0     = initial control vector.
%                                 coefficients to be modeled.
%           coe.fdata  = fdata  = standard array of measured flight data, 
%                                 geometry, and mass/inertia properties.  
%           coe.plab   = plab   = labels for the parameters.
%           coe.runopt = runopt = dynamic model flag:
%                                 = 1 for longitudinal dynamics
%                                 = 2 for lateral dynamics
%           coe.dopt   = dopt   = dimensional parameters flag:
%                                 = 1 for non-dimensional parameters 
%                                 = 2 for dimensional parameters
%

%
%    Calls:
%      massprop.m
%      lesq.m
%      deriv.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      06 Aug  2006 - Created and debugged, EAM.
%
%  Copyright (C) 2006  Eugene A. Morelli
%
%  This program carries no warranty, not even the implied 
%  warranty of merchantability or fitness for a particular purpose.  
%
%  Please email bug reports or suggestions for improvements to:
%
%      e.a.morelli@nasa.gov
%

%
%  Default values are longitudinal non-dimensional derivatives.
%
%  runopt = 1 for longitudinal dynamics
%         = 2 for lateral dynamics
%
if nargin < 2
  runopt=1;
end
%
%  dopt = 1 for non-dimensional parameters
%       = 2 for dimensional parameters
%
if nargin < 3
  dopt=1;
end
%
%  Initial values for the parameters.
%
if nargin < 4
  if runopt==1
    ns=4;
    nc=3;
    no=6;
    p0=zeros(ns*(ns+nc)+no,1);
    np=length(p0);
%
%  ip element = 1 to estimate the corresponding parameter.
%             = 0 to exclude the corresponding parameter from the estimation.
    ip=zeros(np,1);
%          V  alpha  q  the  de  df  bias
    indx=[      9,  10,      12,      14,...
               16,  17,      19,      21,...
                                      28,...
                                 34]';
%          V  alpha  q  the  ax  az
  else
    ns=4;
    nc=3;
    no=5;
    p0=zeros(ns*(ns+nc)+no,1);
    np=length(p0);
%
%  ip element = 1 to estimate the corresponding parameter.
%             = 0 to exclude the corresponding parameter from the estimation.
    ip=zeros(np,1);
%         beta  p   r   phi  da  dr  bias
    indx=[  1,      3,            6,   7,...
            8, 9,  10,       12, 13,  14,...
           15, 16, 17,       19, 20,  21,...
                                      28,...
                             33]';
%         beta  p   r   phi  ay
  end
  ip(indx)=ones(length(indx),1);
end
%
%  Labels for the model parameters.
%
if runopt==1
  if dopt==1
    plab=[ 'CXV ';'CXa ';'CXq ';'a14 ';'CXde';'CXdf';'CXo ';...
           'CZV ';'CZa ';'CZq ';'a24 ';'CZde';'CZdf';'CZo ';...
           'CmV ';'Cma ';'Cmq ';'a34 ';'Cmde';'Cmdf';'Cmo ';...
           'a41 ';'a42 ';'a43 ';'a44 ';'b41 ';'b42 ';'theo';...
           'Vb  ';'ab  ';'qb  ';'theb';'axb ';'azb '];
  else
    plab=[ 'XV  ';'Xa  ';'Xq  ';'a14 ';'Xde ';'Xdf ';'Xo  ';...
           'ZV  ';'Za  ';'Zq  ';'a24 ';'Zde ';'Zdf ';'Zo  ';...
           'MV  ';'Ma  ';'Mq  ';'a34 ';'Mde ';'Mdf ';'Mo  ';...
           'a41 ';'a42 ';'a43 ';'a44 ';'b41 ';'b42 ';'theo';...
           'Vb  ';'ab  ';'qb  ';'theb';'axb ';'azb '];
  end
else
  if dopt==1
    plab=[ 'CYb ';'CYp ';'CYr ';'a14 ';'CYda';'CYdr';'CYo ';...
           'C1b ';'C1p ';'C1r ';'a24 ';'C1da';'C1dr';'C1o ';... 
           'Cnb ';'Cnp ';'Cnr ';'a34 ';'Cnda';'Cndr';'Cno ';...
           'a41 ';'a42 ';'a43 ';'a44 ';'b41 ';'b42 ';'phio';...
           'bb  ';'pb  ';'rb  ';'phib';'ayb '];
  else
    plab=[ 'Yb  ';'Yp  ';'Yr  ';'a14 ';'Yda ';'Ydr ';'Yo  ';...
           'Lb  ';'Lp  ';'Lr  ';'a24 ';'Lda ';'Ldr ';'Lo  ';... 
           'Nb  ';'Np  ';'Nr  ';'a34 ';'Nda ';'Ndr ';'No  ';...
           'a41 ';'a42 ';'a43 ';'a44 ';'b41 ';'b42 ';'phio';...
           'bb  ';'pb  ';'rb  ';'phib';'ayb '];
  end
end
%
%
%  ims = 1 to use measured values 
%          for the corresponding state.
%      = 0 to use computed model values 
%          for the corresponding state.  
%
if nargin < 6
  if runopt==1
%      x = [   vt, beta, alpha,   p,    q,    r,  phi,  the,  psi]
    ims=[       0,    1,    0,    1,    0,    1,    1,    1,    1];
  else
%      x = [   vt, beta, alpha,   p,    q,    r,  phi,  the,  psi]
    ims=[       1,    0,    1,    0,    1,    0,    1,    1,    1];
  end
end
%
%
%  imo = 1 to select the corresponding output
%          to be included in the model output.
%      = 0 to omit the corresponding output 
%          from the model output. 
%
if nargin < 7
  if runopt==1
%    y = [   vt,  alpha,  q,   the,  ax,   az ]
    imo=[     0,    1,    1,    1,    0,    1 ];
  else
%    y = [  beta,   p,    r,  phi,   ay ]
    imo=[     1,    1,    1,    1,    1 ];
  end
end
%
%   x0 = initial state vector.  
%
%    x = [vt,beta,alpha,p,q,r,phi,the,psi]'
%
dtr=pi/180;
if nargin < 8
  if runopt==1
    x0=[fdata(1,2),fdata(1,[4,6,9])*dtr]';
  else
    x0=[fdata(1,[3,5,7,8])*dtr]';
  end
end
%
%   u0 = initial control vector.  
%
%    u = [el,ail,rdr]'
%
if nargin < 9
  if runopt==1
    u0=[fdata(1,[14,17])*dtr,1]';
  else
    u0=[fdata(1,[15,16])*dtr,1]';
  end
end
%
%  Add constants for models with non-dimensional parameters.  
%
g=32.174;
coe.vo=mean(fdata(:,2));
coe.vog=coe.vo/g;
coe.qbar=mean(fdata(:,27));
coe.qs=coe.qbar*fdata(1,77);
coe.qsc=coe.qs*fdata(1,79);
coe.c2v=fdata(1,79)/(2*coe.vo);
coe.qsb=coe.qs*fdata(1,78);
coe.b2v=fdata(1,78)/(2*coe.vo);
coe.sa=sin(mean(fdata(:,4)*dtr));
coe.ca=cos(mean(fdata(:,4)*dtr));
coe.dgdp=g*cos(mean(fdata(:,9)*dtr))/coe.vo;
coe.tt=tan(mean(fdata(:,9)*dtr));
coe.ct=cos(mean(fdata(:,9)*dtr));
[ci,mass,ixx,iyy,izz,ixz] = massprop(fdata);
coe.ci=ci;
coe.mass=mass;
%
%  Compute initial parameter estimates and state-space 
%  matrix elements using known quantities and 
%  the equation-error method.  
%
npts=size(fdata,1);
dt=1/round(1/(fdata(2,1)-fdata(1,1)));
if runopt==1
%
%  Assign the known constant terms.
%
%  Use equation-error parameter estimates for initial values.  
%
  if dopt==1
    [yZ,pZ,crbZ,s2Z] = lesq([fdata(:,4)*dtr,fdata(:,72),fdata(:,14)*dtr,ones(npts,1)],fdata(:,63));
    [ym,pm,crbm,s2m] = lesq([fdata(:,4)*dtr,fdata(:,72),fdata(:,14)*dtr,ones(npts,1)],fdata(:,65));
    p0(9)=pZ(1);
    p0(10)=pZ(2);
    p0(12)=pZ(3);
    p0(14)=pZ(4);
    p0(16:17)=pm(1:2);
    p0(19)=pm(3);
    p0(21)=pm(4);
  else
    [yZ,pZ,crbZ,s2Z] = lesq([fdata(:,[4,6,14])*dtr,ones(npts,1)],fdata(:,13));
    qd=deriv(fdata(:,6)*dtr,dt);
    [ym,pm,crbm,s2m] = lesq([fdata(:,[4,6,14])*dtr,ones(npts,1)],qd);
    p0(9)=pZ(1)/coe.vog;
%
%  Include the kinematic terms in  
%  the Xa and Zq parameters,
%  for better identifiability.  
%
    p0(2)=g;
    p0(10)=pZ(2)/coe.vog + 1;
    p0(12)=pZ(3)/coe.vog;
    p0(14)=pZ(4)/coe.vog;
    p0(16:17)=pm(1:2);
    p0(19)=pm(3);
    p0(21)=pm(4);
  end
%
%  Set known kinematic terms in the A matrix.
%
  p0(4)=-g;
  p0(24)=1;
else
%
%  Assign the known constant terms.
%
%  Use equation-error parameter estimates for initial values.  
%
  if dopt==1
    [yY,pY,crbY,s2Y] = lesq([fdata(:,[3,16])*dtr,ones(npts,1)],fdata(:,62));
    [y1,p1,crb1,s21] = lesq([fdata(:,3)*dtr,fdata(:,[71,73]),fdata(:,[15,16])*dtr,ones(npts,1)],fdata(:,64));
    [yn,pn,crbn,s2n] = lesq([fdata(:,3)*dtr,fdata(:,[71,73]),fdata(:,[15,16])*dtr,ones(npts,1)],fdata(:,66));
    p0(1)=pY(1);
    p0(6)=pY(2);
    p0(7)=pY(3);
    p0(8:10)=p1(1:3);
    p0(12:14)=p1(4:6);
    p0(15:17)=pn(1:3);
    p0(19:21)=pn(4:6);
  else
    [yY,pY,crbY,s2Y] = lesq([fdata(:,[3,16])*dtr,ones(npts,1)],fdata(:,12));
    pd=deriv(fdata(:,5)*dtr,dt);
    rd=deriv(fdata(:,7)*dtr,dt);
    [y1,p1,crb1,s21] = lesq([fdata(:,[3,5,7,15,16])*dtr,ones(npts,1)],pd);
    [yn,pn,crbn,s2n] = lesq([fdata(:,[3,5,7,15,16])*dtr,ones(npts,1)],rd);
    p0(1)=pY(1)/coe.vog;
%
%  Include the kinematic terms in the 
%  Yp and Yr parameters,
%  for better identifiability.  
%
    p0(2)=coe.sa;
    p0(3)=-coe.ca;
    p0(6)=pY(2)/coe.vog;
    p0(7)=pY(3)/coe.vog;
    p0(8:10)=p1(1:3);
    p0(12:14)=p1(4:6);
    p0(15:17)=pn(1:3);
    p0(19:21)=pn(4:6);
  end
%
%  Set the known kinematic terms in the A matrix.
%
  p0(4)=coe.dgdp;
  p0(23)=1;
  p0(24)=coe.tt;
end
%
%     coe = cell structure:
%           coe.p0     = p0     = vector of initial parameter values.
%           coe.ip     = ip     = index vector to select estimated parameters.
%           coe.ims    = ims    = index vector to select measured states.
%           coe.imo    = imo    = index vector to select model outputs.
%           coe.x0     = x0     = initial state vector.
%           coe.u0     = u0     = initial control vector.
%                                 coefficients to be modeled.
%           coe.fdata  = fdata  = standard array of measured flight data, 
%                                 geometry, and mass/inertia properties.  
%           coe.plab   = plab   = labels for the parameters.
%           coe.runopt = runopt = dynamic model flag:
%                                 = 1 for longitudinal dynamics
%                                 = 2 for lateral dynamics
%           coe.dopt   = dopt   = dimensional parameters flag:
%                                 = 1 for non-dimensional parameters 
%                                 = 2 for dimensional parameters
%
coe.p0=p0;
coe.ip=ip;
coe.ims=ims;
coe.imo=imo;
coe.x0=x0;
coe.u0=u0;
coe.fdata=fdata;
coe.plab=plab;
coe.runopt=runopt;
coe.dopt=dopt;
return
