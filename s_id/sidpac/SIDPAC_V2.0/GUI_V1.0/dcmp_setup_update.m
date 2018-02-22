%
%  DCMP_SETUP_UPDATE  Updates the run settings for data compatibility analysis.  
%
%  Calling GUI: dcmp_setup_gui.m
%
%  Usage: dcmp_setup_update;
%
%  Description:
%
%    Implements the run settings for data compatibility analysis, 
%    according to user input.  
%
%  Input:
%    
%    None
%
%  Output:
%
%     cc = cell structure:
%          cc.p0c   = vector of initial parameter values.
%          cc.ipc   = index vector to select estimated parameters.
%          cc.ims   = index vector to select measured states.
%          cc.imo   = index vector to select model outputs.
%

%
%    Calls:
%      None
%
%    Author:  Eugene A. Morelli
%
%    History:  
%      31 Dec  2005 - Created and debugged, EAM.
%      03 Apr  2006 - Added output biases, EAM.
%      02 Aug  2006 - Changed checkbox handles to switch, EAM.
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
%  Initial values for the estimated parameters.
%
%  p0c = [ax_bias,  ay_bias,   az_bias,  
%         p_bias,   q_bias,    r_bias, 
%         V_scf,    beta_scf,  alpha_scf, 
%         V_bias,   beta_bias, alpha_bias, 
%         phi_scf,  the_scf,   psi_scf,
%         phi_bias, the_bias,  psi_bias]
%
p0c=zeros(1,18);
p0c(1)=str2num(char(get(handles.ax_b_edit,'String')));
p0c(2)=str2num(char(get(handles.ay_b_edit,'String')));
p0c(3)=str2num(char(get(handles.az_b_edit,'String')));
p0c(4)=str2num(char(get(handles.p_b_edit,'String')));
p0c(5)=str2num(char(get(handles.q_b_edit,'String')));
p0c(6)=str2num(char(get(handles.r_b_edit,'String')));
p0c(7)=str2num(char(get(handles.airspeed_scf_edit,'String')));
p0c(8)=str2num(char(get(handles.beta_scf_edit,'String')));
p0c(9)=str2num(char(get(handles.alpha_scf_edit,'String')));
p0c(10)=str2num(char(get(handles.airspeed_b_edit,'String')));
p0c(11)=str2num(char(get(handles.beta_b_edit,'String')));
p0c(12)=str2num(char(get(handles.alpha_b_edit,'String')));
p0c(13)=str2num(char(get(handles.phi_scf_edit,'String')));
p0c(14)=str2num(char(get(handles.the_scf_edit,'String')));
p0c(15)=str2num(char(get(handles.psi_scf_edit,'String')));
p0c(16)=str2num(char(get(handles.phi_b_edit,'String')));
p0c(17)=str2num(char(get(handles.the_b_edit,'String')));
p0c(18)=str2num(char(get(handles.psi_b_edit,'String')));
%
%  The number of parameters is np.
%
np=length(p0c);
%
%
%  ipc element = 1 to estimate the corresponding parameter.
%              = 0 to exclude the corresponding parameter from the estimation.
%
ipc=zeros(1,18);
ipc(1)=get(handles.ax_b_switch,'Value');
ipc(2)=get(handles.ay_b_switch,'Value');
ipc(3)=get(handles.az_b_switch,'Value');
ipc(4)=get(handles.p_b_switch,'Value');
ipc(5)=get(handles.q_b_switch,'Value');
ipc(6)=get(handles.r_b_switch,'Value');
ipc(7)=get(handles.airspeed_scf_switch,'Value');
ipc(8)=get(handles.beta_scf_switch,'Value');
ipc(9)=get(handles.alpha_scf_switch,'Value');
ipc(10)=get(handles.airspeed_b_switch,'Value');
ipc(11)=get(handles.beta_b_switch,'Value');
ipc(12)=get(handles.alpha_b_switch,'Value');
ipc(13)=get(handles.phi_scf_switch,'Value');
ipc(14)=get(handles.the_scf_switch,'Value');
ipc(15)=get(handles.psi_scf_switch,'Value');
ipc(16)=get(handles.phi_b_switch,'Value');
ipc(17)=get(handles.the_b_switch,'Value');
ipc(18)=get(handles.psi_b_switch,'Value');
%
%
%  imo = 1 to select the corresponding output
%          to be included in the model output.
%      = 0 to omit the corresponding output 
%          from the model output. 
%
%    y = [vt,beta,alpha,phi,the,psi]
%
imo=zeros(1,6);
imo(1)=get(handles.airspeed_output_switch,'Value');
imo(2)=get(handles.beta_output_switch,'Value');
imo(3)=get(handles.alpha_output_switch,'Value');
imo(4)=get(handles.phi_output_switch,'Value');
imo(5)=get(handles.the_output_switch,'Value');
imo(6)=get(handles.psi_output_switch,'Value');
%
%
%  ims = 1 to use measured values 
%          for the corresponding state.
%      = 0 to use computed model values 
%          for the corresponding state.  
%
%    x = [u,v,w,phi,the,psi]
%
ims=ones(1,6);
indx=find(imo~=0);
if ~isempty(indx)
  ims(indx)=zeros(1,length(indx));
end
%
%     cc = cell structure:
%          cc.p0c = vector of initial parameter values.
%          cc.ipc = index vector to select estimated parameters.
%          cc.ims = index vector to select measured states.
%          cc.imo = index vector to select model outputs.
%
cc=evalin('base','cc');
cc.p0c=p0c;
cc.ipc=ipc;
cc.ims=ims;
cc.imo=imo;
%
%  Update cc in the MATLAB workspace.
%
assignin('base','cc',cc);
return
