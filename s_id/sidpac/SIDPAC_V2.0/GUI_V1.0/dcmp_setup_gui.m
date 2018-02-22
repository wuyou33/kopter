function varargout = dcmp_setup_gui(varargin)
%
%  DCMP_SETUP_GUI  M-file for dcmp_setup_gui.fig
%
%      dcmp_GUI, by itself, creates a new dcmp_GUI or raises the existing
%      singleton*.
%
%      H = dcmp_GUI returns the handle to a new dcmp_GUI or the handle to
%      the existing singleton*.
%
%      dcmp_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in dcmp_GUI.M with the given input arguments.
%
%      dcmp_GUI('Property','Value',...) creates a new dcmp_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dcmp_setup_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dcmp_setup_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dcmp_setup_gui

% Last Modified by GUIDE v2.5 10-Aug-2006 04:34:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dcmp_setup_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @dcmp_setup_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before dcmp_setup_gui is made visible.
function dcmp_setup_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dcmp_setup_gui (see VARARGIN)

% Choose default command line output for dcmp_setup_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dcmp_setup_gui wait for user response (see UIRESUME)
% uiwait(handles.dcmp_setup_gui);

%
%  User code.
%
%  Implement settings in the GUI if the cc variable
%  already exists in the MATLAB workspace.  Otherwise, 
%  the default settings in the GUI determine the initial settings.  
%
if evalin('base','exist(''cc'',''var'')')
  p0c=evalin('base','cc.p0c');
  set(handles.ax_b_edit,'Value',p0c(1));
  set(handles.ax_b_edit,'String',num2str(p0c(1)));
  set(handles.ay_b_edit,'Value',p0c(2));
  set(handles.ay_b_edit,'String',num2str(p0c(2)));
  set(handles.az_b_edit,'Value',p0c(3));
  set(handles.az_b_edit,'String',num2str(p0c(3)));
  set(handles.p_b_edit,'Value',p0c(4));
  set(handles.p_b_edit,'String',num2str(p0c(4)));
  set(handles.q_b_edit,'Value',p0c(5));
  set(handles.q_b_edit,'String',num2str(p0c(5)));
  set(handles.r_b_edit,'Value',p0c(6));
  set(handles.r_b_edit,'String',num2str(p0c(6)));
  set(handles.airspeed_scf_edit,'Value',p0c(7));
  set(handles.airspeed_scf_edit,'String',num2str(p0c(7)));
  set(handles.beta_scf_edit,'Value',p0c(8));
  set(handles.beta_scf_edit,'String',num2str(p0c(8)));
  set(handles.alpha_scf_edit,'Value',p0c(9));
  set(handles.alpha_scf_edit,'String',num2str(p0c(9)));
  set(handles.airspeed_b_edit,'Value',p0c(10));
  set(handles.airspeed_b_edit,'String',num2str(p0c(10)));
  set(handles.beta_b_edit,'Value',p0c(11));
  set(handles.beta_b_edit,'String',num2str(p0c(11)));
  set(handles.alpha_b_edit,'Value',p0c(12));
  set(handles.alpha_b_edit,'String',num2str(p0c(12)));
  set(handles.phi_scf_edit,'Value',p0c(13));
  set(handles.phi_scf_edit,'String',num2str(p0c(13)));
  set(handles.the_scf_edit,'Value',p0c(14));
  set(handles.the_scf_edit,'String',num2str(p0c(14)));
  set(handles.psi_scf_edit,'Value',p0c(15));
  set(handles.psi_scf_edit,'String',num2str(p0c(15)));
  set(handles.phi_b_edit,'Value',p0c(16));
  set(handles.phi_b_edit,'String',num2str(p0c(16)));
  set(handles.the_b_edit,'Value',p0c(17));
  set(handles.the_b_edit,'String',num2str(p0c(17)));
  set(handles.psi_b_edit,'Value',p0c(18));
  set(handles.psi_b_edit,'String',num2str(p0c(18)));
  ipc=evalin('base','cc.ipc');
  set(handles.ax_b_switch,'Value',ipc(1));
  set(handles.ay_b_switch,'Value',ipc(2));
  set(handles.az_b_switch,'Value',ipc(3));
  set(handles.p_b_switch,'Value',ipc(4));
  set(handles.q_b_switch,'Value',ipc(5));
  set(handles.r_b_switch,'Value',ipc(6));
  set(handles.airspeed_scf_switch,'Value',ipc(7));
  set(handles.beta_scf_switch,'Value',ipc(8));
  set(handles.alpha_scf_switch,'Value',ipc(9));
  set(handles.airspeed_b_switch,'Value',ipc(10));
  set(handles.beta_b_switch,'Value',ipc(11));
  set(handles.alpha_b_switch,'Value',ipc(12));
  set(handles.phi_scf_switch,'Value',ipc(13));
  set(handles.the_scf_switch,'Value',ipc(14));
  set(handles.psi_scf_switch,'Value',ipc(15));
  set(handles.phi_b_switch,'Value',ipc(16));
  set(handles.the_b_switch,'Value',ipc(17));
  set(handles.psi_b_switch,'Value',ipc(18));
  imo=evalin('base','cc.imo');
  set(handles.airspeed_output_switch,'Value',imo(1));
  set(handles.beta_output_switch,'Value',imo(2));
  set(handles.alpha_output_switch,'Value',imo(3));
  set(handles.phi_output_switch,'Value',imo(4));
  set(handles.the_output_switch,'Value',imo(5));
  set(handles.psi_output_switch,'Value',imo(6));
