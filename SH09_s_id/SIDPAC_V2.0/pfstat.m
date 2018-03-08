function F = pfstat(x,xc,z)
%
%  PFSTAT  Computes the partial F statistic for hypothesis testing in model structure determination.  
%
%  Usage: F = pfstat(x,xc,z);
%
%  Description:
%
%    Computes the partial F statistic for adding a regressor xc
%    to a linear regression model for z using the regressors in x.
%    The output is the F statistic for hypothesis testing.
%
%  Input:
%    
%     x = matrix of regressor column vectors.
%    xc = vector regressor column vector candidate for the model.
%     z = measured output vector.
%
%  Output:
%
%    F = F statistic for hypothesis testing.
%

%
%    Calls:
%      lesq.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      21 July 1996 - Created and debugged, EAM.
%      09 May  2001 - Changed xc to a single vector, 
%                     updated partial F calculation, EAM.
%      20 Sept 2004 - Updated for SIDPAC version 2.0, EAM.
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
[npts,nr]=size(x);
%[npts,nc]=size(xc);
xc=xc(:,1);
%[y,p,cvar,s2]=lesq(x,z);
%ss=z'*z - p'*x'*z;
[yc,pc,crbc,s2c,xmc]=lesq([x,xc],z);
ssc=z'*z - pc'*xmc'*z;
%
%  Both numerator and denominator of F estimate the model variance
%  when the regressors in xc are not explanatory.  Use the 
%  expression from NASA TP-1916, so the partial F value 
%  is correct for real or complex numbers.  
%
%F=((ss - ssc)/nc)/(ssc/(npts-nr-nc));
n=nr+1;
F=pc(n)*pc(n)/crbc(n,n);
return
