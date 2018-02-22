function varargout = dcmp_gui(varargin)
%
%  DCMP_GUI  M-file for dcmp_gui.fig.
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
%      applied to the GUI before dcmp_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dcmp_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dcmp_gui

% Last Modified by GUIDE v2.5 06-Aug-2006 12:51:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dcmp_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @dcmp_gui_OutputFcn, ...
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


% --- Executes just before dcmp_gui is made visible.
function dcmp_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dcmp_gui (see VARARGIN)

% Choose default command line output for dcmp_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dcmp_gui wait for user response (see UIRESUME)
% uiwait(handles.dcmp_gui);

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
%  Compute the reconstructed outputs.
%
fprintf('\n\nComputing reconstructed outputs, stand by ... \n'),
dcmp_chk
fprintf('\nDone \n\n'),
%
%  Plot the results.
%
evalin('base','dcmp_plot');


% --- Outputs from this function are returned to the command line.
function varargout = dcmp_gui_OutputFcn(hObject, eventdata, handles)
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
%  Estimate the instrumentation error parameters.
%
dcmp_est
%
%  Plot the results.
%
evalin('base','dcmp_plot');


% --- Executes on button press in setup_pushbutton.
function setup_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to setup_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Start the set-up GUI.  
%
evalin('base','dcmp_setup_gui');


% --- Executes on button press in check_pushbutton.
function check_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to check_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Compute the reconstructed outputs.
%
dcmp_chk
%
%  Plot the results.
%
evalin('base','dcmp_plot');


% --- Executes on button press in correct_data_pushbutton.
function correct_data_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to correct_data_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Make systematic instrumentation error corrections to fdata.
%
evalin('base','dcmp_cor');


% --- Executes on button press in save_results_pushbutton.
function save_results_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_results_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Save data compatibiilty analysis results in fds.
%
evalin('base','dcmp_save');


% --- Executes on button press in close_pushbutton.
function close_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to close_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.dcmp_gui),
evalin('base','clear guiH;');
evalin('base','sid_gui;');


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
fdata=evalin('base','fdata;');
cc=dcmp_psel(fdata,runopt);
assignin('base','cc',cc);


% --- Executes during object creation, after setting all properties.
function transrot_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to transrot_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in transrot_popup.
function transrot_popup_Callback(hObject, eventdata, handles)
% hObject    handle to transrot_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns transrot_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from transrot_popup

%
%  User code.
%
%  Make data compatibility plots.
%
evalin('base','dcmp_plot');


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
%  Make data compatibility plots.
%
evalin('base','dcmp_plot');


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
close(handles.dcmp_gui),
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
close(handles.dcmp_gui),
evalin('base','clear guiH;');
evalin('base','mc_gui;');


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
close(handles.dcmp_gui),
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
close(handles.dcmp_gui),
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
close(handles.dcmp_gui),
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
close(handles.dcmp_gui),
evalin('base','clear guiH;');
evalin('base','sid_gui;');


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


