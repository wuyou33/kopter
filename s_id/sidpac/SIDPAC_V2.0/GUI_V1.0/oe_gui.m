function varargout = oe_gui(varargin)
%
%  OE_GUI  M-file for oe_gui.fig.
%
%      oe_GUI, by itself, creates a new oe_GUI or raises the existing
%      singleton*.
%
%      H = oe_GUI returns the handle to a new oe_GUI or the handle to
%      the existing singleton*.
%
%      oe_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in oe_GUI.M with the given input arguments.
%
%      oe_GUI('Property','Value',...) creates a new oe_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before oe_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to oe_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help oe_gui

% Last Modified by GUIDE v2.5 09-Aug-2006 00:51:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @oe_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @oe_gui_OutputFcn, ...
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


% --- Executes just before oe_gui is made visible.
function oe_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to oe_gui (see VARARGIN)

% Choose default command line output for oe_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes oe_gui wait for user response (see UIRESUME)
% uiwait(handles.oe_gui);

%
%  User code
%
%  Save the abscissa data for plotting via callbacks.
%
handles.data.xp=evalin('base','t');
handles.label.xp=evalin('base','fds.varlab{1}');
handles.units.xp=evalin('base','fds.varunits{1}');
%
%  Save data in the handles structure.
%
guidata(hObject, handles);
%
%  Create a pointer from the MATLAB workspace to the GUI data.
%
evalin('base','guiH=guidata(gcf);');
%
%  Determine if this is a longitudinal or lateral case.
%
if evalin('base','exist(''coe'',''var'')')
  runopt = evalin('base','coe.runopt;');
  set(handles.lonlat_popup,'Value',runopt);
else
  runopt=get(handles.lonlat_popup,'Value');
end
assignin('base','runopt',runopt);
evalin('base','coe=oe_psel(fdata,runopt);');
%  
%  Compute the model outputs.
%
fprintf('\n\nComputing model outputs, stand by ... \n'),
evalin('base','oe_chk')
fprintf('\nDone \n\n'),
%
%  Plot the results.
%
evalin('base','oe_plot')


% --- Outputs from this function are returned to the command line.
function varargout = oe_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in grid_radiobutton.
function grid_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to grid_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of grid_radiobutton

%
%  User code.
%
%  Grid switch function.
%
if get(hObject,'Value')==1
  axes(handles.axes1);grid on;
  axes(handles.axes2);grid on;
  axes(handles.axes3);grid on;
else
  axes(handles.axes1);grid off;
  axes(handles.axes2);grid off;
  axes(handles.axes3);grid off;
end


% --- Executes on button press in estimate_pushbutton.
function estimate_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to estimate_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%
%  Estimate the model parameters.
%
evalin('base','oe_est')
%
%  Plot the results.
%
evalin('base','oe_plot')


% --- Executes on button press in setup_pushbutton.
function setup_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setup_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Start the appropriate set-up GUI.  
%
if evalin('base','coe.runopt==1')
  evalin('base','oe_lon_setup_gui')
else
  evalin('base','oe_lat_setup_gui')
end


% --- Executes on button press in check_pushbutton.
function check_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to check_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Compute the model outputs.
%
evalin('base','oe_chk')
%
%  Plot the results.
%
evalin('base','oe_plot')


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
assignin('base','runopt',runopt);
evalin('base','coe=oe_psel(fdata,runopt);');
%
%  Plot the data and initial model.
%
evalin('base','oe_chk')
evalin('base','oe_plot')


% --- Executes during object creation, after setting all properties.
function group_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to group_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in group_popup.
function group_popup_Callback(hObject, eventdata, handles)
% hObject    handle to group_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns group_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from group_popup

%
%  User code.
%
evalin('base','oe_plot')


% --- Executes during object creation, after setting all properties.
function plot_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in plot_popup.
function plot_popup_Callback(hObject, eventdata, handles)
% hObject    handle to plot_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plot_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_popup

%
%  User code.
%
evalin('base','oe_plot');


% --- Executes on button press in correct_pushbutton.
function correct_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to correct_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Correct standard errors for colored residuals.
%
evalin('base','oe_cor');


% --- Executes on button press in save_results_pushbutton.
function save_results_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_results_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Save results in fds.
%
evalin('base','oe_save');


% --- Executes on button press in close_pushbutton.
function close_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to close_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.oe_gui),
evalin('base','clear guiH;');
evalin('base','sid_gui;');


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
close(handles.oe_gui),
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
close(handles.oe_gui),
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
close(handles.oe_gui),
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
close(handles.oe_gui),
evalin('base','clear guiH;');
evalin('base','lr_gui;');


% --------------------------------------------------------------------
function Stepwise_Regression_2_Callback(hObject, eventdata, handles)
% hObject    handle to Stepwise_Regression_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.oe_gui),
evalin('base','clear guiH;');
evalin('base','swr_gui;');


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
close(handles.oe_gui),
evalin('base','clear guiH;');
evalin('base','sid_gui;');




% --------------------------------------------------------------------
function Notes_1_Callback(hObject, eventdata, handles)
% hObject    handle to Notes_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Edit_Notes_2_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Notes_2 (see GCBO)
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


