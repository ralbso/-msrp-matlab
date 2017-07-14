% get file name and its local path
try
    % if running on Raul's Mac
    if ismac
         [handles.file_name] = uigetfile('M01_000_*_rigid.*', 'Select imaging data',...
             '/Volumes/LaCie');
    end

    % if running on lab's pcs
    if ispc
        [handles.file_name, path] = uigetfile('*.sig;*rigid.sbx', 'Select imaging data',...
         'C:\vr\vroutput\', 'MultiSelect', 'on');
    end
catch
    error('Files do not exist')
end

if isequal(handles.file_name,0)
    error('File selection cancelled')
else
    disp('Files selected:')
    disp(handles.file_name)
end

[pathstr, name, ext] = fileparts(handles.file_name);

handles.file_name = [pathstr name];

disp(handles.file_name)

sig_file = [handles.file_name '.sig'];
sbx_file = [handles.file_name '.sbx'];

% open file
file_id = fullfile(path, sig_file);
disp(file_id)
handles.roi_data = dlmread(file_id); 