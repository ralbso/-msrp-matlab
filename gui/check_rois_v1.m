function varargout = check_rois(varargin)
% CHECK_ROIS MATLAB code for check_rois.fig
%      CHECK_ROIS, by itself, creates a new CHECK_ROIS or raises the existing
%      singleton*.
%
%      H = CHECK_ROIS returns the handle to a new CHECK_ROIS or the handle to
%      the existing singleton*.
%
%      CHECK_ROIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHECK_ROIS.M with the given input arguments.
%
%      CHECK_ROIS('Property','Value',...) creates a new CHECK_ROIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before check_rois_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to check_rois_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help check_rois

% Last Modified by GUIDE v2.5 07-Jul-2017 09:44:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @check_rois_OpeningFcn, ...
                   'gui_OutputFcn',  @check_rois_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before check_rois is made visible.
function check_rois_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to check_rois (see VARARGIN)

% Choose default command line output for check_rois
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes check_rois wait for user response (see UIRESUME)
% uiwait(handles.check_rois);


% --- Outputs from this function are returned to the command line.
function varargout = check_rois_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get file name and its local path
% if running on Raul's Mac
if ismac
    [handles.file_name, path] = uigetfile('*.sig', 'Select imaging data',...
     '/Users/Raul/coding/github/harnett_lab/msrp-matlab/gui');
end

% if running on lab's pcs
if ispc
    [handles.file_name, path] = uigetfile('*.sig', 'Select imaging data',...
     'C:\vr\vroutput\');
end


file_id = fullfile(path, handles.file_name);

disp(file_id)

handles.roi_data = dlmread(file_id); 

handles.col = 1;

handles.graph = plot(handles.roi_data(:,handles.col));
xlim([0 27800])

set(handles.roi_num, 'String', strcat("ROI ", num2str(handles.col)));

handles.tmp = ones(1, size(handles.roi_data,2));
handles.comment = strings(1, size(handles.roi_data,2));

guidata(hObject, handles)
 
% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.slider = hObject;

set(handles.slider, 'SliderStep', [1/5,2/5]) % Slider speed
slider_pos = get(handles.slider, 'Value');   % Slider position

get(handles.slider, 'Min');
get(handles.slider, 'Max');

guidata(hObject, handles)

% --- Executes on button press in prev.
function prev_Callback(hObject, eventdata, handles)
% hObject    handle to prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.col = handles.col - 1;

if handles.col <= 0
    handles.col = 1;
end

handles.graph = plot(handles.roi_data(:,handles.col));
xlim([0 27800])

set(handles.roi_num, 'String', strcat("ROI ", num2str(handles.col)));

guidata(hObject, handles)

% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.col = handles.col + 1;

if handles.col > size(handles.roi_data, 2)
    handles.col = size(handles.roi_data, 2);
end

handles.graph = plot(handles.roi_data(:,handles.col));
xlim([0 27800])

set(handles.roi_num, 'String', strcat("ROI ", num2str(handles.col)));

guidata(hObject, handles)


% --- Executes on button press in reject.
function reject_Callback(hObject, eventdata, handles)
% hObject    handle to reject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Change tmp value at col position if ROI is rejected 
handles.tmp(1, handles.col) = 0;

guidata(hObject, handles)


function comment_input_Callback(hObject, eventdata, handles)
% hObject    handle to comment_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of comment_input as text
%        str2double(get(hObject,'String')) returns contents of comment_input as a double

% handles.comment = get(hObject, 'string');

handles.comment(1, handles.col) = strcat('(', num2str(handles.col), ')', get(hObject, 'string'), ';');

guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function comment_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comment_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in button_save.
function button_save_Callback(hObject, eventdata, handles)
% hObject    handle to button_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

file_name = strrep(handles.file_name, '.sig', '');
save_rois = [file_name '.txt'];

fileID = fopen(save_rois, 'w');
fprintf(fileID, '%s', num2str(handles.tmp));
fclose(fileID);

comments_file = strrep(handles.file_name, '.sig', '');
save_comments = [comments_file '.csv'];

commentsID = fopen(save_comments, 'w');
fprintf(commentsID, '%s', handles.comment);
fclose(commentsID);


% --- Executes during object creation, after setting all properties.
function roi_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function roi_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.roi_num = hObject;



function jump_to_Callback(hObject, eventdata, handles)
% hObject    handle to jump_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jump_to as text
%        str2double(get(hObject,'String')) returns contents of jump_to as a double

handles.col = str2double(get(hObject, 'String'));

if handles.col > size(handles.roi_data, 2)
    error('Error. \nThere are %d ROIS. \nChoose another ROI.',...
        size(handles.roi_data, 2));
end

handles.graph = plot(handles.roi_data(:,handles.col));
xlim([0 27800])

set(handles.roi_num, 'String', strcat("ROI ", num2str(handles.col)));

guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function jump_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jump_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
