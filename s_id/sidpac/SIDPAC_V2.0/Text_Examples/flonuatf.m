function [Y,num,den] = flonuatf(p,U,w,x0,c)
%
%  FLONUATF  Frequency-domain longitudinal unsteady aerodynamics transfer function model file.  
%
%  Usage: [Y,num,den] = flonuatf(p,U,w,x0,c);
%
%  Description:
%
%    Model file for longitudinal unsteady aerodynamic
%    modeling from forced oscillation data, using a 
%    transfer function model in the frequency domain.
%
%  Input:
%
%     p = parameter vector.
%     U = input vector in the frequency domain.
%     w = frequency vector, rad/sec.
%    x0 = initial state vector.
%
%  For equation error formulation:
%     c = matrix of measured output vectors in the frequency domain = Z.
%
%  For output error formulation:
%     c = column vector of constants.
%
%
%  Output:
%
%       Y = matrix of model output vectors in the frequency domain.
%     num = transfer function numerator polynomial coefficients.
%     den = transfer function denominator polynomial coefficients.
%
%
np=length(p);
%
%  Model parameterization.
%
num=[p(1),p(2),p(3)];
den=[1,p(4)];
[no,maxnord]=size(num);
maxnord=maxnord-1;
%
%  Frequency vectors.
%
jay=sqrt(-1);
jw=jay*w;
w2=w.*w;
%
%  Input/Output data.
%
[nw,ni]=size(U);
U=cvec(U);
Y=zeros(nw,no);
%
%  Determine whether to use equation error or output error formulation.
%
if ~isreal(c)
%
%  Equation error.
%
  Z=c;
  Y=[-w2.*U,jw.*U,U]*num' - den(2)*Z;
else
%
%  Output error.
%
  denom=[jw,ones(nw,1)]*den';
  Y=([-w2.*U,jw.*U,U]*num')./denom;
end
return
