function yi = intsinc(y,dt,ti)
%
%  INTSINC  Interpolates band-limited time series data, using the sampling theorem.  
%
%  Usage: yi = intsinc(y,dt,ti);
%
%
%  Description:
%
%    Interpolates band-limited data 
%    using the sampling theorem.  
%
%  Input:
%
%    y = vector of function values.  
%   dt = sampling interval for y, sec.
%   ti = vector of interpolation times.  
%
%  Output:
%
%    yi = vector of interpolated values of y 
%         at the times specified in vector ti. 
%
%

%
%    Calls:
%      cvec.m
%      sincs.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      14 Oct  2003 - Created and debugged, EAM.
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
y=cvec(y);
%
%  Number of data points.  
%
ny=length(y);
%
%  Spacing of the data points.  
%
dt=abs(dt(1));
ti=cvec(ti);
%
%  Number of interpolation points.  
%
ni=length(ti);
yi=zeros(ni,1);
%
%  For each data point, use a convolution 
%  with the sincs function to find the 
%  interpolated value.  This is the implementation 
%  of the sampling theorem.  Accuracy degrades 
%  slightly near the endpoints, because data 
%  is absent on the side near the endpoint.  
%
for j=1:ni,
  tni=(ti(j)/dt)*ones(ny,1)-[0:ny-1]';
  w=sincs(pi*tni);
  yi(j)=y'*w;
end
return
