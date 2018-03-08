%
%  DCMP_DEMO  Demonstrates data compatibility analysis using a SIDPAC GUI.  
%
%  Usage: dcmp_demo;
%
%  Description:
%
%    Demonstrates data compatibility analysis 
%    using flight test data from the NASA
%    F-18 High Alpha Research Vehicle (HARV) and 
%    the SIDPAC GUI for data compatibility.  
%
%  Input:
%
%    None
%
%  Output:
%
%    graphics:
%      2D plots
%      data compatibility GUI
%

%
%    Calls:
%      harv2sid.m
%      dcmp_gui.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      29 Oct 2000 - Created and debugged, EAM.
%      01 Jan 2006 - Updated the code, EAM.
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
%  Load the flight test data.
%
load 'dcmp_demo_data.mat';
whos
%
%  Convert the data to standard format.
%
[fdata,fds]=harv2sid(fdata_153b);
%
%  Start the data compatibility GUI.
%
dcmp_gui
fprintf('\n\n End of demonstration \n\n')
return
