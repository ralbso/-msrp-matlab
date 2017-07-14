% get file name and its local path
try
    % if running on Raul's Mac
    if ismac
%          [pathstr, handles.file_name, ext] = fileparts(uigetfile('M01_000_*_rigid.*', 'Select imaging data',...
%              '/Volumes/LaCie'));
         
         [handles.file_name, pathstr] = uigetfile('M01_000_*_rigid.*', 'Select imaging data',...
             '/Volumes/LaCie');
    end

    % if running on lab's pcs
    if ispc
        [pathstr, handles.file_name] = uigetfile('*.sig;*rigid.sbx', 'Select imaging data',...
         'C:\vr\vroutput\', 'MultiSelect', 'on');
    end
catch
    error('There was a problem getting your file.')
end

if isequal(handles.file_name,0)
    error('File selection cancelled')
else
    disp('Files selected:')
    disp(handles.file_name)
end

disp(['0 ' handles.file_name])
[~, name, ext] = fileparts(handles.file_name);
disp(['1 ' pathstr])
disp(['2 ' name])
disp(['2.5 ' ext])

handles.file_name = [pathstr name];

disp(['3 ' handles.file_name])

sig_file = [handles.file_name '.sig'];
sbx_file = [handles.file_name '.sbx'];

% open file
file_id = sig_file;
disp(['4 ' file_id])
handles.roi_data = dlmread(file_id); 