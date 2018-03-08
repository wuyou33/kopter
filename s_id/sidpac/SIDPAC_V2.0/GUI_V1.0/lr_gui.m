function varargout = lr_gui(varargin)
%
%  LR_GUI  M-file for lr_gui.fig.
%
%      lr_GUI, by itself, creates a new lr_GUI or raises the existing
%      singleton*.
%
%      H = lr_GUI returns the handle to a new lr_GUI or the handle to
%      the existing singleton*.
%
%      lr_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in lr_GUI.M with the given input arguments.
%
%      lr_GUI('Property','Value',...) creates a new lr_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lr_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lr_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lr_gui

% Last Modified by GUIDE v2.5 05-Aug-2006 23:47:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lr_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @lr_gui_OutputFcn, ...
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


% --- Executes just before lr_gui is made visible.
function lr_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lr_gui (see VARARGIN)

% Choose default command line output for lr_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lr_gui wait for user response (see UIRESUME)
% uiwait(handles.lr_gui);

%
%  User code
%
%
%  Save the abscissa data for plotting via callbacks.
%
handles.data.xp=evalin('base','t');
handles.label.xp=evalin('base','char(fds.varlab(1))');
handles.units.xp=evalin('base','char(fds.varunits(1))');
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
%  Plot the first SIDPAC variable.
%
sid_var_plot
%
%  Initialize the modeling method flag.
%
evalin('base','mflg=0;');
%
%  Clear any previous X and Z, if they are not the right size, 
%  or if there is no list for them.  
%
if evalin('base','exist(''X'',''var'') & exist(''Z'',''var'')') ...
   & evalin('base','size(X,1)==size(t,1) & size(Z,1)==size(t,1)') ...
   & evalin('base','exist(''Xlist'',''var'') & exist(''Zlist'',''var'')')    
  evalin('base','set(guiH.regressor_listbox,''String'',Xlist);');
  evalin('base','set(guiH.output_popup,''String'',Zlist);');
else
  evalin('base','clear X Z Xlist Zlist;');
end


% --- Outputs from this function are returned to the command line.
function varargout = lr_gui_OutputFcn(hObject, eventdata, handles)
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
%  Assign computed quantities
%  if this has not been done, 
%  indicated by whether or not 
%  CZ has not been assigned.  
%
if evalin('base','norm(fdata(:,63))==0')
  evalin('base','fdata=compfmc(fdata);');
end
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
%
%  Plot the data from the listbox
%  only if the selected channel has been 
%  previously assigned to non-zero values.  
%
ichnl=get(hObject,'Value');
if evalin('base',['norm(fdata(:,',num2str(ichnl),'))'])~=0
%
%  Turn off the output plot listbox and associated text.
%
  set(handles.output_plot_text,'Visible','off');
  set(handles.output_plot_popup,'Visible','off');
  sid_var_plot
  sid_var_list
end


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


% --- Executes during object creation, after setting all properties.
function regressor_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regressor_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in regressor_listbox.
function regressor_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to regressor_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns regressor_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from regressor_listbox

%
%  User code.
%
lr_rplot;


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over regressor_listbox.
function regressor_listbox_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to regressor_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Update the documentation for the selected regressor
%  with a right mouse click.
%
ir=get(handles.regressor_listbox,'Value');
%
%  Show the current documentation, if it exists.
%
if evalin('base',['isempty(Xlist{',num2str(ir),'})'])
  def={['el',' (deg) ']};
else
%
%  Description.
%
  def=evalin('base',['cellstr(Xlist{',num2str(ir),'})']);
end
data=inputdlg({'Label: '},'Regressor Label',[1,27],def);
%
%  Skip the documentation update if the dialog box input is cancelled.
%
if ~isempty(data)
%
%  Make sure the first two characters are spaces.
%
  data=char(data);
  if ~strcmp(data(1),' ')
    data=['  ',data];
  end
  if ~strcmp(data(2),' ')
    data=[' ',data];
  end
  Xlist=get(handles.regressor_listbox,'String');
  Xlist{ir}=data;
%
%  Update the regressor listbox.
%
  set(handles.regressor_listbox,'String',Xlist);
%
%  Update the workspace list variable.
%
  evalin('base','Xlist=get(guiH.regressor_listbox,''String'');');
%
%  Plot the regressor with the modified label.
%
  lr_rplot
end


% --- Executes during object creation, after setting all properties.
function output_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in output_popup.
function output_popup_Callback(hObject, eventdata, handles)
% hObject    handle to output_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns output_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from output_popup

%
%  User code.
%
lr_oplot;


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over output_popup.
function output_popup_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to output_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Update the documentation for the selected output
%  with a right mouse click.
%
io=get(handles.output_popup,'Value');
%
%  Show the current documentation, if it exists.
%
if evalin('base',['isempty(Zlist{',num2str(io),'})'])
  def={['CZ','  ']};
else
%
%  Description.
%
  def=evalin('base',['cellstr(Zlist{',num2str(io),'})']);
