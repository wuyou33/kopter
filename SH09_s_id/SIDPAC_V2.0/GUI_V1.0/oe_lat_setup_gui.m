function varargout = oe_lat_setup_gui(varargin)
%
%  OE_LAT_SETUP_GUI  M-file for oe_lat_setup_gui.fig.
%
%      oe_lat_setup_GUI, by itself, creates a new oe_lat_setup_GUI or raises the existing
%      singleton*.
%
%      H = oe_lat_setup_GUI returns the handle to a new oe_lat_setup_GUI or the handle to
%      the existing singleton*.
%
%      oe_lat_setup_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in oe_lat_setup_GUI.M with the given input arguments.
%
%      oe_lat_setup_GUI('Property','Value',...) creates a new oe_lat_setup_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before oe_lat_setup_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to oe_lat_setup_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help oe_lat_setup_gui

% Last Modified by GUIDE v2.5 10-Aug-2006 00:31:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @oe_lat_setup_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @oe_lat_setup_gui_OutputFcn, ...
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


% --- Executes just before oe_lat_setup_gui is made visible.
function oe_lat_setup_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to oe_lat_setup_gui (see VARARGIN)

% Choose default command line output for oe_lat_setup_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes oe_lat_setup_gui wait for user response (see UIRESUME)
% uiwait(handles.oe_lat_setup_gui);

%
%  User code.
%
%  Load parameters from coe.p0, 
%  if coe exists in the workspace;
%  otherwise use the default values
%  from the GUI.  
%
if evalin('base','exist(''coe'',''var'')')
  oe_lat_fill
%
%  If coe.p0 is all zeros, set the 
%  initial_parameter_popup accordingly.
%
  if evalin('base','norm(coe.p0)==0')
    set(handles.initial_parameter_popup,'Value',2);
  end
end
%
%  Turn on the proper text labels.
%
if evalin('base','dopt==1')
  set(handles.CY_text,'Visible','on');
  set(handles.Cl_text,'Visible','on');
  set(handles.Cn_text,'Visible','on');
  set(handles.Y_text,'Visible','off');
  set(handles.L_text,'Visible','off');
  set(handles.N_text,'Visible','off');
else
  set(handles.CY_text,'Visible','off');
  set(handles.Cl_text,'Visible','off');
  set(handles.Cn_text,'Visible','off');
  set(handles.Y_text,'Visible','on');
  set(handles.L_text,'Visible','on');
  set(handles.N_text,'Visible','on');
end


% --- Outputs from this function are returned to the command line.
function varargout = oe_lat_setup_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function dimension_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dimension_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in dimension_popup.
function dimension_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dimension_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns dimension_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dimension_popup

%
%  User code.
%
dopt=get(hObject,'Value');
assignin('base','dopt',dopt);
evalin('base','coe=oe_psel(fdata,runopt,dopt);');
%
%  Fill in the initial parameter values shown in the GUI.
%
oe_lat_fill
%
%  Turn on the proper text labels.
%
if evalin('base','dopt==1')
  set(handles.CY_text,'Visible','on');
  set(handles.Cl_text,'Visible','on');
  set(handles.Cn_text,'Visible','on');
  set(handles.Y_text,'Visible','off');
  set(handles.L_text,'Visible','off');
  set(handles.N_text,'Visible','off');
else
  set(handles.CY_text,'Visible','off');
  set(handles.Cl_text,'Visible','off');
  set(handles.Cn_text,'Visible','off');
  set(handles.Y_text,'Visible','on');
  set(handles.L_text,'Visible','on');
  set(handles.N_text,'Visible','on');
end


% --- Executes during object creation, after setting all properties.
function initial_parameter_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initial_parameter_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in initial_parameter_popup.
function initial_parameter_popup_Callback(hObject, eventdata, handles)
% hObject    handle to initial_parameter_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns initial_parameter_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from initial_parameter_popup

%
%  User code.
%
iflg=get(hObject,'Value');
if iflg==1
  dopt=get(handles.dimension_popup,'Value');
  assignin('base','dopt',dopt);
  evalin('base','coe=oe_psel(fdata,2,dopt);')