end
%
%  Turn on the proper case label.
%
if evalin('base','exist(''runopt'',''var'')')
  set(handles.lonlat_popup,'Value',evalin('base','runopt'));
end


% --- Outputs from this function are returned to the command line.
function varargout = dcmp_setup_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function lonlat_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lonlat_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in lonlat_popup.
function lonlat_popup_Callback(hObject, eventdata, handles)
% hObject    handle to lonlat_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lonlat_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lonlat_popup

%
%  User code.
%
runopt=get(hObject,'Value');
%
%  Longitudinal.
%
if runopt==1
%  Parameters. 
  set(handles.ax_b_switch,'Value',1);
  set(handles.ay_b_switch,'Value',0);
  set(handles.az_b_switch,'Value',1);
  set(handles.p_b_switch,'Value',0);
  set(handles.q_b_switch,'Value',1);
  set(handles.r_b_switch,'Value',0);
  set(handles.airspeed_scf_switch,'Value',0);
  set(handles.beta_scf_switch,'Value',0);
  set(handles.alpha_scf_switch,'Value',1);
  set(handles.phi_scf_switch,'Value',0);
  set(handles.the_scf_switch,'Value',1);
  set(handles.psi_scf_switch,'Value',0);
%  Outputs.
  set(handles.airspeed_output_switch,'Value',1);
  set(handles.beta_output_switch,'Value',0);
  set(handles.alpha_output_switch,'Value',1);
  set(handles.phi_output_switch,'Value',0);
  set(handles.the_output_switch,'Value',1);
  set(handles.psi_output_switch,'Value',0);
%
%  Lateral.
%
elseif runopt==2
%  Parameters. 
  set(handles.ax_b_switch,'Value',0);
  set(handles.ay_b_switch,'Value',1);
  set(handles.az_b_switch,'Value',0);
  set(handles.p_b_switch,'Value',1);
  set(handles.q_b_switch,'Value',0);
  set(handles.r_b_switch,'Value',1);
  set(handles.airspeed_scf_switch,'Value',0);
  set(handles.beta_scf_switch,'Value',1);
  set(handles.alpha_scf_switch,'Value',0);
  set(handles.phi_scf_switch,'Value',1);
  set(handles.the_scf_switch,'Value',0);
  set(handles.psi_scf_switch,'Value',1);
%  Outputs.
  set(handles.airspeed_output_switch,'Value',0);
  set(handles.beta_output_switch,'Value',1);
  set(handles.alpha_output_switch,'Value',0);
  set(handles.phi_output_switch,'Value',1);
  set(handles.the_output_switch,'Value',0);
  set(handles.psi_output_switch,'Value',1);
%
%  Combined longitudinal and lateral.
%
else
%  Parameters. 
  set(handles.ax_b_switch,'Value',1);
  set(handles.ay_b_switch,'Value',1);
  set(handles.az_b_switch,'Value',1);
  set(handles.p_b_switch,'Value',1);
  set(handles.q_b_switch,'Value',1);
  set(handles.r_b_switch,'Value',1);
  set(handles.airspeed_scf_switch,'Value',1);
  set(handles.beta_scf_switch,'Value',1);
  set(handles.alpha_scf_switch,'Value',1);
  set(handles.phi_scf_switch,'Value',1);
  set(handles.the_scf_switch,'Value',1);
  set(handles.psi_scf_switch,'Value',1);
