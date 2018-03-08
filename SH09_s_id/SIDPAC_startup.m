    %
%  STARTUP  Set-up for SIDPAC.  
%
%  Usage: startup;
%
%  Description:
%
%    Modifies the MATLAB search path to include 
%    SIDPAC version 2.0 software.  This script 
%    is automatically executed when MATLAB is started.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      31 Oct 2005 - Created and debugged, EAM.
%      04 Nov 2005 - Modified for SIDPAC version 2.0, EAM.
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
%  ParentDir is the directory containing SIDPAC.  
%  Note that this directory will be named 
%  SIDPAC_V2.0 by default.
%
ParentDir=pwd;
if ispc
    path(path,[ParentDir,'\SIDPAC_V2.0']),
    path(path,[ParentDir,'\SIDPAC_V2.0\GUI_V1.0']),
    path(path,[ParentDir,'\SIDPAC_V2.0\Text_Examples']),
    path(path,[ParentDir,'\SIDPAC_V2.0\F16_NLS_V1.1']),
    path(path,[ParentDir,'\SIDPAC_V2.0\Demos']),

elseif isunix
    path(path,[ParentDir,'/SIDPAC_V2.0']),
    path(path,[ParentDir,'/SIDPAC_V2.0/GUI_V1.0']),
    path(path,[ParentDir,'/SIDPAC_V2.0/Text_Examples']),
    path(path,[ParentDir,'/SIDPAC_V2.0/F16_NLS_V1.1']),
    path(path,[ParentDir,'/SIDPAC_V2.0/Demos']),
end

clear ParentDir;
return
