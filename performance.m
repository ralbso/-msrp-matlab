function performance(bin)
% PERFORMANCE Quick glance at behavior during session.
%   Function takes either 0 or 1 as arg.
%   0 for latest session performance overview; 1 to select a session.
%   Returns session performance overview.
%   See also GETLATESTFILE, VLINE.

% Automatic selection of most recent .csv file in directory
if bin == 0
    file_name = getLatestFile('C:\vr\vroutput\*.csv'); 
    path = 'C:\vr\vroutput\';
end

% Pop-up box for .csv file selection
if bin == 1
    [file_name, path] = uigetfile('*.csv', 'Select raw data', 'C:\vr\vroutput\');
    if isequal(file_name, 0)
        error('File selection was cancelled.')
    end
end

% Arg can only be 0 or 1
if bin > 1 || bin < 0
    error('Arg can only be 0 or 1.')
end

file_path = fullfile(path, file_name); 
raw_data = fopen(file_path, 'r'); 

% read .csv with session data 
data = textscan(raw_data, '%f %f %f %f %f %f %f %f %f', 'Delimiter', ';'); 

% breakdown of .csv contents 
t = [data{1}];                  % Time
pos = [data{2}];                % Position
t_frame = [data{3}];            % Time since last frame
vel = [data{4}];                % Velocity
vr_world = [data{5}];           % Current trial (short, long, blackbox)
valve_stat = [data{6}];         % Valve status
num_trials = [data{7}];         % Number of trials
licks = [data{8}];              % Number of licks
wheel_vel = [data{9}];          % Wheel velocity

% Create matrix from individual cell arrays (for easier handling)
all_data = [t pos t_frame vel vr_world valve_stat num_trials licks wheel_vel];

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

% Valve status
valve_change = diff(valve_stat);               % Only valve changes matter to us

temp_trig = zeros(length(valve_change),1);     % Convert into logical
for t = 1:length(valve_change)
    if valve_change(t) == 1
        temp_trig(t) = valve_change(t);
    end
end

temp_def = zeros(length(valve_change),1);
for t = 1:length(valve_change)                 % Convert into logical
    if valve_change(t) == 2
        temp_def(t-1) = 1;
    end
end

temp_trig = logical([temp_trig;0]);
temp_def = logical([temp_def;0]);

trig_short_ind = find(temp_trig(short));
trig_long_ind = find(temp_trig(long));
default_short_ind = find(temp_def(short));
default_long_ind = find(temp_def(long));

% Honorable mention to Quique, who helped me refresh for loops in MATLAB
% Average velocity of mouse
tempV = zeros(length(vel),1);
thresh = 0.7;               % Slower speed is considered stationary
for t = 1:length(vel)-1
    if vel(t) > thresh
        tempV(t) = vel(t);  % Velocities under thresh will remain as 0
    end
end

vels = tempV(tempV ~= 0);   % Holds velocities over thresholds
avg_vel = sum(vels)/length(vels);

% For plotting:
% Licks along the tracks
pos_licks_short = pos_short(licks_short);
trial_licks_short = num_trials_short(licks_short);
pos_licks_long = pos_long(licks_long);
trial_licks_long = num_trials_long(licks_long);

% Triggered rewards
pos_triggered_short = pos_short(trig_short_ind);
trial_triggered_short = num_trials_short(trig_short_ind);
pos_triggered_long = pos_long(trig_long_ind);
trial_triggered_long = num_trials_long(trig_long_ind);

% Default rewards
pos_short_def = pos_short(default_short_ind);
trial_short_def = num_trials_short(default_short_ind);
pos_long_def = pos_long(default_long_ind);
trial_long_def = num_trials_long(default_long_ind);

% Figure setup, from this point on
figure
    
    % Short trials
    subplot(6,5,[2 28])
    plot(pos_licks_short, trial_licks_short, 'bo') 
    
    xlabel('Location (cm)')
    xlim([50 350])
    ylabel('Trial #') 
    title('Short trials') 
    
    % Adds reference lines for landmark
    vline([200 240], {'k', 'k'})
    annotation('rectangle',[.436 .1095 .039 .8164],'FaceColor','black','FaceAlpha',.1)
    
    % Adds reference lines for reward zone
    vline([320 340], {'k', 'k'})
    annotation('rectangle', [.551 .1095 .019 .8164],'FaceColor', 'blue','FaceAlpha',.1)
    hold on;
    
    plot(pos_triggered_short, trial_triggered_short, 'g*')
    hold on;
    
    plot(pos_short_def, trial_short_def, 'r*')
    hold on;
    
    % Long trials
    subplot(6,5,[4 30])
    plot(pos_licks_long, trial_licks_long, 'bo')
    
    xlabel('Location (cm)')
    xlim([50 420])
    title('Long trials')
    
    % Adds reference lines for landmark
    vline([200 240], {'k', 'k'})
    annotation('rectangle',[.734 .1095 .0325 .8164],'FaceColor','black','FaceAlpha',.1)
    
    % Adds reference lines for reward zone box
    vline([380 400], {'k', 'k'})
    annotation('rectangle', [.874 .1095 .016 .8164],'FaceColor','magenta','FaceAlpha',.1)
    hold on;
    
    plot(pos_triggered_long, trial_triggered_long, 'g*')
    hold on;
    
    plot(pos_long_def, trial_long_def, 'r*')
    hold on;
    
    % Adds textbox for session information
    axes('Position', [0.01 0 1 1], 'Visible', 'off');
    descr = {'Short trials:';
        strcat(num2str(total_short_trials), ' trials');
        '';
        'Long trials:';
        strcat(num2str(total_long_trials), ' trials');
        '';
        'Average velocity:';
        strcat(num2str(avg_vel), ' cm/s')};
    text(0.025,0.5,descr)
    
    % Figure parameters
    x0 = 350;       % x position on screen
    y0 = 200;       % y Position on screen
    width = 900;    
    height = 500;   
    set(gcf, 'units','points','position',[x0,y0,width,height])

file_name = strrep(file_name, '.csv', '');
save_session = [file_name '.png'];
saveas(gcf, save_session);

fclose(raw_data); 
end