else
  evalin('base','coe.p0=0*coe.p0;')
end
oe_lat_fill


% --- Executes on button press in cancel_pushbutton.
function cancel_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.oe_lat_setup_gui),


% --- Executes on button press in ok_pushbutton.
function ok_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ok_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
oe_lat_setup_update
%
%  Compute outputs and plot results for 
%  the updated model and run parameters.
%
evalin('base','oe_chk')
evalin('base','oe_plot')
close(handles.oe_lat_setup_gui),


% --- Executes during object creation, after setting all properties.
function a11_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a11_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a11_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a11_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a11_edit as text
%        str2double(get(hObject,'String')) returns contents of a11_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a11_switch.
function a11_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a11_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a11_switch


% --- Executes during object creation, after setting all properties.
function a12_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a12_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a12_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a12_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a12_edit as text
%        str2double(get(hObject,'String')) returns contents of a12_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a12_switch.
function a12_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a12_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a12_switch


% --- Executes during object creation, after setting all properties.
function a13_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a13_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a13_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a13_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a13_edit as text
%        str2double(get(hObject,'String')) returns contents of a13_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a13_switch.
function a13_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a13_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a13_switch


% --- Executes during object creation, after setting all properties.
function a14_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a14_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a14_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a14_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a14_edit as text
%        str2double(get(hObject,'String')) returns contents of a14_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a14_switch.
function a14_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a14_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a14_switch


% --- Executes during object creation, after setting all properties.
function b11_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b11_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b11_edit_Callback(hObject, eventdata, handles)
% hObject    handle to b11_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b11_edit as text
%        str2double(get(hObject,'String')) returns contents of b11_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in b11_switch.
function b11_switch_Callback(hObject, eventdata, handles)
% hObject    handle to b11_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of b11_switch


% --- Executes during object creation, after setting all properties.
function b12_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b12_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b12_edit_Callback(hObject, eventdata, handles)
% hObject    handle to b12_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b12_edit as text
%        str2double(get(hObject,'String')) returns contents of b12_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in b12_switch.
function b12_switch_Callback(hObject, eventdata, handles)
% hObject    handle to b12_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of b12_switch



% --- Executes during object creation, after setting all properties.
function b13_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b13_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b13_edit_Callback(hObject, eventdata, handles)
% hObject    handle to b13_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b13_edit as text
%        str2double(get(hObject,'String')) returns contents of b13_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in b13_switch.
function b13_switch_Callback(hObject, eventdata, handles)
% hObject    handle to b13_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of b13_switch


% --- Executes during object creation, after setting all properties.
function a21_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a21_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a21_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a21_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a21_edit as text
%        str2double(get(hObject,'String')) returns contents of a21_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a21_switch.
function a21_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a21_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a21_switch


% --- Executes during object creation, after setting all properties.
function a22_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a22_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a22_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a22_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a22_edit as text
%        str2double(get(hObject,'String')) returns contents of a22_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a22_switch.
function a22_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a22_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a22_switch


% --- Executes during object creation, after setting all properties.
function a23_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a23_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a23_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a23_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a23_edit as text
%        str2double(get(hObject,'String')) returns contents of a23_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a23_switch.
function a23_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a23_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a23_switch


% --- Executes during object creation, after setting all properties.
function a24_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a24_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a24_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a24_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a24_edit as text
%        str2double(get(hObject,'String')) returns contents of a24_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a24_switch.
function a24_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a24_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a24_switch


% --- Executes during object creation, after setting all properties.
function b21_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b21_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b21_edit_Callback(hObject, eventdata, handles)
% hObject    handle to b21_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b21_edit as text
%        str2double(get(hObject,'String')) returns contents of b21_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in b21_switch.
function b21_switch_Callback(hObject, eventdata, handles)
% hObject    handle to b21_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of b21_switch


% --- Executes during object creation, after setting all properties.
function b22_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b22_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b22_edit_Callback(hObject, eventdata, handles)
% hObject    handle to b22_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b22_edit as text
%        str2double(get(hObject,'String')) returns contents of b22_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in b22_switch.
function b22_switch_Callback(hObject, eventdata, handles)
% hObject    handle to b22_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of b22_switch