%  Outputs.
  set(handles.airspeed_output_switch,'Value',1);
  set(handles.beta_output_switch,'Value',1);
  set(handles.alpha_output_switch,'Value',1);
  set(handles.phi_output_switch,'Value',1);
  set(handles.the_output_switch,'Value',1);
  set(handles.psi_output_switch,'Value',1);
end
assignin('base','runopt',runopt);


% --- Executes on button press in cancel_pushbutton.
function cancel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.dcmp_setup_gui),


% --- Executes on button press in ok_pushbutton.
function ok_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ok_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
dcmp_setup_update
close(handles.dcmp_setup_gui),


% --- Executes during object creation, after setting all properties.
function airspeed_scf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to airspeed_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function airspeed_scf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to airspeed_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of airspeed_scf_edit as text
%        str2double(get(hObject,'String')) returns contents of airspeed_scf_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in airspeed_scf_switch.
function airspeed_scf_switch_Callback(hObject, eventdata, handles)
% hObject    handle to airspeed_scf_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of airspeed_scf_switch


% --- Executes during object creation, after setting all properties.
function airspeed_b_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to airspeed_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function airspeed_b_edit_Callback(hObject, eventdata, handles)
% hObject    handle to airspeed_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of airspeed_b_edit as text
%        str2double(get(hObject,'String')) returns contents of airspeed_b_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in airspeed_b_switch.
function airspeed_b_switch_Callback(hObject, eventdata, handles)
% hObject    handle to airspeed_b_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of airspeed_b_switch


% --- Executes during object creation, after setting all properties.
function beta_scf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beta_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function beta_scf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to beta_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of beta_scf_edit as text
%        str2double(get(hObject,'String')) returns contents of beta_scf_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in beta_scf_switch.
function beta_scf_switch_Callback(hObject, eventdata, handles)
% hObject    handle to beta_scf_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of beta_scf_switch


% --- Executes during object creation, after setting all properties.
function beta_b_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beta_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function beta_b_edit_Callback(hObject, eventdata, handles)
% hObject    handle to beta_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of beta_b_edit as text
%        str2double(get(hObject,'String')) returns contents of beta_b_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in beta_b_switch.
function beta_b_switch_Callback(hObject, eventdata, handles)
% hObject    handle to beta_b_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of beta_b_switch


% --- Executes during object creation, after setting all properties.
function alpha_scf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function alpha_scf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alpha_scf_edit as text
%        str2double(get(hObject,'String')) returns contents of alpha_scf_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in alpha_scf_switch.
function alpha_scf_switch_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_scf_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alpha_scf_switch


% --- Executes during object creation, after setting all properties.
function alpha_b_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function alpha_b_edit_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alpha_b_edit as text
%        str2double(get(hObject,'String')) returns contents of alpha_b_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in alpha_b_switch.
function alpha_b_switch_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_b_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alpha_b_switch


% --- Executes during object creation, after setting all properties.
function phi_scf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phi_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function phi_scf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to phi_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phi_scf_edit as text
%        str2double(get(hObject,'String')) returns contents of phi_scf_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in phi_scf_switch.
function phi_scf_switch_Callback(hObject, eventdata, handles)
% hObject    handle to phi_scf_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of phi_scf_switch


% --- Executes during object creation, after setting all properties.
function phi_b_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phi_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function phi_b_edit_Callback(hObject, eventdata, handles)
% hObject    handle to phi_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phi_b_edit as text
%        str2double(get(hObject,'String')) returns contents of phi_b_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in phi_b_switch.
function phi_b_switch_Callback(hObject, eventdata, handles)
% hObject    handle to phi_b_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of phi_b_switch


% --- Executes during object creation, after setting all properties.
function the_scf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to the_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function the_scf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to the_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of the_scf_edit as text
%        str2double(get(hObject,'String')) returns contents of the_scf_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in the_scf_switch.
function the_scf_switch_Callback(hObject, eventdata, handles)
% hObject    handle to the_scf_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of the_scf_switch


% --- Executes during object creation, after setting all properties.
function theta_b_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to theta_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function theta_b_edit_Callback(hObject, eventdata, handles)
% hObject    handle to theta_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of theta_b_edit as text
%        str2double(get(hObject,'String')) returns contents of theta_b_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in the_b_switch.
function the_b_switch_Callback(hObject, eventdata, handles)
% hObject    handle to the_b_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of the_b_switch


% --- Executes during object creation, after setting all properties.
function psi_scf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psi_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function psi_scf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to psi_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psi_scf_edit as text
%        str2double(get(hObject,'String')) returns contents of psi_scf_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in psi_scf_switch.
function psi_scf_switch_Callback(hObject, eventdata, handles)
% hObject    handle to psi_scf_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of psi_scf_switch


