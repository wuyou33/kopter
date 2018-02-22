function dydp = senest(dsname,p,u,t,x0,c,del,no,ifd)
%
%  SENEST  Computes sensitivity estimates using finite differences.  
%
%  Usage: dydp = senest(dsname,p,u,t,x0,c,del,no,ifd);
%
%  Description:
%
%    Computes the output sensitivities for maximum likelihood 
%    estimation using forward or central finite differences.
%    The dynamic system is specified in the file named dsname.  
%    Inputs del, no, and ifd are optional.  
%
%  Input:
%
%    dsname = name of the file that computes the system outputs.
%         p = vector of parameter values.
%         u = control vector time history.
%         t = time vector.
%        x0 = state vector initial condition.
%         c = vector of constants passed to dsname.
%       del = vector of parameter perturbations 
%             in fraction of nominal value (optional).
%        no = number of outputs (optional).
%       ifd = finite difference method flag (optional):
%             = 1 for central differences (default).
%             = 0 for forward differences.
%
%  Output:
%
%    dydp = matrix of output sensitivities: 
%
%           [dy/dp(1),dy/dp(2),...,dy/dp(np)].
%

%
%    Calls:
%      cvec.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      18 Jan 1997 - Created and debugged, EAM.
%      24 Aug 2004 - Updated and streamlined code, EAM.
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
npts=length(t);
np=length(p);
if nargin < 9 | isempty(ifd)
  ifd=1;
end
p0=p;
if nargin < 8 | isempty(no)
  y0=eval([dsname,'(p0,u,t,x0,c)']);
  no=size(y0,2);
end
dydp=zeros(npts,no*np);
if nargin < 7 | isempty(del)
  del=0.01*ones(np,1);
end
del=abs(cvec(del));
if length(del)~=np
  del=del(1)*ones(np,1);
end
mindp=1.0e-04;
%
%  Define the parameter perturbations.
%
dp=zeros(np,1);
for j=1:np,
  if abs(p0(j)) > mindp
    dp(j)=abs(del(j)*p0(j));
  else
    dp(j)=mindp;
  end
end
%
%  Finite difference calculation for the 
%  output sensitivities.  
%
if ifd==1 
  for j=1:np,
    p=p0;
    p(j)=p0(j) + 0.5*dp(j);
    y1=eval([dsname,'(p,u,t,x0,c)']);
    p(j)=p0(j) - 0.5*dp(j);
    y0=eval([dsname,'(p,u,t,x0,c)']);
    dydp(:,[(j-1)*no+1:j*no])=(y1-y0)/dp(j);
  end
else
  if ~exist('y0','var')
    y0=eval([dsname,'(p0,u,t,x0,c)']);
  end
  for j=1:np,
    p=p0;
    p(j)=p0(j) + dp(j);
    y1=eval([dsname,'(p,u,t,x0,c)']);
    dydp(:,[(j-1)*no+1:j*no])=(y1-y0)/dp(j);
  end
end
return