end
data=inputdlg({'Label: '},'Output Label',[1,27],def);
%
%  Skip the documentation update if the dialog box input is cancelled.
%
if ~isempty(data)
%
%  Make sure the first two characters are spaces.
%
  data=char(data);
  if ~strcmp(data(1),' ')
    data=['  ',data];
  end
  if ~strcmp(data(2),' ')
    data=[' ',data];
  end
  Zlist=get(handles.output_popup,'String');
  Zlist{io}=data;
%
%  Update the output popup.
%
  set(handles.output_popup,'String',Zlist);
%
%  Update the workspace list variable.
%
  evalin('base','Zlist=get(guiH.output_popup,''String'');');
%
%  Plot the output with the modified label.
%
  lr_oplot
end


% --- Executes on button press in output_delete_pushbutton.
function output_delete_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to output_delete_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Clear the selected column in the output matrix, 
%  as long as there is a data column available to be cleared.  
%
if evalin('base','exist(''Z'',''var'')')
  n=evalin('base','size(Z,2)');
  if n > 1
    ichnl=get(handles.output_popup,'Value');
    chnls=[1:n];
    chnls=find(chnls~=ichnl);
%
%  Update the output matrix in the workspace.
%
    evalin('base',['Z=Z(:,[',num2str(chnls),']);']);
    Zlist=get(handles.output_popup,'String');
%
%  Use character array to delete one member
%  of the list. 
%
    Zchar=char(Zlist);
    Zlist=cellstr(Zchar(chnls,:));
  else
    evalin('base','clear Z;');
    Zlist='Popup';
  end
else
  Zlist='Popup';
end
%
%  Update the output listbox.
%
set(handles.output_popup,'String',Zlist);
%
%  Update the workspace list variable.
%
evalin('base','Zlist=get(guiH.output_popup,''String'');');
%
%  Highlight the last output, if there is one.
%
if evalin('base','exist(''Z'',''var'')')
  set(handles.output_popup,'Value',evalin('base','size(Z,2)'));
%
%  Plot the data from the listbox.
%
  lr_oplot;
end


% --- Executes on button press in output_add_pushbutton.
function output_add_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to output_add_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Assign the plotted variable to the 
%  output matrix.  
%
evalin('base','guiH=guidata(gcf);');
if evalin('base','exist(''Z'',''var'')')
  evalin('base','Z=[Z,guiH.data.yp];');
  Zlist=get(handles.output_popup,'String');
  Zlist={char(Zlist);[handles.label.yp,handles.units.yp]};
else
  evalin('base','Z=guiH.data.yp;');
  Zlist=cellstr([handles.label.yp,handles.units.yp]);
end
%
%  Update the output listbox.
%
set(handles.output_popup,'String',Zlist);
%
%  Update the workspace list variable.
%
evalin('base','Zlist=get(guiH.output_popup,''String'');');
%
%  Highlight the last output.
%
set(handles.output_popup,'Value',evalin('base','size(Z,2)'));


% --- Executes during object creation, after setting all properties.
function data_conditioning_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_conditioning_popup (see GCBO)
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
%  Define data conditioning labels.
%
condlist={'zero-lag filter';...
          'optimal Fourier smoother';...
          'bias removal';...
          'linear detrend';...
          'cubic detrend';...
          'Fourier transform';...
          'smooth numerical differentiation';...
          'custom workspace variable'};
set(hObject,'String',condlist)


% --- Executes on selection change in data_conditioning_popup.
function data_conditioning_popup_Callback(hObject, eventdata, handles)
% hObject    handle to data_conditioning_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns data_conditioning_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from data_conditioning_popup


% --- Executes on button press in regressor_add_pushbutton.
function regressor_add_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to regressor_add_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Assign the plotted variable to the 
%  regressor matrix.  
%
evalin('base','guiH=guidata(gcf);');
if evalin('base','exist(''X'',''var'')')
  evalin('base','X=[X,guiH.data.yp];');
  Xlist=get(handles.regressor_listbox,'String');
  Xlist={char(Xlist);[handles.label.yp,handles.units.yp]};
else
  evalin('base','X=guiH.data.yp;');
  Xlist=cellstr([handles.label.yp,handles.units.yp]);
end
%
%  Update the regressor listbox.
%
set(handles.regressor_listbox,'String',Xlist);
%
%  Update the workspace list variable.
%
evalin('base','Xlist=get(guiH.regressor_listbox,''String'');');
%
%  Highlight the last regressor.
%
set(handles.regressor_listbox,'Value',evalin('base','size(X,2)'));


% --- Executes on button press in regressor_delete_pushbutton.
function regressor_delete_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to regressor_delete_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
%  Clear the selected column in the regressor matrix, 
%  as long as there is a data column available to be cleared.  
%
if evalin('base','exist(''X'',''var'')')
  n=evalin('base','size(X,2)');
  if n > 1
    ichnl=get(handles.regressor_listbox,'Value');
    chnls=[1:n];
    chnls=find(chnls~=ichnl);
%
%  Update the regressor matrix in the workspace.
%
    evalin('base',['X=X(:,[',num2str(chnls),']);']);
    Xlist=get(handles.regressor_listbox,'String');
