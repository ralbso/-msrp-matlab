handles.date = 'Day2017613';

% get h5 data name and path
try
    if ismac
        [handles.hdf5,path] = uigetfile('*.h5', 'Select h5 file',...
            '~/Downloads/');
    end
    if ispc
        [handles.hdf5, path] = uigetfile('*.h5', 'Select h5 file',...
            'F:\');
    end
catch
    error('There was a problem retrieving your file.')
end

assert(~isequal(handles.hdf5,0), 'h5 file selection cancelled.')

full_path = fullfile(path, handles.hdf5);
beh_data = h5read(full_path, ['/' handles.date '/behaviour_aligned']);

% set up time and position
t = beh_data(1,:);
pos = beh_data(2,:);
vr_world = beh_data(5,:);   % keep track of blackboxes

corridor = logical(vr_world ~= 5);

for i = 1:length(corridor)
    if corridor(i) == 0
        pos(i) = 0;
    end
end

%ax(handles.beh_plot);
figure
%plot(handles.beh_plot, t, pos);
plot(t,pos);


dF_data = h5read(full_path, ['/' handles.date '/dF_win']);

handles.col = 1;
handles.tmp = ones(1, size(dF_data,2));
handles.comment = strings(1, size(dF_data,2));

figure
plot(t,dF_data(handles.col,:));
