function [xo,a,m] = gsorth(x,nof)
%
%  GSORTH  Generates orthogonal regressors using Gram Schmidt orthogonalization.  
%
%  Usage: [xo,a,m] = gsorth(x,nof);
%
%  Description:
%
%    Orthogonalizes a set of vectors in matrix x, 
%    using a forward Gram-Schmidt vector orthogonalization
%    technique.  The output m contains the index of the
%    orthogonal function for which the orthogonality 
%    is intact for all preceding orthogonal functions.
%    If the optional input nof is provided, then the 
%    first nof columns of x are assumed to be 
%    orthogonalized already, and the remaining columns 
%    of x are orthogonalized relative to x(:,[1:nof]). 
%    When nof is omitted or set equal to 1, the relationship
%    between x and xo is given by:
%
%                   x=xo*(eye(n,n)+a');
%    or
%                   xo=x*inv(eye(n,n)+a');
%     
%    where n=size(x,2).  
%
%  Input:
%    
%      x = matrix of column vectors.
%    nof = number of orthogonalized columns in x (optional, default=1).  
%
%  Output:
%
%    xo = matrix of orthogonal column vectors.
%     a = matrix of orthogonalization constants.
%     m = maximum usable orthogonal function index.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      3 Sep 2001 - Created and debugged, EAM.
%     20 Sep 2002 - Added m output, EAM.
%     17 Dec 2002 - Added optional nof input, EAM.
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
[npts,n]=size(x);
%
%  Check for the nof input.
%
if nargin < 2
  nof=1;
end
%
%  Start with the a priori orthogonal basis.  If 
%  nof input is omitted, the first column of x 
%  is the first orthgonal vector.  
%
xo=x;
%
%  Finished if n <= nof.
%
if n > nof
%
%  Loop to orthogonalize the kth vector
%  with respect to all the previously 
%  orthogonalized vectors.  
%
  a=zeros(n,n);
%
%  Loop on number of vectors in x.
%
  for k=nof+1:n,
%
%  Loop on past orthogonalized vectors.
%
    for j=1:k-1,
      a(k,j)=(xo(:,j)'*x(:,k))/(xo(:,j)'*xo(:,j));
    end
    xo(:,k)=x(:,k)-xo*a(k,:)';
  end
%
%  Check for non-orthogonality.
%
  ztol=1.0e-08;
  xotxo=zeros(n,n);
  m=n;
  for i=1:n,
    for j=i+1:n,
      xotxo(i,j)=xo(:,i)'*xo(:,j);
%
%  For every pair of non-orthogonal functions, record the 
%  index of the latest one as the maximum orthogonal function 
%  index, m.
%
      if xotxo(i,j) > ztol
        if j <= m
          m=j-1;
        end
%        fprintf('\n Non-orthogonal measure: ');
%        fprintf(' xo(:,%2i) ''* xo(:,%2i) = %13.6e \n\n',i,j,xotxo(i,j));
      end
    end
  end
end
return