% --- Executes during object creation, after setting all properties.
function b23_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b23_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b23_edit_Callback(hObject, eventdata, handles)
% hObject    handle to b23_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b23_edit as text
%        str2double(get(hObject,'String')) returns contents of b23_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in b23_switch.
function b23_switch_Callback(hObject, eventdata, handles)
% hObject    handle to b23_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of b23_switch


% --- Executes during object creation, after setting all properties.
function a31_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a31_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a31_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a31_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a31_edit as text
%        str2double(get(hObject,'String')) returns contents of a31_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a31_switch.
function a31_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a31_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a31_switch


% --- Executes during object creation, after setting all properties.
function a32_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a32_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a32_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a32_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a32_edit as text
%        str2double(get(hObject,'String')) returns contents of a32_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a32_switch.
function a32_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a32_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a32_switch



% --- Executes during object creation, after setting all properties.
function a33_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a33_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a33_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a33_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a33_edit as text
%        str2double(get(hObject,'String')) returns contents of a33_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a33_switch.
function a33_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a33_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a33_switch


% --- Executes during object creation, after setting all properties.
function a34_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a34_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a34_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a34_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a34_edit as text
%        str2double(get(hObject,'String')) returns contents of a34_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a34_switch.
function a34_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a34_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a34_switch


% --- Executes during object creation, after setting all properties.
function b31_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b31_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b31_edit_Callback(hObject, eventdata, handles)
% hObject    handle to b31_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b31_edit as text
%        str2double(get(hObject,'String')) returns contents of b31_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in b31_switch.
function b31_switch_Callback(hObject, eventdata, handles)
% hObject    handle to b31_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of b31_switch


% --- Executes during object creation, after setting all properties.
function b32_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b32_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b32_edit_Callback(hObject, eventdata, handles)
% hObject    handle to b32_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b32_edit as text
%        str2double(get(hObject,'String')) returns contents of b32_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in b32_switch.
function b32_switch_Callback(hObject, eventdata, handles)
% hObject    handle to b32_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of b32_switch


% --- Executes during object creation, after setting all properties.
function b33_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b33_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b33_edit_Callback(hObject, eventdata, handles)
% hObject    handle to b33_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b33_edit as text
%        str2double(get(hObject,'String')) returns contents of b33_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in b33_switch.
function b33_switch_Callback(hObject, eventdata, handles)
% hObject    handle to b33_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of b33_switch


% --- Executes during object creation, after setting all properties.
function a41_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a41_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a41_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a41_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a41_edit as text
%        str2double(get(hObject,'String')) returns contents of a41_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a41_switch.
function a41_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a41_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a41_switch



% --- Executes during object creation, after setting all properties.
function a42_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a42_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a42_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a42_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a42_edit as text
%        str2double(get(hObject,'String')) returns contents of a42_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a42_switch.
function a42_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a42_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a42_switch



% --- Executes during object creation, after setting all properties.
function a43_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a43_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a43_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a43_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a43_edit as text
%        str2double(get(hObject,'String')) returns contents of a43_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a43_switch.
function a43_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a43_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a43_switch


% --- Executes during object creation, after setting all properties.
function a44_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a44_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function a44_edit_Callback(hObject, eventdata, handles)
% hObject    handle to a44_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a44_edit as text
%        str2double(get(hObject,'String')) returns contents of a44_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in a44_switch.
function a44_switch_Callback(hObject, eventdata, handles)
% hObject    handle to a44_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a44_switch


% --- Executes during object creation, after setting all properties.
function b41_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b41_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b41_edit_Callback(hObject, eventdata, handles)
% hObject    handle to b41_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b41_edit as text
%        str2double(get(hObject,'String')) returns contents of b41_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in b41_switch.
function b41_switch_Callback(hObject, eventdata, handles)
% hObject    handle to b41_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of b41_switch


% --- Executes during object creation, after setting all properties.
function b42_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b42_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b42_edit_Callback(hObject, eventdata, handles)
% hObject    handle to b42_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b42_edit as text
%        str2double(get(hObject,'String')) returns contents of b42_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in b42_switch.
function b42_switch_Callback(hObject, eventdata, handles)
% hObject    handle to b42_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of b42_switch