%
%  Use character array to delete one member
%  of the list. 
%
    Xchar=char(Xlist);
    Xlist=cellstr(Xchar(chnls,:));
  else
    evalin('base','clear X;');
    Xlist='Listbox';
  end
else
  Xlist='Listbox';
end
%
%  Update the regressor listbox.
%
set(handles.regressor_listbox,'String',Xlist);
%
%  Update the workspace list variable.
%
evalin('base','Xlist=get(guiH.regressor_listbox,''String'');');
%
%  Highlight the last regressor, if there is one.
%
if evalin('base','exist(''X'',''var'')')
  set(handles.regressor_listbox,'Value',evalin('base','size(X,2)'));
%
%  Plot the data from the listbox.
%
  lr_rplot;
end


% --- Executes during object creation, after setting all properties.
function output_plot_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_plot_popup (see GCBO)
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
set(hObject,'Value',1);


% --- Executes on selection change in output_plot_popup.
function output_plot_popup_Callback(hObject, eventdata, handles)
% hObject    handle to output_plot_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns output_plot_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from output_plot_popup

%
%  User code.
%
%  Plot the model fit according user input.
%
%  Get the popup value, if it's visible.
%
if strcmp(get(handles.output_plot_popup,'Visible'),'on')
  if evalin('base','exist(''Z'',''var'')')
    evalin('base','zcol=get(guiH.output_popup,''Value'');');
%
%  Plot measured and model output comparison, or residuals.
%
    if (get(handles.output_plot_popup,'Value')==1)
      evalin('base','plot(t,Z(:,zcol),t,y,''--''),');
      evalin('base','ylabel(Zlist(zcol)),');
      evalin('base','legend(''data'',''model'',0),');
    else
      evalin('base','plot(t,Z(:,zcol)-y),');
      evalin('base','ylabel(''residuals''),');
    end
    xlabel([handles.label.xp,handles.units.xp]);
    if get(handles.grid_radiobutton,'Value')==1
      grid on
    else
      grid off
    end
  end
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


% --- Executes during object creation, after setting all properties.
function lonlat_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lonlat_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
dtr=pi/180;
fdata=evalin('base','fdata;');
lflg=get(hObject,'Value');
if lflg==1
  X=[fdata(:,4)*dtr,fdata(:,72),fdata(:,14)*dtr];
  Xlist=evalin('base',['{[fds.varlab{4},'' (rad) ''];',...
               '[fds.varlab{72},fds.varunits{72}];[fds.varlab{14},'' (rad) '']}']);
  Z=fdata(:,[63,65,61]);
  Zlist=evalin('base','{fds.varlab{63};fds.varlab{65};fds.varlab{61}}');
end
if lflg==2
  X=[fdata(:,3)*dtr,fdata(:,[71,73]),fdata(:,[15,16])*dtr];
  Xlist=evalin('base',['{[fds.varlab{3},'' (rad) ''];',...
               '[fds.varlab{[71]},fds.varunits{[71]}];',...
               '[fds.varlab{[73]},fds.varunits{[73]}];',...
               '[fds.varlab{15},'' (rad) ''];[fds.varlab{16},'' (rad) '']}']);
  Z=fdata(:,[62,64,66]);
  Zlist=evalin('base','{fds.varlab{62};fds.varlab{64};fds.varlab{66}}');
end
%
%  Update the regressor matrix and measured outputs.
%
assignin('base','X',X);
assignin('base','Z',Z);
%
%  Update the regressor and output listboxes.
%
set(handles.regressor_listbox,'String',Xlist);
set(handles.output_popup,'String',Zlist);
%
%  Update the variable lists.
%
evalin('base','Xlist=get(guiH.regressor_listbox,''String'');');
evalin('base','Zlist=get(guiH.output_popup,''String'');');
%
%  Plot the first regressor.
%
set(handles.output_popup,'Value',1);
set(handles.regressor_listbox,'Value',1);
lr_rplot;


% --- Executes during object creation, after setting all properties.
function ws_var_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ws_var_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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


% --- Executes during object creation, after setting all properties.
function array_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to array_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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


% --- Executes on button press in lesq_pushbutton.
function lesq_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to lesq_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
evalin('base','lr_est;');


% --- Executes on button press in save_pushbutton.
function save_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
evalin('base','lr_save;');


% --- Executes on button press in close_pushbutton.
function close_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to close_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.lr_gui),
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
close(handles.lr_gui),
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
close(handles.lr_gui),
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
close(handles.lr_gui),
evalin('base','clear guiH;');
evalin('base','dcmp_gui;');


% --------------------------------------------------------------------
function Modeling_2_Callback(hObject, eventdata, handles)
% hObject    handle to Modeling_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Stepwise_Regression_Modeling_3_Callback(hObject, eventdata, handles)
% hObject    handle to Stepwise_Regression_Modeling_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%
%  User code.
%
close(handles.lr_gui),
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
close(handles.lr_gui),
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
close(handles.lr_gui),
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


