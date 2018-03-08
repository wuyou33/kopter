function varargout = sid_gui(varargin)
%
%  SID_GUI  M-file for sid_gui.fig.
%
%      SID_GUI, by itself, creates a new SID_GUI or raises the existing
%      singleton*.
%
%      H = SID_GUI returns the handle to a new SID_GUI or the handle to
%      the existing singleton*.
%
%      SID_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SID_GUI.M with the given input arguments.
%
%      SID_GUI('Property','Value',...) creates a new SID_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sid_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sid_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sid_gui

% Last Modified by GUIDE v2.5 05-Aug-2006 23:49:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sid_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @sid_gui_OutputFcn, ...
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


% --- Executes just before sid_gui is made visible.
function sid_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sid_gui (see VARARGIN)

% Choose default command line output for sid_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sid_gui wait for user response (see UIRESUME)
% uiwait(handles.sid_gui);

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
%  Plot the first workspace variable.
%
sid_ws_var_plot


% --- Outputs from this function are returned to the command line.
function varargout = sid_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function ws_var_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ws_var_listbox (see GCBO)
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
%  Initialize the variable list.
%
vars = evalin('base','who');
set(hObject,'String',vars);
%
%  Initial plot uses the first workspace variable.
%
set(hObject,'Value',1);


% --- Executes on selection change in ws_var_listbox.
function ws_var_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to ws_var_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ws_var_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ws_var_listbox

%
%  User code.
%
sid_ws_var_plot


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
%  Update the listbox.
%
set(hObject,'String',varlist);


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
sid_var_plot


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over sidpac_var_listbox.
function sidpac_var_listbox_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to sidpac_var_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%
%  Update the documentation for the fdata channel 
%  selected with a right mouse click, and 
%  place the information in the fds flight data structure 
%  located in the MATLAB workspace.
%
iy=get(handles.sidpac_var_listbox,'Value');
%
%  Show the current documentation, if it exists.
%
if evalin('base',['isempty(fds.vardesc{',num2str(iy),'})'])
  def={'elevator  (deg)','el','(deg)'};
else
%
%  Description.
%
  def{1}=evalin('base',['fds.vardesc{',num2str(iy),'}']);
%
%  Strip off the leading and trailing blanks.
%
  cd=def{1};
  nc=length(cd);
  def{1}=cd(3:nc-1);
%
%  Label.
%
  def{2}=evalin('base',['fds.varlab{',num2str(iy),'}']);
  cd=def{2};
  nc=length(cd);
  def{2}=cd(3:nc-1);
%
%  Units.
%
  def{3}=evalin('base',['fds.varunits{',num2str(iy),'}']);
  cd=def{3};
  nc=length(cd);
  def{3}=cd(2:nc-1);
end
data=inputdlg({'Description: ','Label: ','Units: '},...
               'Data Assign',...
              [1,27;1,6;1,10],def);