% --- Executes during object creation, after setting all properties.
function b43_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b43_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function b43_edit_Callback(hObject, eventdata, handles)
% hObject    handle to b43_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b43_edit as text
%        str2double(get(hObject,'String')) returns contents of b43_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in b43_switch.
function b43_switch_Callback(hObject, eventdata, handles)
% hObject    handle to b43_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of b43_switch


% --- Executes during object creation, after setting all properties.
function d13_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to d13_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function d13_edit_Callback(hObject, eventdata, handles)
% hObject    handle to d13_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of d13_edit as text
%        str2double(get(hObject,'String')) returns contents of d13_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in d13_switch.
function d13_switch_Callback(hObject, eventdata, handles)
% hObject    handle to d13_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d13_switch


% --- Executes during object creation, after setting all properties.
function d23_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to d23_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function d23_edit_Callback(hObject, eventdata, handles)
% hObject    handle to d23_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of d23_edit as text
%        str2double(get(hObject,'String')) returns contents of d23_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in d23_switch.
function d23_switch_Callback(hObject, eventdata, handles)
% hObject    handle to d23_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d23_switch


% --- Executes during object creation, after setting all properties.
function d33_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to d33_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function d33_edit_Callback(hObject, eventdata, handles)
% hObject    handle to d33_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of d33_edit as text
%        str2double(get(hObject,'String')) returns contents of d33_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in d33_switch.
function d33_switch_Callback(hObject, eventdata, handles)
% hObject    handle to d33_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d33_switch


% --- Executes during object creation, after setting all properties.
function d43_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to d43_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function d43_edit_Callback(hObject, eventdata, handles)
% hObject    handle to d43_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of d43_edit as text
%        str2double(get(hObject,'String')) returns contents of d43_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in d43_switch.
function d43_switch_Callback(hObject, eventdata, handles)
% hObject    handle to d43_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d43_switch


% --- Executes during object creation, after setting all properties.
function d53_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to d53_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function d53_edit_Callback(hObject, eventdata, handles)
% hObject    handle to d53_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of d53_edit as text
%        str2double(get(hObject,'String')) returns contents of d53_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in d53_switch.
function d53_switch_Callback(hObject, eventdata, handles)
% hObject    handle to d53_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d53_switch


% --- Executes during object creation, after setting all properties.
function d63_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to d63_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function d63_edit_Callback(hObject, eventdata, handles)
% hObject    handle to d63_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of d63_edit as text
%        str2double(get(hObject,'String')) returns contents of d63_edit as a double

%
%  User code.
%
oe_setup_mod


% --- Executes on button press in d63_switch.
function d63_switch_Callback(hObject, eventdata, handles)
% hObject    handle to d63_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of d63_switch


% --- Executes on button press in beta_output_switch.
function beta_output_switch_Callback(hObject, eventdata, handles)
% hObject    handle to beta_output_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of beta_output_switch


% --- Executes on button press in p_output_switch.
function p_output_switch_Callback(hObject, eventdata, handles)
% hObject    handle to p_output_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p_output_switch


% --- Executes on button press in r_output_switch.
function r_output_switch_Callback(hObject, eventdata, handles)
% hObject    handle to r_output_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of r_output_switch


% --- Executes on button press in phi_output_switch.
function phi_output_switch_Callback(hObject, eventdata, handles)
% hObject    handle to phi_output_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of phi_output_switch


% --- Executes on button press in ay_output_switch.
function ay_output_switch_Callback(hObject, eventdata, handles)
% hObject    handle to ay_output_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ay_output_switch


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
close(handles.oe_lat_setup_gui),
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
close(handles.oe_lat_setup_gui),
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
close(handles.oe_lat_setup_gui),
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
close(handles.oe_lat_setup_gui),
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
close(handles.oe_lat_setup_gui),
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
close(handles.oe_lat_setup_gui),
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
close(handles.oe_lat_setup_gui),
evalin('base','clear guiH;');
evalin('base','oe_gui;');


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


