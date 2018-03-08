%
%  AVDS_MATLAB_SETUP  Adds AVDS-to-MATLAB toolbox files to the MATLAB path.  
%
%  Usage: avds_matlab_setup;
%
%  Description:
%
%    Modifies the path to include the toolbox 
%    for data exchange between AVDS and MATLAB.  
%
%  Input:
%
%    None
%
%  Output:
%
%    None
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      26 Sep 2003 - Created and debugged, EAM.
%
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
ToolboxPath='C:\Program Files\AVDS\Utilities\MATLABToolbox\Toolbox';
addpath(ToolboxPath);
ToolboxHelpPath=strcat(ToolboxPath,'\Help');
addpath(ToolboxHelpPath);
return
