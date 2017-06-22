tic
%UNCOMMENT NEXT LINE AFTER TESTS ARE DONE 
%sessionData = getLatestFile('C:\vr\vroutput\*.csv'); 
sessionData = ('MTH3_vr1_2017615_1731.csv'); 
filePath = fullfile('Users', 'Raul', 'coding', 'mit', 'harnett', 'msrp-matlab', sessionData);
%filePath = fullfile('C:', 'vr', 'vroutput', sessionData); 
file = fopen(filePath, 'r'); 
% read .csv with session data 
data = textscan(file, '%f %f %f %f %f %f %f %f %f', 'Delimiter', ';'); 

% breakdown of .csv contents 
t = [data{1}];              % Time
pos = [data{2}];            % Position
tFrame = [data{3}];         % Time since last frame
vel = [data{4}];            % Velocity
vrWorld = [data{5}];        % Current trial (short, long, blackbox)
valveStat = [data{6}];      % Valve status
numTrials = [data{7}];      % Number of trials
numLicks = [data{8}];       % Number of licks
wheelVel = [data{9}];       % Wheel velocity

% Join individual cell arrays into a single matrix
allData = [t pos tFrame vel vrWorld valveStat numTrials numLicks wheelVel];

% Logicals. S for short, L for long.
S = vrWorld == 3; 
L = vrWorld == 4;

% Mouse position for each trial
posShort = pos(S);
posLong = pos(L);

% Trial # for each type of trial
numTrialsShort = numTrials(S);
numTrialsLong = numTrials(L);

% Licks on each trial
numLicksShort = numLicks(S);
numLicksLong = numLicks(L);

% Indexes of licks on each trial 
licksShort = find(numLicksShort); 
licksLong = find(numLicksLong); 

% Total trials
totalShortTrials = length(unique(numTrialsShort)); 
totalLongTrials = length(unique(numTrialsLong)); 

% Kudos to Quique, who helped me figure out for loops in MATLAB

% Separate arrays for triggered vs. automatic reward
tempT = zeros(length(numLicks),1);
for t = 1:length(tempT)-1
    if numLicks(t) == 1
        tempT(t) = 1;
    end
end

triggeredTemp = find(tempT);    % Indexes of triggered rewards
triggered = numLicks(tempT ~= 0);
triggeredShort = intersect(licksShort, triggeredTemp);
triggeredLong = intersect(licksLong, triggeredTemp);

tempA = zeros(length(numLicks),1);
for t = 1:length(tempA)-1
    if numLicks(t) == 2
        tempA(t) = 1;
    end
end

autoTemp = find(tempA);         % Indexes of automatic rewards
auto = numLicks(tempA ~= 0);
autoShort = intersect(licksShort, autoTemp);
autoLong = intersect(licksLong, autoTemp);

% Average velocity of mouse
tempV = zeros(length(vel),1);
threshold = 0.7;
for t = 1:length(vel)-1
    if vel(t) > threshold
        tempV(t) = vel(t);
    end
end

vels = tempV(tempV ~= 0);   % Holds velocities over thresholds
avgVel = sum(vels)/length(vels);

% Figure setup, from this point on
figure
    subplot(6,5,[2 28])
    plot(posShort(licksShort), numTrialsShort(licksShort), 'bo') 
    
    xlabel('Position') 
    ylabel('Trial #') 
    title('Short trials') 
    
    % Adds opaque rectangle to identify key areas
    annotation('rectangle',[.436 .11 .039 .813],'FaceColor','black','FaceAlpha',.1)
    vline([200 240], {'k', 'k'})
    hold on;
    
    subplot(6,5,[4 30])
    plot(posLong(licksLong), numTrialsLong(licksLong), 'ro')
    
    xlabel('Position')
    title('Long trials')
    
    % Adds opaque rectangle to identify key areas
    annotation('rectangle',[.7418 .11 .0325 .813],'FaceColor','black','FaceAlpha',.1)
    vline([200 240], {'k', 'k'})
    hold on;
    
    % Adds textbox for general session information
    ax1 = axes('Position', [0.01 0 1 1], 'Visible', 'off');
    descr = {'Short trials:';
        strcat(num2str(totalShortTrials), ' trials');
        '';
        'Long trials:';
        strcat(num2str(totalLongTrials), ' trials');
        '';
        'Average velocity:';
        strcat(num2str(avgVel), ' cm/s')};
    text(0.025,0.5,descr)
    
    % Figure parameters
    x0 = 350;       % x position on screen
    y0 = 200;       % y Position on screen
    width = 900;    
    height = 500;   
    set(gcf, 'units','points','position',[x0,y0,width,height])

% sessionData = strrep(sessionData, '.csv', '');
% saveSession = [sessionData '.png'];
% saveas(gcf, saveSession);

fclose(file); 
toc