%
%  Skip the documentation update if the dialog box input is cancelled.
%
if ~isempty(data)
  evalin('base',['fds.vardesc{',num2str(iy),'}=[''  '',''',data{1},''','' ''];']);
  evalin('base',['fds.varlab{',num2str(iy),'}=[''  '',''',data{2},''','' ''];']);
  evalin('base',['fds.varunits{',num2str(iy),'}=['' '',''',data{3},''','' ''];']);
end
%
%  Update the listbox and plot.
%
sid_var_list
sid_var_plot


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
  sid_plot
end


% --- Executes on button press in update_ws_var_pushbutton.
function update_ws_var_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to update_ws_var_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Update the variable list.
%
vars = evalin('base','who');
set(handles.ws_var_listbox,'String',vars)
%
%  Save data in the handles structure.
%
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function array_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to array_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in array_popup.
function array_popup_Callback(hObject, eventdata, handles)
% hObject    handle to array_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns array_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from array_popup

%
%  User code.
%
handles.data.yp=evalin('base',[handles.label.yp,'(:,',num2str(get(handles.array_popup,'Value')),');']);
%
%  Save data in the handles structure.
%
guidata(hObject, handles);
sid_plot


% --- Executes during object creation, after setting all properties.
function vector_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vector_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in vector_popup.
function vector_popup_Callback(hObject, eventdata, handles)
% hObject    handle to vector_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns vector_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from vector_popup

%
%  User code.
%
yp=evalin('base',[handles.label.yp,'(',num2str(get(handles.vector_popup,'Value')),');']);
handles.data.yp=yp*ones(size(handles.data.xp,1),1);
handles.units.yp='   ';
%
%  Save data in the handles structure.
%
guidata(hObject, handles);
sid_plot


% --- Executes on button press in clear_pushbutton.
function clear_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clear_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Clear the selected column in the fdata matrix.
%
ichnl=get(handles.sidpac_var_listbox,'Value');
evalin('base',['fdata(:,',num2str(ichnl),')=zeros(size(fdata,1),1);']);
%
%  Update the listbox and plot.
%
sid_var_list
sid_var_plot


% --- Executes on button press in assign_pushbutton.
function assign_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to assign_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
sid_assign


% --- Executes during object creation, after setting all properties.
function assign_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to assign_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%
%  User code.
%
nchnls=evalin('base','size(fdata,2)');
set(hObject,'Visible','on','String',num2str([1:nchnls]'));
set(hObject,'Value',1)


% --- Executes on selection change in assign_popup.
function assign_popup_Callback(hObject, eventdata, handles)
% hObject    handle to assign_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns assign_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from assign_popup


% --- Executes during object creation, after setting all properties.
function convert_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to convert_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%
%  User code.
%
%  Define variable conversion labels.
%
convlist={'lbf/ft2 to N/m2';...
          'N/m2 to lbf/ft2';...
          'lbf to N';...
          'N to lbf';...
          'slug-ft2 to kg-m2';...
          'kg-m2 to slug-ft2';...
          'slug to kg';...
          'kg to slug';...
          'lbm to slug';...
          'slug to lbm';...
          'mph to ft/sec';...
          'ft/sec to mph';...
          'kts to ft/sec';...
          'ft/sec to kts';...
          'ft/sec2 to g';...
          'g to ft/sec2';...
          'mm to cm';...
          'cm to mm';...
          'mm to m';...
          'm to mm';...
          'in to ft';...
          'ft to in';...
          'm to ft';...
          'ft to m';...
          'rad to deg';...
          'deg to rad'};
set(hObject,'String',convlist)
set(hObject,'Value',length(convlist))


% --- Executes on selection change in convert_popup.
function convert_popup_Callback(hObject, eventdata, handles)
% hObject    handle to convert_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns convert_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from convert_popup

%
%  User code.
%
%  Apply the selected unit conversion and plot the result.
%
sid_convert;
%
%  Update the display if the current
%  variable is a scalar, then plot.
%
if strcmp(get(handles.scalar_text,'Visible'),'on')
  set(handles.scalar_text,'String',['Scalar: ',num2str(handles.data.yp(1))]);
end
sid_plot;


% --- Executes on button press in close_pushbutton.
function close_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to close_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.sid_gui),
evalin('base','clear guiH;');


% --------------------------------------------------------------------
function SIDPAC_1_Callback(hObject, eventdata, handles)
% hObject    handle to SIDPAC_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Maneuver_Cut_2_Callback(hObject, eventdata, handles)
% hObject    handle to Maneuver_Cut_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.sid_gui),
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
close(handles.sid_gui),
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
close(handles.sid_gui),
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
close(handles.sid_gui),
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
close(handles.sid_gui),
evalin('base','clear guiH;');
evalin('base','oe_gui;');


% --------------------------------------------------------------------
function Transfer_Function_Modeling_3_Callback(hObject, eventdata, handles)
% hObject    handle to Transfer_Function_Modeling_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Exit_2_Callback(hObject, eventdata, handles)
% hObject    handle to Exit_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.sid_gui),
evalin('base','clear guiH;');


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


