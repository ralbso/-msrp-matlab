function performance(bin)
% PERFORMANCE Quick glance at behavior during session.
%   Function takes either 0 or 1 as arg.
%   0 for latest session performance overview; 1 to select a session.
%   Returns session performance overview.
%   See also GETLATESTFILE, VLINE.

% tic

% Select latest .csv in directory
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
if bin > 1
    error('Arg can only be 0 or 1.')
end

file_path = fullfile(path, file_name); 
raw_data = fopen(file_path, 'r'); 

% read .csv with session data 
data = textscan(raw_data, '%f %f %f %f %f %f %f %f %f', 'Delimiter', ';'); 

% breakdown of .csv contents 
t = [data{1}];              % Time
pos = [data{2}];            % Position
t_frame = [data{3}];         % Time since last frame
vel = [data{4}];            % Velocity
vr_world = [data{5}];        % Current trial (short, long, blackbox)
valve_stat = [data{6}];      % Valve status
num_trials = [data{7}];      % Number of trials
num_licks = [data{8}];       % Number of licks
wheel_vel = [data{9}];       % Wheel velocity

% Create matrix from individual cell arrays (for easier handling)
all_data = [t pos t_frame vel vr_world valve_stat num_trials num_licks wheel_vel];

% Logicals. S for short, L for long.
S = vr_world == 3; 
L = vr_world == 4;

% Mouse position for each trial
pos_short = pos(S);
pos_long = pos(L);

% Trial # for each type of trial
num_trials_short = num_trials(S);
num_trials_long = num_trials(L);

% Licks on each trial
num_licks_short = num_licks(S);
num_licks_long = num_licks(L);

% Indexes of licks on each trial 
licks_short = find(num_licks_short); 
licks_long = find(num_licks_long); 

valve_stat_short = valve_stat(S);
valve_stat_long = valve_stat(L);

% Total trials
total_short_trials = length(unique(num_trials_short)); 
total_long_trials = length(unique(num_trials_long)); 

% Kudos to Quique, who helped me figure out for loops in MATLAB

% Separate arrays for triggered vs. default reward
tempT = zeros(length(valve_stat),1);
for t = 1:length(tempT)-1
    if valve_stat(t) ~= valve_stat(t+1) && valve_stat(t) == 1  % Triggered reward
        tempT(t) = 1; 
    end
end

triggered_rew = find(tempT);       % Indices of triggered rewards
find(num_licks(triggered_rew));    % Indices of licks && triggered

% Average velocity of mouse
tempV = zeros(length(vel),1);
thresh = 0.7;
for t = 1:length(vel)-1
    if vel(t) > thresh
        tempV(t) = vel(t); % velocities under thresh will be 0
    end
end

vels = tempV(tempV ~= 0);   % Holds velocities over thresholds
avg_vel = sum(vels)/length(vels);

% Figure setup, from this point on
figure
    
    % Short trials
    subplot(6,5,[2 28])
    plot(pos_short(licks_short), num_trials_short(licks_short), 'bo') 
    
    xlabel('Location (cm)') 
    xlim([50 350])
    ylabel('Trial #') 
    title('Short trials') 
    
    % Adds reference lines for landmark
    vline([200 240], {'k', 'k'})
    annotation('rectangle',[.436 .109 .039 .817],'FaceColor','black','FaceAlpha',.1)
    
    % Adds reference lines for reward zone
    vline([320 340], {'k', 'k'})
    annotation('rectangle', [.551 .109 .019 .817],'FaceColor', 'blue','FaceAlpha',.1)
    
    hold on;
    
    % Long trials
    subplot(6,5,[4 30])
    plot(pos_long(licks_long), num_trials_long(licks_long), 'ro')
    
    xlabel('Location (cm)')
    xlim([50 420])
    title('Long trials')
    
    % Adds reference lines for landmark
    vline([200 240], {'k', 'k'})
    annotation('rectangle',[.734 .109 .0325 .817],'FaceColor','black','FaceAlpha',.1)
    
    % Adds reference lines for reward zone
    vline([380 400], {'k', 'k'})
    annotation('rectangle', [.874 .109 .016 .817],'FaceColor','blue','FaceAlpha',.1)
    
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
% toc
end
