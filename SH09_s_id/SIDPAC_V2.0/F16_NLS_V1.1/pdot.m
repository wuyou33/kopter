function pdot = pdot(pa,pc)
%
%  PDOT  Computes rate of change of power level with time.  
%
%  Usage: pdot = pdot(pa,pc);
%
%  Description:
%
%    Computes the rate of change of power level 
%    with time, using a first order lag.  
%
%  Input:
%    
%     pa = actual power level, percent.
%     pc = commanded power level, percent.  
%
%  Output:
%
%   pdot = rate of change of power level, percent/sec.
%

%
%    Calls:
%      rtau.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      19 Feb 1995 - Created and debugged, EAM.
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
if pc>=50.0
  if pa>=50.0
    pi=pc;
    rt=5.0;
  else
    pi=60.0;
    rt=rtau(pi-pa);
  end
else
  if pa>=50.0
    pi=40.0;
    rt=5.0;
  else
    pi=pc;
    rt=rtau(pi-pa);
  end
end
pdot=rt*(pi-pa);
return
