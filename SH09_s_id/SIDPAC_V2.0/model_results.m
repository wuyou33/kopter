function model_results(fname,p,serr)
%
%  MODEL_RESULTS  Exports linear regression modeling results to a file.
%
%  Usage: model_results(fname,p,serr);
%
%  Description:
%
%    Writes the modeling results p and standard errors 
%    serr to an ASCII text file called fname, with 
%    the data delimited by spaces.  The data in   
%    output file fname can be read directly into an Excel 
%    spreadsheet using the File\Open command.  From there, 
%    the data can be cut and pasted into a Word table or an 
%    Excel table template, using the Paste Special command 
%    and selecting only the value for pasting, to preserve
%    the template formatting.  The resulting Excel table 
%    can be cut and pasted directly into a Word document.  
%
%
%  Input:
%    
%   fname = name of ASCII output data file.
%       p = parameter vector.
%    serr = vector of standard errors.
%
%
%  Output:
%
%     ASCII file called fname
%
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      18 Feb  2002 - Created and debugged, EAM.
%      01 June 2005 - Changed crb input to serr, EAM.
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
p=cvec(p);
np=length(p);
%
%  Loop over the model terms.
%
A=[[1:1:np]',p,serr];
dlmwrite(fname,A,' ');
fprintf('\n Data written to file %s \n\n',fname)
return
