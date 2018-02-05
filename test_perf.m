%%
[file_name, path] = uigetfile('*.csv', 'Select raw data', 'C:\vr\vroutput\');

file_path = fullfile(path, file_name); 

% read .csv with session data 
data = dlmread(file_path);
%%
t = data(:,1);                  % Time
pos = data(:,2);                % Position
t_frame = data(:,3);            % Time since last frame
vel = data(:,4);                % Velocity
vr_world = data(:,5);           % Current trial (short, long, blackbox)
valve_stat = data(:,6);         % Valve status
num_trials = data(:,7);         % Trial number
licks = data(:,8);              % Number of licks
wheel_vel = data(:,9);          % Wheel velocity

% Data on short tracks
short = vr_world == 3;                         % Short track is track 3
pos_short = pos(short, :);                     % Location
num_trials_short = num_trials(short, :);       % Trial #
licks_short = find(licks(short));              % Indices of licks
total_short_trials = length(unique(num_trials_short)); % Total trials

% Data on long tracks
long = vr_world == 4;                          % Long track is track 4
pos_long = pos(long, :);                       % Location
num_trials_long = num_trials(long, :);         % Trial #
licks_long = find(licks(long));                % Indices of licks
total_long_trials = length(unique(num_trials_long));    % Total trials

first_licks_short = pos_trial_mat_short(1,:);
currVal = pos_trial_mat_short(1,2);

for ii = 2:size(pos_trial_mat_short,1)
    if(pos_trial_mat_short(ii,2) ~= currVal)
        first_licks_short = [first_licks_short;...
            pos_trial_mat_short(ii,:)];
        currVal = pos_trial_mat_short(ii,2);
    end
end

pos_trial_mat_long = [pos_licks_long trial_licks_long];
first_licks_long = pos_trial_mat_long(1,:);
currVal = pos_trial_mat_long(1,2);

for ii = 2:size(pos_trial_mat_long,1)
    if(pos_trial_mat_long(ii,2) ~= currVal)
        first_licks_long = [first_licks_long;...
            pos_trial_mat_long(ii,:)];
        currVal = pos_trial_mat_long(ii,2);
    end
end