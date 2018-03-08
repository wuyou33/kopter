function [x,xhist] = solve(fname,x0,c,del,tol,ifd)
%
%  SOLVE  Solves a set of nonlinear algebraic equations using modified Newton-Raphson.  
%
%  Usage: [x,xhist] = solve(fname,x0,c,del,tol,ifd);
%
%  Description:
%
%    Solves a set of nonlinear equations arranged so each nonlinear
%    equation is set equal to zero.  The file containing
%    the function descriptions is fname.  Modified Newton-Raphson
%    iterations are used to arrive at the solution.  
%
%  Input:
%    
%   fname = name of the file that computes the system outputs.
%      x0 = parameter vector initial condition.
%       c = vector of constants passed to fname.
%     del = vector of parameter perturbations in fraction of nominal value.
%     tol = distance in parameter space that defines convergence.
%     ifd = finite difference method flag:
%           = 1 for central differences.
%           = 0 for forward differences.
%
%  Output:
%
%        x = minimizing parameter vector.
%    xhist = sequence of parameter vectors.
%

%
%    Calls:
%      grad.m
%      cnvrg.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      24 Apr 1995 - Created and debugged, EAM.
%      13 Nov 2001 - Modified step change computation to use SVD, EAM.
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
maxloops=100;
nloops=0;
lstop=0;
x=x0;
f=eval([fname,'(x,c)']);
xhist=zeros(length(x0),maxloops);
while nloops<maxloops & lstop==0,
  nloops=nloops + 1;
  xhist(:,nloops)=x;
  xp=x;
  fp=f;
%
%  Follow the gradient.
%
  lhs=-f;
  dfdp=grad(fname,x,c,del,ifd);
%
%  dx=dfdp\lhs;
%
%  Use singular value decomposition 
%  for numerical robustness to ill-conditioned
%  dfdp matrices.  
%
  [m,n]=size(dfdp);
  [U,S,V]=svd(dfdp,0);
  sv=diag(S);
  svmax=S(1,1);
  svlim=max(size(dfdp))*eps;
  for j=1:n,
    if S(j,j)/svmax < svlim
      S(j,j)=0.0;
    else
      S(j,j)=1/S(j,j);
    end
  end
  dfdpi=V*S*U';
  dx=dfdpi*lhs;
%
%  Add dx to x and re-evaluate the function.
%
  x=x + dx;
  f=eval([fname,'(x,c)']);
%
%  Check for convergence.
%
  lstop=cnvrg(f,x,fp,xp,tol);
end
if lstop==1
  fprintf('\n\n CONVERGENCE CRITERIA SATISFIED \n\n');
else
  fprintf('\n\n EXIT ON MAXIMUM ITERATION COUNT, nloops = %4.0f \n\n',nloops);
end
xhist=xhist(:,[1:nloops]);
return
