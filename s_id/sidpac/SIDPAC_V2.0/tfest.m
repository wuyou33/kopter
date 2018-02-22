function [y,num,den,p,crb,s2,zr,xr,f,cost] = tfest(u,z,t,nord,dord,w)
%
%  TFEST  Transfer function parameter estimation using equation-error in the frequency domain.
%
%  Usage: [y,num,den,p,crb,s2,zr,xr,f,cost] = tfest(u,z,t,nord,dord,w);
%
%  Description:
%
%    Estimates the parameters for a constant coefficient 
%    single-input, single-output (SISO) transfer function
%    model with numerator order nord and denominator order dord.
%    The parameter estimation uses the equation-error formulation
%    with complex least squares regression in the frequency domain.
%
%  Input:
%    
%       u = measured input vector time series.
%       z = measured output vector time series.
%       t = time vector.
%    nord = transfer function model numerator order.
%    dord = transfer function model denominator order.
%       w = frequency vector, rad/sec.
%
%  Output:
%
%    y    = model output vector time series.
%    num  = vector of numerator parameter estimates in descending order.
%    den  = vector of denominator parameter estimates in descending order.
%    p    = vector of parameter estimates.
%    crb  = estimated parameter covariance matrix.
%    s2   = equation-error model fit error variance estimate.
%    zr   = complex dependent variable vector for the linear regression.
%    xr   = complex regressor matrix for the linear regression.
%    f    = frequency vector for the complex Fourier transformed data, Hz.
%    cost = value of the cost for the complex least squares estimation.
%

%
%    Calls:
%      cvec.m
%      fint.m
%      tfregr.m
%      lesq.m
%      tfsim.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%     02 Sept 1997 - Created and debugged, EAM.
%     02 Mar  2000 - Allow row or column vector w input, EAM.
%     22 Dec  2004 - Modified to handle improper transfer functions, EAM.
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
u=u(:,1);
z=z(:,1);
t=t(:,1);
w=cvec(w);
%
%  Compute the zoom Fourier transforms.
%
U=fint(u,t,w);
Z=fint(z,t,w);
f=w/(2*pi);
%
%  Arrange the data for the complex least squares estimation.
%
[zr,xr]=tfregr(U,Z,nord,dord,w);
%
%  Least squares solution, including the parameter covariance 
%  matrix, crb, and the model error variance estimate, s2.
%
[yr,p,crb,s2]=lesq(xr,zr);
%
%  Unscramble the parameter vector.
%
num=p(1:nord+1)';
den=[1,p(nord+2:nord+1+dord)'];
%
%  Time domain simulated output.
%  This calculation is not possible 
%  if the transfer function is improper.  
%  In that case, set the time domain 
%  simulated output to zero.
%
if dord > nord
  y=tfsim(num,den,0,u,t);
else
  y=zeros(length(t),1);
end
%
%  Compute the cost.  Use the real 
%  part to omit any imaginary parts 
%  present due to round-off errors.  
%
cost=0.5*real((zr-yr)'*(zr-yr));
return
