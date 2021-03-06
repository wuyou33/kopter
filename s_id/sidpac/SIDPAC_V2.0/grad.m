function dfdp = grad(fname,p,c,del,ifd)
%
%  GRAD  Finds the gradient of a vector function using finite differences.  
%
%  Usage: dfdp = grad(fname,p,c,del,ifd);
%
%  Description:
%
%    Computes the gradient for a vector function
%    using forward or central finite differences.
%    The vector function is specified in the file named fname.  
%
%  Input:
%
%    fname = name of the file that computes the vector function values.
%        p = vector of parameter values.
%        c = vector of constants passed to fname.
%      del = vector of parameter perturbations in fraction of nominal value.
%      ifd = 1 for central differences.
%            0 for forward differences.
%
%  Output:
%
%    dfdp = Jacobian matrix of sensitivities: 
%
%           [df/dp(1),df/dp(2),...,df/dp(np)].
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      24 Apr 1995 - Created and debugged, EAM.
%
%
%  Copyright (C) 2006  Eugene A. Morelli
%
%
%  This program carries no warranty, not even the implied 
%  warranty of merchantability or fitness for a particular purpose.  
%
%  Please email bug reports or suggestions for improvements to:
%
%      e.a.morelli@nasa.gov
%
f=eval([fname,'(p,c)']);
nf=length(f);
np=length(p);
dfdp=zeros(nf,np);
po=p;
del=abs(del);
mindp=1.0e-02;
if ifd==1 
  for j=1:np,
    p=po;
    if abs(p(j)) > mindp
      dp=abs(del(j)*po(j));
    else
      dp=mindp;
    end
    dp=0.5*dp;
    p(j)=po(j) + dp;
    f1=eval([fname,'(p,c)']);
    p(j)=po(j) - dp;
    f0=eval([fname,'(p,c)']);
    dfdp(:,j)=(f1-f0)/(2*dp);
  end
else
  f0=eval([fname,'(p,c)']);
  for j=1:np,
    p=po;
    if abs(p(j)) > mindp
      dp=abs(del(j)*po(j));
    else
      dp=mindp;
    end
    p(j)=po(j) + dp;
    f1=eval([fname,'(p,c)']);
    dfdp(:,j)=(f1-f0)/dp;
  end
end
return
