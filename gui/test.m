try
    if ismac
        [handles.beh,path_beh] = uigetfile('MTH3_vr1_*.csv', 'Select behavioral data',...
            '/Volumes/LaCie');
    end
    if ispc
        [handles.beh, path_beh] = uigetfile('MTH3_vr1_*.csv', 'Select behavioral data',...
            'F:\');
    end
catch
    error('There was a problem retrieving your file.')
end

assert(~isequal(handles.beh,0), 'Behavioral file selection cancelled.')

file_path = fullfile(path_beh, handles.beh);

data = dlmread(file_path);

t = data(:,1);
pos = data(:,2);
vr_world = data(:,5);

blackbox = vr_world ~= 5;

for i = 1:length(vr_world)
    if vr_world(i) == blackbox
        pos(i) = 0;
    end
end

