function css = compcss(fdata)
%
%  COMPCSS  Assembles constants for dimensional state-space models.  
%
%  Usage: css = compcss(fdata);
%
%  Description:
%
%    Computes constant values in dimensional state-space
%    dynamic models, based on measured flight data 
%    from standard data array fdata.
%
%  Input:
%    
%    fdata = flight test data array in standard configuration.
%
%  Output:
%
%      css = vector of constants for a dimensional state-space model.
%

%
%    Calls:
%      massprop.m
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      03 Feb 2006 - Created and debugged, EAM.
%      09 Jun 2006 - Expanded definitions, converted to named structure, EAM.
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
dtr=pi/180;
g=32.174;
css.vo=mean(fdata(:,2));
css.vog=css.vo/g;
css.qbar=mean(fdata(:,27));
css.qs=css.qbar*fdata(1,77);
css.qsc=css.qs*fdata(1,79);
css.c2v=fdata(1,79)/(2*css.vo);
css.qsb=css.qs*fdata(1,78);
css.b2v=fdata(1,78)/(2*css.vo);
css.sa=sin(mean(fdata(:,4)*dtr));
css.ca=cos(mean(fdata(:,4)*dtr));
css.dgdp=g*cos(mean(fdata(:,9)*dtr))/css.vo;
css.tt=tan(mean(fdata(:,9)*dtr));
[ci,mass,ixx,iyy,izz,ixz] = massprop(fdata);
css.ci=ci;
css.mass=mass;
return
