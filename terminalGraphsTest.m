%UNCOMMENT NEXT LINE AFTER TESTS ARE DONE 
%sessionData = getLatestFile('C:\vr\vroutput\*.csv'); 
sessionData = ('MTH3_vr1_2017615_1731.csv'); 
filePath = fullfile('C:', 'vr', 'vroutput', sessionData); 
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

% Calculate total distance in short trials
temp = zeros(length(posShort),1);
for t = 1:length(temp)-1
    if numTrials(t + 1) ~= numTrials(t)
        temp(t) = 1;
    end
end 

shortDistTemp = find(temp .* posShort); % Indices of distance travelled on each short trial
distShort = pos(shortDistTemp);         % Returns distance travelled
totDistShort = sum(distShort);

% Calculate total distance in long trials
temp = zeros(length(posLong),1);
for t = 1:length(temp)-1
    if numTrials(t + 1) ~= numTrials(t);
        temp(t) = 1;
    end
end

longDistTemp = find(temp .* posLong); % Indices of distance travelled on each long trial
distLong = pos(longDistTemp);         % Returns distance travelled
totDistLong = sum(distLong);
 
figure
    subplot(6,5,[2 28])
    plot(posShort(licksShort), numTrialsShort(licksShort), 'bo') 
    xlabel('Position') 
    ylabel('Trial #') 
    title('Short trials') 
    hold on;
    
    subplot(6,5,[4 30])
    plot(posLong(licksLong), numTrialsLong(licksLong), 'ro')
    xlabel('Position')
    ylabel('Trial #')
    title('Long trials')
    hold on;
    
    ax1 = axes('Position', [0.01 0 1 1], 'Visible', 'off');
    descr = {'Short trials:';
        strcat(num2str(totalShortTrials), ' trials');
        strcat(num2str(totDistShort), ' cm');
        '';
        'Long trials:';
        strcat(num2str(totalLongTrials), ' trials');
        strcat(num2str(totDistLong), ' cm')};
    text(0.025,0.5,descr)
    
    x0 = 350;
    y0 = 200;
    width = 700;
    height = 400;
    set(gcf, 'units','points','position',[x0,y0,width,height])

saveSession = [sessionData '.fig']
savefig(saveSession)

fclose(file); 
