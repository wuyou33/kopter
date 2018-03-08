function fds = fdata2fds(fdata)
%
%  FDATA2FDS  Converts from standard fdata matrix format to standard fds data structure format.  
%
%  Usage: fds = fdata2fds(fdata);
%
%  Description:
%
%    Stores the standard SIDPAC array (fdata) to the  
%    standard SIDPAC flight data structure (fds).
%
%  Input:
%    
%    fdata = flight data array in standard configuration.
%
%  Output:
%
%    fds = flight data structure in standard configuration.
%

%
%    Calls:
%      fds_init.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      19 Apr 2004 - Created and debugged, EAM.
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

%
%  Initialize the data structure.
%
fds=fds_init;
%
%  Assign the data fields in fds.
%
%  The time vector t starts at zero and 
%  has constant sampling intervals.
%
t=fdata(:,1);
npts=length(t);
t=t-t(1);
dt=1/round(1/(t(2)-t(1)));
t=[0:dt:(npts-1)*dt]';
%
%  Store the fdata array 
%  and time vector in fds.
%
fds.fdata=fdata;
fds.t=t;
return
