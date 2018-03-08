function [cost,y] = compcost(dsname,p,u,t,x0,c,z,rr,p0,M0)
%
%  COMPCOST  Computes the output-error cost function.  
%
%  Usage: [cost,y] = compcost(dsname,p,u,t,x0,c,z,rr,p0,M0);
%
%  Description:
%
%    Computes the maximum likelihood cost 
%    and the model output vector time history. 
%    The dynamic system is specified in the file
%    named dsname.  Inputs p0 and M0 are optional.  
%
%  Input:
%    
%    dsname = name of the file that computes the system outputs.
%         p = vector of parameter values.
%         u = control vector time history.
%         t = time vector.
%        x0 = state vector initial condition.
%         c = vector or data structure of constants passed to dsname.
%         z = measured output vector time history.
%        rr = discrete measurement noise covariance matrix estimate. 
%        p0 = vector of a priori parameter values (optional).
%        M0 = a priori inverse parameter covariance matrix (optional).
%
%  Output:
%
%       cost = cost function.
%          y = model output vector time history.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      24 Jan 1997 - Created and debugged, EAM.
%      28 Oct 2001 - Added p0 and crb0, EAM.
%      27 Oct 2005 - Changed crb0 input to M0, EAM.
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
[npts,no]=size(z);
np=length(p);
if nargin < 10 | isempty(M0)
  M0=zeros(np,np);
end
if nargin < 9 | isempty(p0)
  p0=zeros(np,1);
end
vv=inv(rr);
y=eval([dsname,'(p,u,t,x0,c)']);
cost=0.0;
v=z-y;
%
%  The operator .' means transpose without complex conjugation.
%
for i=1:npts,
  cost=cost + conj(v(i,:))*vv*v(i,:).';
end
%
%  Get rid of imaginary round-off error.
%
cost=0.5*real(cost);
%
%  Add the a priori contribution.
%
cost=cost + 0.5*(p-p0)'*M0*(p-p0);
return