% --- Executes during object creation, after setting all properties.
function psi_b_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psi_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function psi_b_edit_Callback(hObject, eventdata, handles)
% hObject    handle to psi_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psi_b_edit as text
%        str2double(get(hObject,'String')) returns contents of psi_b_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in psi_b_switch.
function psi_b_switch_Callback(hObject, eventdata, handles)
% hObject    handle to psi_b_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of psi_b_switch


% --- Executes during object creation, after setting all properties.
function p_scf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function p_scf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to p_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of p_scf_edit as text
%        str2double(get(hObject,'String')) returns contents of p_scf_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in p_scf_switch.
function p_scf_switch_Callback(hObject, eventdata, handles)
% hObject    handle to p_scf_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p_scf_switch


% --- Executes during object creation, after setting all properties.
function p_b_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function p_b_edit_Callback(hObject, eventdata, handles)
% hObject    handle to p_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of p_b_edit as text
%        str2double(get(hObject,'String')) returns contents of p_b_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in p_b_switch.
function p_b_switch_Callback(hObject, eventdata, handles)
% hObject    handle to p_b_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p_b_switch


% --- Executes during object creation, after setting all properties.
function q_scf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function q_scf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to q_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q_scf_edit as text
%        str2double(get(hObject,'String')) returns contents of q_scf_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in q_scf_switch.
function q_scf_switch_Callback(hObject, eventdata, handles)
% hObject    handle to q_scf_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of q_scf_switch


% --- Executes during object creation, after setting all properties.
function q_b_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to q_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function q_b_edit_Callback(hObject, eventdata, handles)
% hObject    handle to q_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of q_b_edit as text
%        str2double(get(hObject,'String')) returns contents of q_b_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in q_b_switch.
function q_b_switch_Callback(hObject, eventdata, handles)
% hObject    handle to q_b_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of q_b_switch


% --- Executes during object creation, after setting all properties.
function r_scf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function r_scf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to r_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r_scf_edit as text
%        str2double(get(hObject,'String')) returns contents of r_scf_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in r_scf_switch.
function r_scf_switch_Callback(hObject, eventdata, handles)
% hObject    handle to r_scf_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of r_scf_switch


% --- Executes during object creation, after setting all properties.
function r_b_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function r_b_edit_Callback(hObject, eventdata, handles)
% hObject    handle to r_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r_b_edit as text
%        str2double(get(hObject,'String')) returns contents of r_b_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in r_b_switch.
function r_b_switch_Callback(hObject, eventdata, handles)
% hObject    handle to r_b_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of r_b_switch


% --- Executes during object creation, after setting all properties.
function ax_scf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ax_scf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ax_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ax_scf_edit as text
%        str2double(get(hObject,'String')) returns contents of ax_scf_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in ax_scf_switch.
function ax_scf_switch_Callback(hObject, eventdata, handles)
% hObject    handle to ax_scf_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ax_scf_switch


% --- Executes during object creation, after setting all properties.
function ax_b_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ax_b_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ax_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ax_b_edit as text
%        str2double(get(hObject,'String')) returns contents of ax_b_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in ax_b_switch.
function ax_b_switch_Callback(hObject, eventdata, handles)
% hObject    handle to ax_b_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ax_b_switch


% --- Executes during object creation, after setting all properties.
function ay_scf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ay_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ay_scf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ay_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ay_scf_edit as text
%        str2double(get(hObject,'String')) returns contents of ay_scf_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in ay_scf_switch.
function ay_scf_switch_Callback(hObject, eventdata, handles)
% hObject    handle to ay_scf_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ay_scf_switch


% --- Executes during object creation, after setting all properties.
function ay_b_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ay_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ay_b_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ay_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ay_b_edit as text
%        str2double(get(hObject,'String')) returns contents of ay_b_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in ay_b_switch.
function ay_b_switch_Callback(hObject, eventdata, handles)
% hObject    handle to ay_b_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ay_b_switch


% --- Executes during object creation, after setting all properties.
function az_scf_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to az_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function az_scf_edit_Callback(hObject, eventdata, handles)
% hObject    handle to az_scf_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of az_scf_edit as text
%        str2double(get(hObject,'String')) returns contents of az_scf_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in az_scf_switch.
function az_scf_switch_Callback(hObject, eventdata, handles)
% hObject    handle to az_scf_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of az_scf_switch


