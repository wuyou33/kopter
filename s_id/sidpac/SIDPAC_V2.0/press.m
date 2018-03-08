function pss = press(x,z)
%
%  PRESS  Computes predicted sum of squares metric.  
%
%  Usage: pss = press(x,z);
%
%  Description:
%
%    Computes the predicted sum of squares (PRESS) metric 
%    for fitting the linear regression model y=x*p to measured z
%    using the regressor matrix x.  The output is the PRESS 
%    statistic for model structure determination.
%
%  Input:
%    
%     x = matrix of regressor column vectors.
%     z = measured dependent variable vector.
%
%  Output:
%
%   pss = predicted sum of squares (PRESS) metric.
%
%       PRESS = sum([z(i)-y(i|x(1),x(2),...,x(i-1),x(i+1),...,x(N))]^2)
% 

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      19 Apr  2000 - Created and debugged, EAM.
%      10 Jan  2006 - Modified to use the PRESS defining expression, EAM.
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
%  Compute PRESS from the definition.
%
pss=0;
for i=1:npts,
%
%  Parameter estimate without the ith data point.
%
  pi=inv(real(x'*x-x(i,:)'*x(i,:)))*(real(x'*z-x(i,:)'*z(i)));
%
%  Prediction at the ith data point.
%
  yi=x(i,:)*pi;
%
%  Use the real part to remove 
%  imaginary round-off error 
%  when the data are complex. 
%
  pss=pss + real((z(i)-yi)'*(z(i)-yi));
end
return
