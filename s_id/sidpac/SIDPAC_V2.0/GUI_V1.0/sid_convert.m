%
%  SID_CONVERT  Converts units of the plotted data.  
%
%  Calling GUI: sid_gui.m
%
%  Usage: sid_convert;
%
%  Description:
%
%    Converts units for plotted data 
%    according to user input.
%
%  Input:
%    
%    handles.data.yp = plotted data.
%
%  Output:
%
%    handles.data.yp = plotted data with specified units.
%
%

%
%    Author:  Eugene A. Morelli
%
%    Calls:
%      sid_plot.m
%
%    History:  
%      23 Aug  2004 - Created and debugged, EAM.
%      20 Sept 2004 - Added double conversion error protection, EAM.
%      04 Aug  2006 - Updated for SIDPAC version 2.0, EAM.
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
%  Get the popup value.
%
ncnv=get(hObject,'Value');
%
%  Correlate popup value with conversion name.
%
cnvs=get(hObject,'String');
cnv=char(cnvs{ncnv});
yp=handles.data.yp;
ypunits=handles.units.yp;
%
%  Unit conversion command.  
%
%  The code prevents double conversion errors, 
%  which means, for example, that a conversion 
%  to radians is disallowed if the units
%  are already radians.  
%
switch cnv
  case 'deg to rad',
    if isempty(strfind(ypunits,'(rad)'))
      yp=yp*pi/180;
      ypunits=' (rad) ';
    end
  case 'rad to deg',
    if isempty(strfind(ypunits,'(deg)'))
      yp=yp*180/pi;
      ypunits=' (deg) ';
    end
  case 'ft to m'
    if isempty(strfind(ypunits,'(m)'))
      yp=yp*0.3048;
      ypunits=' (m) ';
    end
  case 'm to ft',
    if isempty(strfind(ypunits,'(ft)'))
      yp=yp/0.3048;
      ypunits=' (ft) ';
    end
  case 'ft to in',
    if isempty(strfind(ypunits,'(in)'))
      yp=yp*12;
      ypunits=' (in) ';
    end
  case 'in to ft',
    if isempty(strfind(ypunits,'(ft)'))
      yp=yp/12;
      ypunits=' (ft) ';
    end
  case 'm to mm',
    if isempty(strfind(ypunits,'(mm)'))
      yp=yp*1000;
      ypunits=' (mm) ';
    end
  case 'mm to m',
    if isempty(strfind(ypunits,'(m)'))
      yp=yp/1000;
      ypunits=' (m) ';
    end
  case 'cm to mm',
    if isempty(strfind(ypunits,'(mm)'))
      yp=yp*10;
      ypunits=' (mm) ';
    end
  case 'mm to cm',
    if isempty(strfind(ypunits,'(cm)'))
      yp=yp/10;
      ypunits=' (cm) ';
    end
  case 'g to ft/sec2',
    if isempty(strfind(ypunits,'(ft/sec2)'))
      yp=yp*32.174;
      ypunits=' (ft/sec2) ';
    end
  case 'ft/sec2 to g',
    if isempty(strfind(ypunits,'(g)'))
      yp=yp/32.174;
      ypunits=' (g) ';
    end
  case 'ft/sec to kts',
    if isempty(strfind(ypunits,'(kts)'))
      yp=yp/1.6878;
      ypunits=' (kts) ';
    end
  case 'kts to ft/sec',
    if isempty(strfind(ypunits,'(ft/sec)'))
      yp=yp*1.6878;
      ypunits=' (ft/sec) ';
    end
  case 'ft/sec to mph',
    if isempty(strfind(ypunits,'(mph)'))
      yp=yp*3600/5280;
      ypunits=' (mph) ';
    end
  case 'mph to ft/sec',
    if isempty(strfind(ypunits,'(ft/sec)'))
      yp=yp*5280/3600;
      ypunits=' (ft/sec) ';
    end
  case 'slug to lbm',
    if isempty(strfind(ypunits,'(lbm)'))
      yp=yp*32.174;
      ypunits=' (lbm) ';
    end
  case 'lbm to slug',
    if isempty(strfind(ypunits,'(slug)'))
      yp=yp/32.174;
      ypunits=' (slug) ';
    end
  case 'kg to slug',
    if isempty(strfind(ypunits,'(slug)'))
      yp=yp/14.594;
      ypunits=' (slug) ';
    end
  case 'slug to kg',
    if isempty(strfind(ypunits,'(kg)'))
      yp=yp*14.594;
      ypunits=' (kg) ';
    end
  case 'kg-m2 to slug-ft2',
    if isempty(strfind(ypunits,'(slug-ft2)'))
      yp=yp/(14.594*0.3048*0.3048);
      ypunits=' (slug-ft2) ';
    end
  case 'slug-ft2 to kg-m2',
    if isempty(strfind(ypunits,'(kg-m2)'))
      yp=yp*14.594*0.3048*0.3048;
      ypunits=' (kg-m2) ';
    end
  case 'N to lbf',
    if isempty(strfind(ypunits,'(lbf)'))
      yp=yp/4.448222;
      ypunits=' (lbf) ';
    end
  case 'lbf to N',
    if isempty(strfind(ypunits,'(N)'))
      yp=yp*4.448222;
      ypunits=' (N) ';
    end
  case 'N/m2 to lbf/ft2',
    if isempty(strfind(ypunits,'(lbf/ft2)'))
      yp=yp*0.3048*0.3048/4.448222;
      ypunits=' (lbf/ft2) ';
    end
  case 'lbf/ft2 to N/m2',
    if isempty(strfind(ypunits,'(N/m2)'))
      yp=yp*4.448222/(0.3048*0.3048);
      ypunits=' (N/m2) ';
    end
end
handles.data.yp=yp;
%
%  Specify the new units.
%
handles.units.yp=ypunits;
%
%  Save data in the handles structure.
%
guidata(hObject, handles);
return