% --- Executes during object creation, after setting all properties.
function az_b_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to az_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function az_b_edit_Callback(hObject, eventdata, handles)
% hObject    handle to az_b_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of az_b_edit as text
%        str2double(get(hObject,'String')) returns contents of az_b_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in az_b_switch.
function az_b_switch_Callback(hObject, eventdata, handles)
% hObject    handle to az_b_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of az_b_switch



% --- Executes on button press in airspeed_output_switch.
function airspeed_output_switch_Callback(hObject, eventdata, handles)
% hObject    handle to airspeed_output_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of airspeed_output_switch


% --- Executes on button press in beta_output_switch.
function beta_output_switch_Callback(hObject, eventdata, handles)
% hObject    handle to beta_output_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of beta_output_switch


% --- Executes on button press in alpha_output_switch.
function alpha_output_switch_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_output_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alpha_output_switch


% --- Executes on button press in phi_output_switch.
function phi_output_switch_Callback(hObject, eventdata, handles)
% hObject    handle to phi_output_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of phi_output_switch


% --- Executes on button press in the_output_switch.
function the_output_switch_Callback(hObject, eventdata, handles)
% hObject    handle to the_output_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of the_output_switch


% --- Executes on button press in psi_output_switch.
function psi_output_switch_Callback(hObject, eventdata, handles)
% hObject    handle to psi_output_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of psi_output_switch




% --------------------------------------------------------------------
function SIDPAC_1_Callback(hObject, eventdata, handles)
% hObject    handle to SIDPAC_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Home_2_Callback(hObject, eventdata, handles)
% hObject    handle to Home_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.dcmp_setup_gui),
evalin('base','clear guiH;');
evalin('base','sid_gui;');


% --------------------------------------------------------------------
function Maneuver_Cut_2_Callback(hObject, eventdata, handles)
% hObject    handle to Maneuver_Cut_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.dcmp_setup_gui),
evalin('base','clear guiH;');
evalin('base','mc_gui;');


% --------------------------------------------------------------------
function Data_Compatibility_2_Callback(hObject, eventdata, handles)
% hObject    handle to Data_Compatibility_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.dcmp_setup_gui),
evalin('base','clear guiH;');
evalin('base','dcmp_gui;');


% --------------------------------------------------------------------
function Modeling_2_Callback(hObject, eventdata, handles)
% hObject    handle to Modeling_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Linear_Regression_Modeling_3_Callback(hObject, eventdata, handles)
% hObject    handle to Linear_Regression_Modeling_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.dcmp_setup_gui),
evalin('base','clear guiH;');
evalin('base','lr_gui;');


% --------------------------------------------------------------------
function Stepwise_Regression_Modeling_3_Callback(hObject, eventdata, handles)
% hObject    handle to Stepwise_Regression_Modeling_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.dcmp_setup_gui),
evalin('base','clear guiH;');
evalin('base','swr_gui;');


% --------------------------------------------------------------------
function Output_Error_Modeling_3_Callback(hObject, eventdata, handles)
% hObject    handle to Output_Error_Modeling_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.dcmp_setup_gui),
evalin('base','clear guiH;');
evalin('base','oe_gui;');


% --------------------------------------------------------------------
function Transfer_Function_Modeling_3_Callback(hObject, eventdata, handles)
% hObject    handle to Transfer_Function_Modeling_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Close_2_Callback(hObject, eventdata, handles)
% hObject    handle to Close_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.dcmp_setup_gui),
evalin('base','clear guiH;');
evalin('base','dcmp_gui;');


% --------------------------------------------------------------------
function Notes_1_Callback(hObject, eventdata, handles)
% hObject    handle to Notes_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Enter_Notes_2_Callback(hObject, eventdata, handles)
% hObject    handle to Enter_Notes_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code
%
ncol=40;
nrow=24;
fds=evalin('base','fds;');
if isfield(fds,'notes')
  notes_in=inputdlg({'Enter notes here: '},'Notes',[nrow,ncol],{fds.notes});
else
  notes_in=inputdlg({'Enter notes here: '},'Notes',[nrow,ncol]);
end
fds.notes=char(textwrap(notes_in,ncol));
assignin('base','fds',fds);


% --------------------------------------------------------------------
function Show_Notes_2_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Notes_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code
%
evalin('base','fds.notes,');


% --------------------------------------------------------------------
function Clear_Notes_2_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_Notes_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code
%
evalin('base','fds.notes='''';');
evalin('base','fprintf(''\n''),disp(''Notes erased''),fprintf(''\n\n''),');


