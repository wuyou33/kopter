function varargout = mc_gui(varargin)
%
%  MC_GUI  M-file for mc_gui.fig.
%
%      mc_GUI, by itself, creates a new mc_GUI or raises the existing
%      singleton*.
%
%      H = mc_GUI returns the handle to a new mc_GUI or the handle to
%      the existing singleton*.
%
%      mc_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in mc_GUI.M with the given input arguments.
%
%      mc_GUI('Property','Value',...) creates a new mc_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mc_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mc_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mc_gui

% Last Modified by GUIDE v2.5 05-Aug-2006 23:49:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mc_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @mc_gui_OutputFcn, ...
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


% --- Executes just before mc_gui is made visible.
function mc_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mc_gui (see VARARGIN)

% Choose default command line output for mc_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mc_gui wait for user response (see UIRESUME)
% uiwait(handles.mc_gui);

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
grid on,
%
%  Create a pointer from the MATLAB workspace to the GUI data.
%
evalin('base','guiH=guidata(gcf);');
%
%  Initialize the fdata index limits.
%
if evalin('base','~exist(''indi'')')
  evalin('base','indi=1;');
  evalin('base','indf=length(t);');
  evalin('base','indil=indi;');
  evalin('base','indfl=indf;');
  evalin('base','indio=indi;');
  evalin('base','indfo=indf;');
end
%
%  Plot the first SIDPAC variable.
%
mc_var_plot
%
%  Assign computed quantities
%  if this has not been done, 
%  indicated by whether or not 
%  CZ has not been assigned.  
%
if evalin('base','norm(fdata(:,63))==0')
  evalin('base','fdata=compfmc(fdata);');
end


% --- Outputs from this function are returned to the command line.
function varargout = mc_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function sidpac_var_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sidpac_var_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%
%  User code.
%
%  Initialize the variable list, and mark
%  the assigned data channels.
%
%  Get the variable labels and units.
%
vars = evalin('base','fds.varlab');
units = evalin('base','fds.varunits');
%
%  Mark the channels that have been assigned.
%
n=evalin('base','size(fdata,2)');
varlist=cell(n,1);
for i=1:n,
  if evalin('base',['norm(fdata(:,',num2str(i),'))'])~=0
    vars=sid_mrk_chnl(vars,i);
  end
%
%  Include SIDPAC channel numbers, and line up the display.  
%
  if i < 10
    varlist(i)=cellstr([num2str(i),'  ',char(vars(i)),' ',char(units(i))]);
  else
    varlist(i)=cellstr([num2str(i),' ',char(vars(i)),' ',char(units(i))]);
  end
end
%
%  Initialize the listbox.
%
set(hObject,'String',varlist);
%
%  Make the first plotted SIDPAC variable 
%  angle of attack in deg.  
%
set(hObject,'Value',4);


% --- Executes on selection change in sidpac_var_listbox.
function sidpac_var_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to sidpac_var_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sidpac_var_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sidpac_var_listbox

%
%  User code.
%
%  Plot the selected column of fdata.
%
mc_var_plot


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
  grid on;
else
  grid off;
end


% --- Executes during object creation, after setting all properties.
function hold_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hold_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hold_popup.
function hold_popup_Callback(hObject, eventdata, handles)
% hObject    handle to hold_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns hold_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hold_popup

%
%  User code.
%
%  Implement the compare function if there 
%  is more than one signal plotted.  
%
if get(handles.hold_popup,'Value')==3 & size(handles.data.yp,2) > 1
  handles.data.yp=cmpsigs(handles.data.xp,handles.data.yp,0);
%
%  Remove the units from the legend labels, 
%  because the compare function alters the scales. 
%
  nlab=length(handles.leglab);
  for i=1:nlab,
    tmp=handles.leglab{i};
    ilo=find(tmp=='(');
    ihi=find(tmp==')');
    if ~isempty(ilo) & ~isempty(ihi)
      for j=ilo:ihi,
        tmp(j)=' ';
      end
      handles.leglab{i}=tmp;
    end
  end
%
%  Plot the compared signals.
%
  mc_plot
end


