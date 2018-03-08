function pf = peakfactor(y)
%
%  PEAKFACTOR  Computes the peak factor of a time series.  
%
%  Usage: pf = peakfactor(y);
%
%  Description:
%
%    Computes the relative peak factor for the input vector 
%    or matrix of column vectors y.  Relative peak factor is 
%    defined by:
%
%      pf = (max(y)-min(y))./(2*sqrt(2)*rms(y))
%
%    Relative peak factor for a single sinusoid equals 1.
%
%
%  Input:
%    
%     y = vector or matrix of column vector time histories.
%
%  Output:
%
%     pf = relative peak factor.
%
%

%
%    Calls:
%      rms.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      18 Mar 2003 - Created and debugged, EAM.
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
pf=(max(y)-min(y))./(2*sqrt(2)*rms(y));
return
