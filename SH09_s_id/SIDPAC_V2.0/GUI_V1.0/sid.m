%
%  System IDentification Programs for AirCraft (SIDPAC)
%
%  Start-up routine
%
%  script sid.m
%
%  Usage: sid
%
%  Description:
%
%    Initializes and starts the Graphical User 
%    Interface (GUI) used to run System IDentification 
%    Programs for AirCraft (SIDPAC).
%
%
%  Input:
%
%    None
%
%
%  Output:
%
%   fdata = flight data array in standard configuration.
%       t = time vector.
%     fds = flight data structure in standard configuration.
%
%

%
%    Calls:
%      fds_init.m
%      cvec.m
%      sid_gui.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      8 Jan 2004 - Created and debugged, EAM.
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
%  Initialize the default data structure.
%
if ~exist('fds','var')
  fds=fds_init;
else
  if ~isstruct(fds)
    fprintf('\n\n Workspace variable fds is not a data structure. \n\n');
    return
  end
end
%
%  Initialize the time vector, if necessary.
%
if exist('t','var')
%
%  Update the flight data structure, fds.
%
  if isempty(fds.t)
    fds.t=t;
  end
else
%
%  Workspace variable t does not exist.
%
  if isempty(fds.t)
    whos
    fprintf('\n\n Data must be loaded into the MATLAB workspace first. '),
    tname=input('\n\n Enter the time variable name (CR to quit) ','s');
    if isempty(tname)
      clear fds;
      clear tname;
      return
    else
      t=eval(tname);
      clear tname;
      cvec(t);
      fds.t=t;
    end
  else
    t=fds.t;
  end
end
%
%  Check for the standard flight data array, fdata.
%
if exist('fdata','var')
%
%  Workspace variable fdata exists.
%
  [npts,nchnls]=size(fdata);
%
%  Update fdata to the correct size, if it 
%  has fewer than 90 columns.  This is to 
%  accommodate old versions of fdata.  
%
  if nchnls < 90
    fdata=[fdata,zeros(npts,90-nchnls)];
  end
%
%  Update the flight data structure, fds.
%
  if isempty(fds.fdata)
    fds.fdata=fdata;
  end
else
%
%  Workspace variable fdata does not exist.
%
  if isempty(fds.fdata)
    fdata=zeros(length(t),90);
    fds.fdata=fdata;
  else
    fdata=fds.fdata;
  end
end
%
%  The time vector t starts at zero and 
%  has constant sampling intervals.  The 
%  original time vector is in the first column 
%  of the fdata array.  
%
[npts,nchnls]=size(fdata);
t=t-t(1);
dt=1/round(1/(t(2)-t(1)));
t=[0:dt:(npts-1)*dt]';
%
%  Update the aircraft wing geometry.
%
if isempty(fds.sarea) & fdata(1,77)~=0
  fds.sarea=fdata(1,77);
end
if isempty(fds.bspan) & fdata(1,78)~=0
  fds.bspan=fdata(1,78);
end
if isempty(fds.cbar) & fdata(1,79)~=0
  fds.cbar=fdata(1,79);
end
%
%  Get aircraft wing geometry.
%
if isempty(fds.sarea)
  if exist('sarea','var')
    if prod(size(sarea))==1
      fds.sarea=sarea;
    end
  else
    sarea=input('\n\n Enter the reference wing area in ft2 (CR to quit) ');
    if isempty(sarea)
      clear fds;
      clear sarea;
      return
    else
      fds.sarea=sarea;
    end
  end
  fdata(:,77)=fds.sarea*ones(npts,1);
end
if isempty(fds.bspan)
  if exist('bspan','var')
    if prod(size(bspan))==1
      fds.bspan=bspan;
    end
  else
    bspan=input('\n\n Enter the wing span in ft (CR to quit) ');
    if isempty(bspan)
      clear fds;
      clear bspan;
      return
    else
      fds.bspan=bspan;
    end
  end
  fdata(:,78)=fds.bspan*ones(npts,1);
end
if isempty(fds.cbar)
  if exist('cbar','var')
    if prod(size(cbar))==1
      fds.cbar=cbar;
    end
  else
    cbar=input('\n\n Enter the wing mean aerodynamic chord in ft (CR to quit) ');
    if isempty(cbar)
      clear fds;
      clear cbar;
      return
    else
      fds.cbar=cbar;
    end
  end
  fdata(:,79)=fds.cbar*ones(npts,1);
end
%
%  Get aircraft and maneuver information.
%
if isempty(fds.aircraft)
  fds.aircraft=input('\n\n Enter the aircraft name (CR to skip) ','s');
  if isempty(fds.aircraft)
    fds.aircraft=' ';
  end
end
if isempty(fds.maneuver)
  fds.maneuver=input('\n\n Enter the maneuver description (CR to skip) ','s');
  if isempty(fds.maneuver)
    fds.maneuver=' ';
  end
end
if isempty(fds.test_date)
  fds.test_date=input('\n\n Enter the test date (CR to skip) ','s');
  if isempty(fds.test_date)
    fds.test_date=' ';
  end
end
if isempty(fds.pilot)
  fds.pilot=input('\n\n Enter the pilot name (CR to skip) ','s');
  if isempty(fds.pilot)
    fds.pilot=' ';
  end
end
%
%  Set up the SIDPAC graphical user interface. (GUI)
%
sid_gui;
return