% --- Executes on button press in undo_pushbutton.
function undo_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to undo_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Undo the maneuver cut by restoring the last index limits.
%
evalin('base','indi=indil;indf=indfl;');
fprintf('\n\nReset initial time = %f \n',evalin('base','t(indi)'));
fprintf('\nReset final time = %f \n\n\n',evalin('base','t(indf)'));
%
%  Plot command.
%
mc_plot;


% --- Executes on button press in cut_pushbutton.
function cut_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cut_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Save uncut data indices for undo.
%
evalin('base','indil=indi;indfl=indf;');
%
%  Turn on the help text box.
%
set(handles.help_text1,'Visible','on');
%
%  Initial time input.
%
[ti,yi,nbi]=ginput(1);
if nbi~=1,
  ti=input('\n\nInput initial time  ');
  tf=input('\nInput final time  ');
else
%
%  Update the help text box.
%
  set(handles.help_text1,'Visible','off');
  set(handles.help_text2,'Visible','on');
%
%  Final time input.
%
  [tf,yf,nbf]=ginput(1);
  if nbf~=1,
    tf=input('\nInput final time  ');
  end
end
set(handles.help_text1,'Visible','off');
set(handles.help_text2,'Visible','off');
%
%  Initial time data conditioning.
%
ti=max(0,ti);
t=evalin('base','t');
fdata=evalin('base','fdata');
dt=1/round(1/(t(2)-t(1)));
ti=round(ti/dt)*dt;
fprintf('\n\nSelected initial time = %f \n',ti);
indi=max(find(t<=ti));
%
%  Final time data conditioning.
%
if tf <= 0 | tf > max(t),
  tf=max(t);
end
tf=round(tf/dt)*dt;
fprintf('\nSelected final time = %f \n\n\n',tf);
indf=min(find(t>=tf));
%
%  Update the indices in the MATLAB workspace.
%
assignin('base','indi',indi);
assignin('base','indf',indf);
%
%  Plot command.
%
mc_plot;


% --- Executes on button press in reset_pushbutton.
function reset_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to reset_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Undo the maneuver cut by restoring the last index limits.
%
evalin('base','indil=indi;indfl=indf;');
evalin('base','indi=indio;indf=indfo;');
fprintf('\n\nReset initial time = %f \n',evalin('base','t(indi)'));
fprintf('\nReset final time = %f \n\n\n',evalin('base','t(indf)'));
%
%  Plot command.
%
mc_plot;


% --- Executes on button press in close_pushbutton.
function close_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to close_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.mc_gui),
evalin('base','clear indi indf indil indfl indio indfo guiH;');
evalin('base','sid_gui;');


% --- Executes on button press in save_pushbutton.
function save_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code
%
%  Implement the maneuver cut.
%
evalin('base','t=t([indi:indf]);t=t-t(1);');
evalin('base','fdata=fdata([indi:indf],:);');
%
%  Save the indices for the cut.  Add the 
%  indices appropriately if there has been 
%  a previous saved cut.  
%
if evalin('base','exist(''indic'',''var'')')
  evalin('base','indfc=indic+indf-1;');
  evalin('base','indic=indic+indi-1;');
else
  evalin('base','indic=indi;indfc=indf;');
end
%
%  Reset the fdata index limits.
%
evalin('base','indi=1;indf=length(t);');
evalin('base','indil=indi;indfl=indf;');
evalin('base','indio=indi;indfo=indf;');
%
%  Reset the abscissa plot variables.
%
handles.label.xp=evalin('base','fds.varlab{1}');
handles.units.xp=evalin('base','fds.varunits{1}');
handles.data.xp=evalin('base','t');
%
%  Save data in the handles structure.
%
guidata(hObject, handles);
%
%  Plot the first SIDPAC variable.
%
mc_var_plot


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
close(handles.mc_gui),
evalin('base','clear guiH;');
evalin('base','sid_gui;');


% --------------------------------------------------------------------
function Data_Compatibility_2_Callback(hObject, eventdata, handles)
% hObject    handle to Data_Compatibility_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.mc_gui),
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
close(handles.mc_gui),
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
close(handles.mc_gui),
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
close(handles.mc_gui),
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
close(handles.mc_gui),
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


