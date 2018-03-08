function r = corrcoefs(x)
%
%  CORRCOEFS  Calculates the correlation coefficient matrix.
%
%  Usage: r = corrcoefs(x);
%
%  Description:
%
%    Calculates the correlation coefficient matrix for input data matrix x.  
%    The input x is a matrix of column vector data, where the correlation 
%    coefficients for each column with all the others (including itself)
%    are to be calculated.  This routine works for real or complex data.  
%
%
%  Input:
%    
%      x = matrix of column vector data.
%
%  Output:
%
%      r = matrix of correlation coefficients, -1 <= r(i,j) <= 1.
%
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      12 July 2006 - Created and debugged, EAM.
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
%  Treatment is different for real and complex data.  
%
if isreal(x)
  r=corrcoef(x);
else
%
%  Stack the real and imaginary parts of complex data
%  before computing the correlation coefficients.
%
  xrc=[real(x);imag(x)];
  r=corrcoef(xrc);
end
return
