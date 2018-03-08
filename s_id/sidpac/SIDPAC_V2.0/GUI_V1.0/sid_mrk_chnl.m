function mlab = sid_mrk_chnl(lab,n)
%
%  SID_MRK_CHNL  Mark or clear a specified channel label. 
%
%  Usage: mlab = sid_mrk_chnl(lab,n);
%
%  Description:
%
%    Mark or clear the (abs(n))th channel label in lab, 
%    and store the result in mlab.
%
%  Input:
%
%     lab = cell array of channel labels.
%       n = flag for channel number to be marked or cleared:
%           if n=abs(n), mark the abs(n)th channel.
%           if n=-abs(n), clear the abs(n)th channel.
%
%
%  Output:
%
%    mlab = character array of channel labels 
%           with the abs(n)th channel marked or cleared.
%
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      22 Apr 2004 - Created and debugged, EAM.
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
%  Mark or clear the nth channel.
%
mlab=lab;
if n > 0
  name=char(lab(n));
  name(1)='*';
  mlab(n)=cellstr(name);
else
  n=abs(n);
  name(1)=' ';
  mlab(n)=cellstr(name);
end
return
